#!/usr/bin/env bash
# Install / refresh mdnb personalisation:
#   - Merge the Evangelion Dark custom theme into mdnb's custom-themes.json
#   - Set it as the default dark editor theme
#   - Set editor font to FiraMono Nerd Font Mono Medium @ 13pt (matches Zed)
# Safe to re-run. mdnb should be quit first or the changes won't stick.
set -euo pipefail

BUNDLE_ID="dev.sidequery.mdnb"
SUPPORT_DIR="$HOME/Library/Application Support/mdnb"
THEMES_FILE="$SUPPORT_DIR/custom-themes.json"
THEME_SRC="$(cd "$(dirname "$0")" && pwd)/themes/evangelion-dark.json"

if [[ ! -f "$THEME_SRC" ]]; then
  echo "Theme source not found at: $THEME_SRC" >&2
  exit 1
fi

if pgrep -x mdnb >/dev/null; then
  echo "mdnb is running — quit it first, then re-run this script." >&2
  echo "  osascript -e 'quit app \"mdnb\"'" >&2
  exit 1
fi

mkdir -p "$SUPPORT_DIR"

THEME_ID=$(/usr/bin/python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["id"])' "$THEME_SRC")

/usr/bin/python3 - "$THEMES_FILE" "$THEME_SRC" <<'PY'
import json, os, sys

themes_path, theme_src = sys.argv[1], sys.argv[2]
with open(theme_src) as f:
    new_theme = json.load(f)

# mdnb's custom-themes.json may not exist yet, or may be an array, or may be
# wrapped in an envelope object. Handle all three shapes.
existing = []
envelope_key = None
if os.path.exists(themes_path):
    with open(themes_path) as f:
        data = json.load(f)
    if isinstance(data, list):
        existing = data
    elif isinstance(data, dict):
        for k in ("themes", "customThemes", "_themes"):
            if k in data and isinstance(data[k], list):
                envelope_key = k
                existing = data[k]
                break
        else:
            raise SystemExit(f"Unrecognised custom-themes.json shape: keys={list(data)}")

# Upsert by id
existing = [t for t in existing if t.get("id") != new_theme["id"]]
existing.append(new_theme)

if envelope_key is not None:
    out = {envelope_key: existing}
else:
    out = existing

tmp = themes_path + ".tmp"
with open(tmp, "w") as f:
    json.dump(out, f, indent=2)
os.replace(tmp, themes_path)
print(f"Wrote {len(existing)} custom theme(s) to {themes_path}")
PY

# Point mdnb's dark editor at this custom theme, and set font preferences.
defaults write "$BUNDLE_ID" customDarkThemeID -string "$THEME_ID"
defaults write "$BUNDLE_ID" editorFontName    -string "FiraMonoNFM-Medium"
defaults write "$BUNDLE_ID" editorFontSize    -float  13

killall cfprefsd 2>/dev/null || true
echo "Done. Launch mdnb — Settings → Appearance should show 'Evangelion Dark' selected as the dark editor theme."
