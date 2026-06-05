#!/run/current-system/sw/bin/bash

PATH="/run/current-system/sw/bin:/etc/profiles/per-user/nick/bin"
BASE="http://localhost:8384"

API_KEY=$(syncthing cli config gui apikey get 2>/dev/null)

if [ -z "$API_KEY" ]; then
  echo '{"text": "󰓦 ?", "class": "warning", "tooltip": "Cannot reach Syncthing"}'
  exit 0
fi

HEADER="X-API-Key: $API_KEY"

ping=$(curl -s -o /dev/null -w "%{http_code}" -H "$HEADER" "$BASE/rest/system/ping")
if [ "$ping" != "200" ]; then
  echo '{"text": "󰓦 ?", "class": "warning", "tooltip": "Syncthing is not running"}'
  exit 0
fi

FOLDERS=$(syncthing cli config folders list 2>/dev/null)

errors=""
for folder in $FOLDERS; do
  result=$(curl -s -H "$HEADER" "$BASE/rest/folder/errors?folder=$folder")
  folder_errors=$(echo "$result" | jq -r '.errors // [] | length')
  if [ "$folder_errors" -gt 0 ] 2>/dev/null; then
    details=$(echo "$result" | jq -r '.errors[] | "\(.path): \(.error)"' | head -5)
    errors="${errors}${folder}:\n${details}\n"
  fi
done

sys_errors=$(curl -s -H "$HEADER" "$BASE/rest/system/error")
sys_count=$(echo "$sys_errors" | jq -r '.errors // [] | length')
if [ "$sys_count" -gt 0 ] 2>/dev/null; then
  sys_details=$(echo "$sys_errors" | jq -r '.errors[] | .message' | head -5)
  errors="${errors}System:\n${sys_details}\n"
fi

if [ -n "$errors" ]; then
  tooltip=$(echo -e "$errors" | sed 's/"/\\"/g' | tr '\n' ' ')
  echo "{\"text\": \"󰓦 !\", \"class\": \"error\", \"tooltip\": \"${tooltip}\"}"
else
  echo '{"text": "󰓦", "class": "ok", "tooltip": "Syncthing: no errors"}'
fi
