# Global operating notes

## Directory navigation — prefer `zz` over `cd <dir> && …`

`zz` is a zoxide-based jumper at `~/.local/bin/zz` that resolves a directory
query and runs a command inside it. Prefer it to `cd <dir> && <command>`: it
resolves worktrees and keeps the session's working directory where it was.
Nothing enforces this — `cd` still works when it is the simpler tool.

- `zz <query> <command>` — run in the best zoxide match (`zz meta pnpm dev`, `zz aatxe cargo test`).
- `zz -r <query> <command>` — run at the `.git` root of the resolved dir.
- `zz -p <query>` — **print the resolved path and exit** (agent-safe, never hangs). Compose: `git -C "$(zz -p data)" status`, `cat "$(zz -p sutegi)/Cargo.toml"`.

### Git worktrees

- `zz <query>@<branch> <command>` or `zz -w <branch> <query> <command>` — run in that repo's **existing** worktree.
- **`@branch` is a partial match**: exact name → unique prefix → unique substring. `zz data@shared pnpm test` resolves the sole `shared*` worktree; you don't need the full branch name. An ambiguous fragment exits non-zero and lists the candidates — re-run with a longer fragment, don't assume.
- `zz -W <query>` lists a repo's worktrees (`branch<TAB>path`); add `--json` for machine-readable output. **Agent-safe** — never spawns fzf or a shell. Use it to discover worktrees before jumping.
- `zz <query>@?` is an interactive fzf picker (terminal only — don't use from an agent).

#### Creating a worktree for a task (agents)

When you're handed a task that should live on its own branch (a fix, a feature, an experiment), don't work in the main checkout — make a worktree with `-c/--create`:

- `zz -c <query>@<new-branch> <command>` (or `zz -c -w <new-branch> <query> <command>`) — if the worktree for `<new-branch>` doesn't exist, `zz` creates it itself with plain `git worktree add` (no external helper) into a sibling `<repo>-worktrees/<branch-slug>` dir, then runs `<command>` inside it. A new branch is cut from the base ref (`main` → `master` → current `HEAD`); an already-existing branch is just checked out. If the worktree already exists, `-c` is a no-op and it just runs there — so `-c` is safe to pass unconditionally when you want "use this worktree, creating it if needed."
- **Agents must pass `-c` explicitly.** Without it, a missing worktree only prompts y/N in a terminal; non-interactively `zz` errors out and prints the path it *would* create instead of creating anything.
- Pick a descriptive branch name for the task (e.g. `fix-csrf-timing`, `feat-thread-pagination`), then run your work through that worktree: `zz -c data@fix-csrf-timing pnpm test`. First invocation creates it and runs; later invocations reuse it.
- To resolve the new worktree's path without running anything (e.g. to Read/Edit files there), combine with `-p`: `zz -c -p data@fix-csrf-timing` prints (and creates) the path.
- Tuning: `ZZ_WORKTREE_DIR` overrides where worktrees are placed (grouped by repo name underneath), and `ZZ_WORKTREE_BASE` overrides the base ref for new branches (e.g. `ZZ_WORKTREE_BASE=develop zz -c data@feat-x …`).

Full reference: the `zz` skill.

## Rust — read the style guide before editing

Before writing or reviewing Rust in any repo, read
`~/thinking-os/concepts/rust-style-guide.md`: ownership, thread safety,
`unsafe`, security and performance rules, a lint baseline, and the
"before you say done" checklist. A crate's own `[lints]` / `clippy.toml` win on
conflict. For a full review, also load
<https://microsoft.github.io/rust-guidelines/agents/all.txt>.

## Commits and pull requests

- No `Co-Authored-By` trailer and no other AI-attribution line in commit
  messages, in any repo.
- Open pull requests as drafts unless told otherwise; write the body once, at
  `gh pr create`.
