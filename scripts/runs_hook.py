"""Claude Code hook: append subagent lifecycle events to the local run registry.

Wired to SubagentStart, SubagentStop and PostToolUse(Agent) as an async hook, so
it never delays a tool call. Read by scripts/runs_watch.ps1. The registry lives
outside OneDrive because it changes often and is machine-local.

Run with `python -I -S`: only the standard library is used, and startup is ~70 ms.

SubagentStart also opens the runs window when it is not already open. The window
touches window.alive on every poll; window.claim stops subagents started in the
same instant from opening one window each.
"""
import json
import os
import sys
import time

MAX_TEXT = 200
ALIVE_SECONDS = 20
CLAIM_SECONDS = 30
PWSH = r"C:\Program Files\PowerShell\7\pwsh.exe"


def main():
    event = json.load(sys.stdin)
    root = os.path.join(os.environ["LOCALAPPDATA"], "AI_runs")
    os.makedirs(root, exist_ok=True)

    tool_input = event.get("tool_input") or {}
    response = event.get("tool_response")
    if not isinstance(response, dict):
        response = {}

    record = {
        "ts": time.time(),
        "event": event.get("hook_event_name"),
        "session": event.get("session_id"),
        "cwd": event.get("cwd"),
        "agent_id": event.get("agent_id") or response.get("agentId"),
        "agent_type": event.get("agent_type") or tool_input.get("subagent_type"),
        "transcript": event.get("agent_transcript_path")
        or response.get("outputFile"),
        "description": tool_input.get("description"),
        "background": tool_input.get("run_in_background"),
        "status": response.get("status"),
        "last": (event.get("last_assistant_message") or "")[:MAX_TEXT],
    }
    # One short append per line, so concurrent sessions do not interleave.
    with open(os.path.join(root, "events.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(record, ensure_ascii=True) + "\n")

    if event.get("hook_event_name") == "SubagentStart":
        open_window(root)


def is_fresh(path, seconds):
    try:
        return time.time() - os.path.getmtime(path) < seconds
    except OSError:
        return False


def take_claim(claim):
    """Exclusive create, so of several simultaneous subagents exactly one wins."""
    for _ in range(2):
        try:
            os.close(os.open(claim, os.O_CREAT | os.O_EXCL | os.O_WRONLY))
            return True
        except FileExistsError:
            if is_fresh(claim, CLAIM_SECONDS):
                return False
            # Left behind by a launch that failed.
            try:
                os.remove(claim)
            except OSError:
                pass
    return False


def open_window(root):
    if is_fresh(os.path.join(root, "window.alive"), ALIVE_SECONDS):
        return
    if not take_claim(os.path.join(root, "window.claim")):
        return

    import subprocess

    script = os.path.join(os.path.dirname(os.path.abspath(__file__)), "runs_watch.ps1")
    subprocess.Popen(
        [PWSH, "-NoProfile", "-NonInteractive", "-File", script, "-Open"],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=subprocess.CREATE_NO_WINDOW,
    )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Monitoring must never disturb the session.
        pass
