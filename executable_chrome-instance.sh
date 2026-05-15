#!/bin/bash

NAME="$1"
shift

flatpak run io.github.ungoogled_software.ungoogled_chromium \
  --user-data-dir="$HOME/.chromes/.chrome-$NAME" \
  --class="Chrome${NAME^}" \
  --new-window \
  "$@"
