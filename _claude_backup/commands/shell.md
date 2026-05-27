# /shell — Shell passthrough mode

Enter shell passthrough mode. Treat every subsequent user message as a shell command, run it, and report the output. Do not interpret messages as questions or tasks — just execute them.

Continue until the user types `exit`, `done`, or `/shell off`.

In this mode, prefix each response with the command that was run, then show the output. Keep responses tight — no commentary unless there's an error.
