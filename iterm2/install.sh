#!/usr/bin/env bash
# Apply the Evangelion Dark color preset to iTerm2's Default profile.
# Safe to re-run. iTerm2 should be closed for the change to stick.
set -euo pipefail

PRESET_NAME="Evangelion Dark"
PRESET_FILE="$HOME/Library/Application Support/iTerm2/ColorPresets/${PRESET_NAME}.itermcolors"
PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

if [[ ! -f "$PRESET_FILE" ]]; then
  echo "Preset not found at: $PRESET_FILE" >&2
  echo "Run \`stow iterm2\` from ~/dotfiles first." >&2
  exit 1
fi

if pgrep -x iTerm2 >/dev/null; then
  echo "iTerm2 is running — quit it first, then re-run this script." >&2
  exit 1
fi

cp "$PLIST" "${PLIST}.bak.$(date +%Y%m%d%H%M%S)"

python3 - "$PRESET_FILE" "$PLIST" <<'PY'
import plistlib, sys

preset_path, plist_path = sys.argv[1], sys.argv[2]
with open(preset_path, "rb") as f:
    preset = plistlib.load(f)
with open(plist_path, "rb") as f:
    data = plistlib.load(f)

default_guid = data.get("Default Bookmark Guid")
bookmarks = data.get("New Bookmarks", [])

targets = [i for i, b in enumerate(bookmarks) if b.get("Guid") == default_guid]
if not targets and bookmarks:
    targets = [0]

for i in targets:
    b = bookmarks[i]
    for k, v in preset.items():
        b[k] = v
        # Override macOS appearance-tied variants so the theme stays consistent
        # whether the system is in light or dark mode.
        b[f"{k} (Dark)"] = v
        b[f"{k} (Light)"] = v
    b["Use Bright Bold"] = True
    bookmarks[i] = b

data["New Bookmarks"] = bookmarks
with open(plist_path, "wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)
print(f"Applied {len(preset)} colors to {len(targets)} profile(s).")
PY

killall cfprefsd 2>/dev/null || true
echo "Done. Launch iTerm2."
