# 📟 agentline

One animated statusline for every coding agent on this machine.

```
⠹ Opus 5.5·high │ ⏱ 1h2m │ ━━━━────── 47% │ 5h 31% ↻2h1m │ wk 64% ↻3d0h │ sys 74% → │ disk 148G free │ ⚙ 4 38% │ ·~·°·><>·~···~
↳ ⠇ cargo test --workspace --a…  ━━━━━ 85%  1.2G  2m  #48213   │   · rust-analyzer  ━──── 3%  88M  40s  #991   │   +2 more
```

- **Core:** `agentline/.local/bin/agentline` (stow → `~/.local/bin/agentline`). Bash + `jq`, ~0.1s.
- **Input:** Claude Code's `statusLine` JSON on stdin; every field optional. Other agents' adapters
  map what they have onto the same keys, so the rendering lives in one place.
- **Output:** always two rows, so the host never changes height. Exit status is always 0 — a
  non-zero exit makes Claude Code hide the line.

| Segment | Meaning |
|---|---|
| spinner / breathing dot | spins while the session's processes use CPU, breathes when idle |
| model | shimmer sweeps across it each second |
| context bar | gradient fill, blinking leading edge |
| `5h` / `wk` | rate-limit use and time to reset |
| `sys 74% →` | load as % of all cores (100% = every core busy), trend 1m vs 5m |
| `disk 148G free` | free space on the volume holding `$HOME` |
| `⚙ 4 38%` | processes under the agent, their summed CPU |
| pond | a fish swims laps, one step a second, trailing bubbles |
| `↳` row | each process: command line (paths shortened), CPU bar + %, memory, age, pid; wrapper shells hidden |

The agent process is the nearest ancestor named `claude`, `codex`, `opencode` or `odei`, or
`AGENTLINE_PID`. `AGENTLINE_ROWS=1` drops the process row; `AGENTLINE_WIDTH` caps how many
columns the process row uses (default 128) — lower it if your terminal is narrower, or the row
wraps and the height jumps.

## Wiring

**Claude Code** — `~/.claude/settings.json` (not committed, machine state):

```json
"statusLine": {
  "type": "command",
  "command": "/Users/enekosarasola/.local/bin/agentline",
  "refreshInterval": 1
}
```

`refreshInterval` is what animates it; without it the line only redraws on session events.

**opencode** — stow `opencode` → `~/.config/opencode/plugins/agentline/tui.tsx`, a V2 TUI plugin
auto-discovered from that directory. It builds the payload from the session (model, variant,
context % the way the built-in footer computes it), runs `agentline` every second with
`AGENTLINE_PID` set, and translates its ANSI into OpenTUI spans under the prompt.
`AGENTLINE_BIN` overrides the path.

**odei** — `export ODEI_STATUSLINE=agentline`. odei runs it before each prompt (no shell,
500 ms budget, falls back to its own line), so it redraws per prompt rather than per second.

**Codex** — no command statusline as of 0.169 (`tui_extensions_statusline` is an unwired
experiment). The closest is the built-in item list in `~/.codex/config.toml`, same order,
no branch or folder:

```toml
[tui]
status_line = ["run-state", "model-with-reasoning", "context-used", "five-hour-limit", "weekly-limit"]
```
