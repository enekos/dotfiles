#!/usr/bin/env python3
# Set the iTerm2 tab title from Claude Code session info.
# Wired in ~/.claude/settings.json on SessionStart / UserPromptSubmit /
# PostToolUse(TaskCreate|TaskUpdate) / Stop / Notification / SessionEnd.
#
# Claude pipes a JSON payload on stdin. The in-progress task is read from
# ~/.claude/tasks/<session_id>/*.json (same source talaia's board uses), so
# the tab shows WHAT the agent is doing, not just where:
#
#   ▶ talaia · Adding SHA-1 to sutegi-crypto (+2)
#   ⚠ leela · needs you
#   ✔ thinking-os
#
# The OSC-0 sequence goes to /dev/tty (not stdout) to stay out of Claude's
# captured hook output. Always exits 0 — a title is never worth blocking on.

import json
import os
import sys
from glob import glob

MAX_TITLE = 60


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    event = payload.get("hook_event_name", "")
    cwd = payload.get("cwd") or os.getcwd()
    sid = payload.get("session_id", "")
    project = os.path.basename(cwd.rstrip("/")) or "~"

    active = None
    pending = 0
    for path in glob(os.path.expanduser(f"~/.claude/tasks/{sid}/*.json")) if sid else []:
        try:
            with open(path) as f:
                task = json.load(f)
        except Exception:
            continue
        status = task.get("status")
        if status == "in_progress" and not active:
            active = task.get("activeForm") or task.get("subject")
        elif status == "pending":
            pending += 1

    if event == "Notification":
        title = f"⚠ {project} · needs you"
    elif event in ("Stop", "SessionEnd"):
        title = f"✔ {project}"
    elif active:
        title = f"▶ {project} · {active}"
        if pending:
            title += f" (+{pending})"
    elif event == "UserPromptSubmit":
        title = f"▶ {project}"
    else:
        short = f"·{sid[:4]}" if sid else ""
        title = f"claude·{project}{short}"

    title = title[:MAX_TITLE]

    if "--print" in sys.argv:  # test mode: show the title instead of setting it
        print(title)
        return

    try:
        seq = f"\033]0;{title}\007"
        if os.environ.get("TMUX"):
            seq = f"\033Ptmux;\033{seq}\033\\"
        with open("/dev/tty", "w") as tty:
            tty.write(seq)
            tty.flush()
    except Exception:
        pass


if __name__ == "__main__":
    main()
    sys.exit(0)
