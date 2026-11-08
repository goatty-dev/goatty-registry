#!/bin/sh
# Validate every plugin, re-check every download, rebuild index.json and
# sign it. Usage: scripts/publish.sh SECRET_KEY_FILE
set -eu
key=${1:?usage: scripts/publish.sh SECRET_KEY_FILE}
cd "$(dirname "$0")/.."
for dir in plugins/*/*/; do
  goatty-plugin validate "$dir" >/dev/null || { goatty-plugin validate "$dir"; exit 1; }
done
goatty-plugin check-downloads plugins/*/*/
goatty-plugin index build
goatty-plugin index sign --key "$key"
goatty-plugin index verify
echo "Now commit index.json and index.json.sig."
