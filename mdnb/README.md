# mdnb

Personalises [mdnb](https://mdnb.app/) (Local-first Markdown notebook) to match
the Zed editor setup in this repo.

What it sets:

- **Editor theme (dark):** custom `Evangelion Dark`, mirrored from the
  `eva-theme` Zed extension. 10-colour palette mapped to mdnb's
  `CustomEditorThemePalette` schema.
- **Editor font:** `FiraMono Nerd Font Mono` Medium @ 13pt (same as Zed).

Re-run `./install.sh` after editing `themes/evangelion-dark.json` to push
changes into mdnb. Quit mdnb first — settings are read via `cfprefsd` and
ignored while the app is open.
