#!/run/current-system/sw/bin/bash
choice=$(echo -e 'Lock\nMonitors Off\nShutdown\nReboot\nLogout' | /run/current-system/sw/bin/fuzzel --dmenu -p 'Power: ')
case "$choice" in
Lock) swaylock -f -e -l -i ~/.background-image -s fill ;;
"Monitors Off") /run/current-system/sw/bin/niri msg action power-off-monitors ;;
Shutdown) /run/current-system/sw/bin/systemctl poweroff ;;
Reboot) /run/current-system/sw/bin/systemctl reboot ;;
Logout) /run/current-system/sw/bin/niri msg action quit ;;
esac
