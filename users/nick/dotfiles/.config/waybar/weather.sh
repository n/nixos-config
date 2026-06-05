#!/run/current-system/sw/bin/bash

text=$(curl -s 'wttr.in/?format=%c%t' | tr -s ' ')
tooltip=$(curl -s 'wttr.in/?0T' | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' '\r' | sed 's/\r/\\n/g')

printf '{"text": "%s", "tooltip": "%s"}' "$text" "$tooltip"
