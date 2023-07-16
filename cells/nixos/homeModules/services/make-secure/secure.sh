#!/usr/bin/env bash

kill_or_nuke() {
  pkill -x "$1" || pkill -x -9 "$1"
}

run_secure() {
  echo "lock screen state changed: secured"

  # kill all SSH sessions and force them if they don't cooperate
  kill_or_nuke ssh
}

run_unsecure() {
  echo "lock screen state changed: unsecured"
}

echo "make-secure is listening for dbus events"
while true; do
  dbus-monitor --session "type='signal',path=/org/freedesktop/ScreenSaver,interface='org.freedesktop.ScreenSaver'" \
    | while read -r x; do
      case "$x" in
        # You can call your desired script in the following line instead of the echo:
        *"boolean true"*) run_secure ;;
        *"boolean false"*) run_unsecure ;;
      esac
    done
done
