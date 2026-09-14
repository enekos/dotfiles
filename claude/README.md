# 🪝 claude

[Claude Code](https://claude.com/claude-code) hooks. Every file here is a
`PreToolUse` guard or a status reporter that Claude Code runs as a subprocess,
handing it the pending tool call as JSON on stdin.

- **Hooks:** `claude/.claude/hooks/` (stow → `~/.claude/hooks/`)
- **Runtime:** the guards are TypeScript run by [bun](https://bun.sh) — one
  language for anything that has to parse a command line, and a shebang so
  they stay executable on their own. `set-tab-title.py` is the exception: it
  only reshuffles a JSON payload and has no bun dependency worth adding.
- **Wiring:** not committed — `~/.claude/settings.json` is machine state
  (model, plugins, permissions). Copy the snippet at the bottom into it.

Two invariants every guard here keeps:

- **Fail open.** A parse error, a missing file, an unexpected payload — the
  hook exits 0 with no output and the tool call proceeds. A broken guard must
  never wedge every Bash call in every session.
- **The deny reason is the retry.** Claude reads `permissionDecisionReason`
  verbatim, so it spells out the exact allowed alternative rather than just
  saying no. A guard that only says no gets worked around.

---

## The hooks

| File | Event | What it stops |
|---|---|---|
| `enforce-zz.ts` | `PreToolUse(Bash)` | `cd <dir> && <cmd>` chains — rewrites them to `zz`, the zoxide jumper |
| `protect-pr-body.ts` | `PreToolUse(Bash)` | Rewriting the body of an **open** PR (`gh pr edit --body`, `gh api PATCH /pulls/n`) |
| `no-agent-comments.ts` | `PreToolUse(Bash, file writes, Linear MCP)` | Agent-written comments and reviews on GitHub and Linear |
| `set-tab-title.py` | session + task events | Nothing — sets the iTerm2 tab title to the in-progress task |

### `enforce-zz.ts`

`cd /some/path && cmd` is disallowed on this machine; `zz <query> <cmd>` runs
the command in the best zoxide match instead. The deny reason carries the
exact rewrite (`zz data pnpm test`), because a guard that only says "use zz"
gets answered with `git -C` and `--manifest-path` workarounds.

### `protect-pr-body.ts`

PR descriptions are written once, by hand, at `gh pr create`. Agents iterating
on an open PR kept overwriting them. Editing the title, labels, reviewers or
base is untouched; so is `gh pr comment` as far as this hook is concerned —
that one is the next guard's business.

### `no-agent-comments.ts`

A comment on a PR, issue or Linear ticket is published writing with my name on
it, read by colleagues who cannot tell an agent wrote it. Findings belong in
the terminal, in the wiki, or in a draft I post myself.

Denied:

- `gh pr comment`, `gh issue comment`, `gh pr review`
- `gh api` / `curl` **writes** to any `/comments` or `/reviews` endpoint, and
  the GraphQL comment mutations (`addComment`, `submitPullRequestReview`, …)
- `linear issue comment add|update|delete`, and `commentCreate` &co. through
  `linear api` or the REST endpoint
- the Linear MCP tools `save_comment`, `save_diff_comment`,
  `submit_diff_review`, `delete_comment`, `delete_diff_comment`

Still allowed, deliberately: every **read** (`gh pr view --comments`,
`gh api …/comments` with no write method, `linear issue comment list`,
`list_comments`), `gh pr create` — opening a PR is not commenting on someone
else's thread — and editing the Linear issue itself (status, assignee,
description).

Prose about all of this stays allowed: quoted spans and heredoc bodies are
masked before matching, so a commit message or a doc that names `gh pr review`
is not itself a review. The mask lifts when the command line runs an
interpreter (`bash`, `ssh`, `python`), where a heredoc body *is* the command.

**Escape hatch.** Mine, never the agent's:

```bash
ALLOW_EXTERNAL_COMMENT=1 claude        # whole session
touch ~/.claude/allow-external-comment # 15-minute window
```

Bash commands that set that variable or write that file, and `Write`/`Edit`
calls that target it, are themselves denied — so an agent cannot hand itself
the permission. It is a guardrail, not a sandbox: anything that shells out
through a script the hook never sees is out of its reach, and that is fine.
The point is to stop drift, not a determined adversary.

---

## Install

`~/.claude/hooks/` usually already holds files, so stow needs to adopt them
rather than refuse to fold:

```bash
cd ~/dotfiles
stow --adopt claude
git diff        # confirm adopt didn't pull a stale local copy over the repo's
git checkout .  # if it did
```

`herdr-agent-state.sh` also lives in that directory on my machine. It is
installed and overwritten by [herdr](https://herdr.dev) itself, so it is
vendor state and stays out of this repo.

## Wiring

Paths are absolute because Claude Code does not expand `~` for every event,
and `$CLAUDE_PROJECT_DIR` points at the project, not at the config. `bun` is
called by absolute path too — hooks do not inherit an interactive shell's
`PATH`. Merge into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "/Users/you/.bun/bin/bun /Users/you/.claude/hooks/enforce-zz.ts" },
          { "type": "command", "command": "/Users/you/.bun/bin/bun /Users/you/.claude/hooks/protect-pr-body.ts" }
        ]
      },
      {
        "matcher": "Bash|Write|Edit|NotebookEdit|mcp__linear-server__.*",
        "hooks": [
          { "type": "command", "command": "/Users/you/.bun/bin/bun /Users/you/.claude/hooks/no-agent-comments.ts" }
        ]
      }
    ],
    "SessionStart": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "/Users/you/.claude/hooks/set-tab-title.py" }] }
    ],
    "UserPromptSubmit": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "/Users/you/.claude/hooks/set-tab-title.py" }] }
    ],
    "PostToolUse": [
      { "matcher": "TaskCreate|TaskUpdate", "hooks": [{ "type": "command", "command": "/Users/you/.claude/hooks/set-tab-title.py" }] }
    ],
    "Stop": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "/Users/you/.claude/hooks/set-tab-title.py" }] }
    ],
    "Notification": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "/Users/you/.claude/hooks/set-tab-title.py" }] }
    ],
    "SessionEnd": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "/Users/you/.claude/hooks/set-tab-title.py" }] }
    ]
  }
}
```

Hook edits take effect on the next tool call — no restart.

## Testing a guard

Each one takes a `PreToolUse` payload on stdin and prints the deny JSON, or
nothing at all when it lets the call through:

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"gh pr comment 1 -b hi"}}' \
  | bun ~/.claude/hooks/no-agent-comments.ts
```

`set-tab-title.py --print` prints the title instead of emitting the escape
sequence.
