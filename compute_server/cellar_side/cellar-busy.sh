#!/bin/sh
# cellar-busy: one-line status used by the Windows sleep watchdog (cellar_watchdog.ps1). Runs as rich.
# Prints: ssh=<established sessions on :2222> tmux=<tmux sessions> load=<1-min load>
ssh=$(ss -Htn state established '( sport = :2222 )' 2>/dev/null | wc -l)
tmux=$(tmux ls 2>/dev/null | wc -l)
load=$(cut -d' ' -f1 /proc/loadavg)
echo "ssh=$ssh tmux=$tmux load=$load"
