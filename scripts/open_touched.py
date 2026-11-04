"""Open a file by its number in the files window (helpi 31).

As a UserPromptSubmit hook it catches prompts such as `open #1` or `open #1 #3`,
opens the files in their own applications and stops the prompt from reaching the
model, so it costs no tokens. Any other prompt passes through untouched.

From a shell, for any agent:  python open_touched.py 1 3
Add --dry to print what would be opened.

Only document types in SHELL_OPEN go to the Windows default application. All else,
code included, goes to Notepad++ for viewing, so this can never run a script.

Run with `python -I -S`: only the standard library is used.
"""
import json
import os
import re
import sys

ROOT = os.path.join(os.environ.get("LOCALAPPDATA", ""), "AI_runs")
INDEX = os.path.join(ROOT, "files_index.json")

PROMPT = re.compile(r"^\s*open((?:[\s,]*#\d+)+)\s*$", re.IGNORECASE)

EDITOR = ("Notepad++", [r"C:\Program Files\Notepad++\notepad++.exe"])

SHELL_OPEN = {
    ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".csv", ".ppt", ".pptx",
    ".png", ".jpg", ".jpeg", ".gif", ".svg", ".html", ".htm",
}


def choose_app(path):
    """Return (label, argv prefix); argv prefix is None for the default application."""
    ext = os.path.splitext(path)[1].lower()
    if ext in SHELL_OPEN:
        return "default app", None
    return EDITOR


def launch(path, argv):
    if argv is None:
        os.startfile(path)
        return
    import subprocess

    subprocess.Popen(
        argv + [path],
        cwd=os.path.dirname(path),
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=subprocess.CREATE_NO_WINDOW,
    )


def open_numbers(numbers, dry=False):
    """Open each numbered file and return one report line per number."""
    try:
        with open(INDEX, encoding="utf-8-sig") as f:
            paths = json.load(f)
    except (OSError, ValueError):
        return ["The files window has no list yet. Open it with helpi 31."]

    report = []
    for number in numbers:
        if not 1 <= number <= len(paths):
            report.append(f"#{number}: no such row (the list has {len(paths)}).")
            continue
        path = paths[number - 1]
        name = os.path.basename(path)
        if not os.path.isfile(path):
            report.append(f"#{number}: {name} no longer exists.")
            continue
        label, argv = choose_app(path)
        try:
            if not dry:
                launch(path, argv)
            report.append(f"#{number}: {name} opened in {label}.")
        except OSError as error:
            report.append(f"#{number}: {name} could not be opened ({error}).")
    return report


def run_hook():
    event = json.load(sys.stdin)
    match = PROMPT.match(event.get("prompt") or "")
    if not match:
        return
    numbers = [int(n) for n in re.findall(r"\d+", match.group(1))]
    # "block" keeps the prompt from the model; the reason is shown to the user.
    print(json.dumps({"decision": "block", "reason": " ".join(open_numbers(numbers))}))


if __name__ == "__main__":
    args = sys.argv[1:]
    if args:
        dry = "--dry" in args
        numbers = [int(a.lstrip("#")) for a in args if a.lstrip("#").isdigit()]
        print("\n".join(open_numbers(numbers, dry)))
    else:
        try:
            run_hook()
        except Exception:
            # A prompt must never be lost because of this hook.
            pass
