# ⚡ NERV Terminal — Evangelion Dark starship prompt

A stack-aware [Starship](https://starship.rs) prompt themed to match this repo's
`nvim/evangelion-dark.lua` colorscheme and the iTerm2 "Evangelion Dark" preset.
Same palette across editor, terminal, and prompt.

- **Config:** `starship/.config/starship.toml` (stow → `~/.config/starship.toml`)
- **Requires:** starship ≥ 1.23, a **Nerd Font** in your terminal (you already
  run `eza --icons`, so this is covered).

---

## What it looks like

```
 aatxe    feat/at-field  ● +1   v1.95.0                        3s   11:41
❯
 webapp    feat/new-parser  ● ?  +26 -13   v22.3.0   ☸ staging/api  ☁ acme-prod
❯
```

Two lines: a row of floating **pills** (only the relevant ones render), then a
bare `❯` you actually type against. Command duration, background-job count, and
the clock sit on the **right** edge.

---

## Segments & color language

The palette is NERV console: **EVA-01 purple** = location, **MAGI green** = git,
**amber** = caution/versions, **klaxon red** = danger/error, **LCL cyan** = Go/Docker.

| Segment | Looks like | Meaning |
|---|---|---|
| **Directory** | purple pill | cwd, truncated to 3 dirs / repo root. `` = read-only. |
| **Git branch** | green text | current branch + in-flight state (rebase/merge/cherry-pick). |
| **Git status** | amber flags | `●` modified · `✚` staged · `?` untracked · `»` renamed · `✘` deleted · `⚔` conflict · `` stashed · `⇡⇣` ahead/behind. |
| **Git metrics** | `+N` green `-N` red | lines added / removed vs HEAD. |
| **Rust** | red pill  | `rustc` version — shows in Cargo projects. |
| **Go** | cyan pill  | `go` version — shows in Go modules. |
| **Node** | green pill  | `node` version — shows with `package.json`/`.nvmrc`. |
| **Bun** | 🥟 pill | `bun` version — shows with `bun.lockb`. |
| **Python** | amber pill  | interpreter + active virtualenv. |
| **Docker** | cyan pill  | non-default docker context (only near a Dockerfile/compose). |
| **Kubernetes** | red pill ☸ | context/namespace — **scoped** (see below). |
| **gcloud** | amber pill ☁ | active GCP project. |
| **Character** | `❯` | **green** = last command OK, **red** = failed, **amber `❮`** = vim normal mode. |

Language pills auto-detect: you only see Rust in Rust repos, Node in Node repos,
etc. Nothing to toggle per-project.

---

## Design notes (why it's built this way)

- **Floating pills, not a connected powerline.** Each segment is self-contained
  — `[](c) [ text ](fg bg) [](c)` — so a *missing* module never breaks the
  color hand-off to its neighbour. Classic powerline chains (`[](fg_prev bg_next)`)
  shatter the moment one optional module is absent; these don't.
- **k8s is a red klaxon and gcloud is amber** on purpose: seeing your cluster /
  project at a glance is cheap insurance against running the right command in the
  wrong place. On-call muscle memory.
- **Right-aligned timing/clock** keeps the left edge stable so your eye always
  lands on the same spot for cwd + git.

---

## Tuning

### Kubernetes — quiet by default, on-demand when you want it
To avoid clutter while coding, the `☸` pill only appears in infra contexts —
dirs named `k8s`/`kubernetes`/`helm`/`charts`, or near a `Dockerfile`,
`Chart.yaml`, `skaffold.yaml`, `kustomization.yaml`, or `*.tf`. **To make it
show on every prompt** (full on-call mode), delete the `detect_*` lines under
`[kubernetes]`.

### gcloud — active project, everywhere
The `☁` pill shows your active gcloud project on every prompt (you're a GCP shop
and it doubles as a "is this prod?" guard). If it's noise on hobby repos, either:
- silence it entirely: set `disabled = true` under `[gcloud]`, or
- shorten it: it already shows `$project` only (no account/region).

### Slow-command threshold
The right-side `  3s` badge only appears for commands slower than **2s**
(`[cmd_duration] min_time = 2000`). Lower it to see more, raise it for less.

### The clock
`[time] time_format = "%H:%M"`. Set `disabled = true` to drop it.

---

## Install / apply

Managed with GNU Stow like the rest of this repo:

```bash
stow -d ~/dotfiles -t ~ starship      # symlinks ~/.config/starship.toml
exec zsh                              # or open a new shell
```

Preview a render for any directory without cd-ing there:

```bash
starship prompt --path ~/code/webapp --logical-path ~/code/webapp --status 0
```

---

## Gotcha (if you edit the TOML)

**Top-level keys must come before the first `[table]` header.** In TOML, a bare
`key = value` written *after* a `[table]` header is parsed as a member of that
table. `format` and `right_format` are deliberately placed **above**
`[palettes.evangelion]` for exactly this reason — move them below it and starship
silently falls back to its default format (and stray segments like `is 📦`
reappear). Verify what actually loaded with:

```bash
starship print-config | grep '^format ='
```

If that shows `format = "$all"`, your custom format isn't being applied.
