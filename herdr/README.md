# 🐑 herdr

Config for [herdr](https://herdr.dev) — a terminal multiplexer with first-class
agent panes. This package covers the **keymap and theme**; the plugins that the
keymap points at are installed separately (see below).

- **Config:** `herdr/.config/herdr/config.toml` (stow → `~/.config/herdr/config.toml`)
- **Requires:** herdr ≥ 0.8 (`es.quick-actions` 0.2.0 needs the `pane swap`/`move`
  and `worktree` CLI verbs), plus `fzf` and `jq` for the two picker plugins.

Apply changes without restarting:

```bash
herdr server reload-config
```

It reports `{"status":"applied","diagnostics":[]}` on success — a bad key name
shows up as a diagnostic rather than failing silently.

---

## Keymap

The prefix is **`ctrl+`` `** rather than herdr's default `ctrl+b`, which collides
with readline/shell muscle memory far more than backtick does.

| Keys | Action |
|---|---|
| `ctrl+h/j/k/l` | Focus pane left/down/up/right — **no prefix** |
| `prefix` `shift+h` / `shift+l` | Previous / next tab |
| `prefix` `` ` `` | Command palette (`jt.command-palette`) — every installed plugin's actions |
| `prefix` `x` | Quick actions (`es.quick-actions`) — herdr's own native actions |
| `prefix` `z` | File viewer in a split (`herdr-file-viewer`) |

Two of these take something away, on purpose:

- **`ctrl+h/j/k/l`** mirrors LazyVim / vim-tmux-navigator window nav, so pane
  movement needs no prefix. The cost is that those keys stop reaching the shell
  or agent in a focused pane — `ctrl+l` no longer clears the terminal, `ctrl+k`
  no longer kills to end of line. Same trade vim-tmux-navigator makes. Delete
  the block and reload to get them back.
- **`prefix+x`** is herdr's default `close_pane`. Quick actions is bound over it,
  so close pane now goes through the picker (which shows it with an empty
  shortcut column, because it correctly detects the key was taken).

Tab cycling stays inside prefix mode because a bare `shift+<letter>` can't be a
direct binding — it would swallow ordinary capital letters as you type.

---

## Plugins

Not committed here: herdr tracks installed plugins in
`~/.config/herdr/plugins.json`, which is machine state (absolute paths, resolved
commits, install timestamps), not config. Reinstall them on a new machine with:

```bash
# Command palette — fuzzy list of every installed plugin's actions
herdr plugin install github:JanTvrdik/herdr-command-palette

# Git-aware read-only file viewer in a split pane
herdr plugin install github:smarzban/herdr-file-viewer

# Quick actions — fzf picker over herdr's OWN native actions, each row
# annotated with the keybinding herdr actually has for it
herdr plugin link ~/eneko_projects/herdr-quick-actions
```

`es.quick-actions` is mine and lives in its own repo
([enekos/herdr-quick-actions](https://github.com/enekos/herdr-quick-actions)),
linked from a local checkout rather than installed from GitHub. The two pickers
are complements, not duplicates: the command palette lists *plugin* actions,
which by definition never include herdr's built-in keybindings; quick actions
covers exactly those, plus live jump targets (other tabs, workspaces, running
agents, and worktrees of the current repo you haven't opened yet).

---

## What's deliberately not stowed

Everything else in `~/.config/herdr/` is runtime state that herdr owns and
rewrites: `session.json`, `plugins.json`, `.plugins.lock`, `release-notes.json`,
the `*.log` files, the `*.sock` files, and the `plugins/` tree of installed
plugin checkouts. Those are gitignored so that a `stow herdr` on a machine with
no `~/.config/herdr` yet — where stow symlinks the whole directory instead of
folding into it — can't start committing session state into this repo.
