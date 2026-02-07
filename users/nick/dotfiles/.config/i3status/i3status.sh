#!/usr/bin/env bash

i3status | while read -r line; do
  case "$line" in
  '{"version":'* | '[')
    echo "$line"
    ;;
  '['* | ',['*)
    temp=$(sensors -j | jq -r '."k10temp-pci-00c3".Tctl.temp1_input * 9/5 + 32 | round' 2>/dev/null)
    prefix=""
    [[ $line == ','* ]] && prefix="," && line="${line:1}"
    echo -n "$prefix"
    echo "$line" | jq -c "[{\"full_text\":\"cpu: ${temp:-?}°F\",\"name\":\"cpu_temp\"}] + ."
    ;;
  *)
    echo "$line"
    ;;
  esac
done
