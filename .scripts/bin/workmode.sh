#!/bin/bash

CATEGORIES=(
  "WORK"
  "WASTE"
)

selected=$(printf "%s\n" "${CATEGORIES[@]}" | sk --bind 'q:abort')
sk_status=$?

if [[ $sk_status -ne 0 || -z "$selected" ]]; then
  exit 0
fi

if [[ "$selected" == "WASTE" ]]; then
  hostess rm studio.youtube.com
  hostess rm www.youtube.com
  hostess rm music.youtube.com
  hostess rm www.reddit.com
  hostess rm www.x.com
  hostess rm www.linkedin.com
  hostess rm www.instagram.com
  echo Workmode set to WASTE
else
  hostess add studio.youtube.com 127.0.0.1
  hostess add www.youtube.com 127.0.0.1
  hostess add music.youtube.com 127.0.0.1
  hostess add www.reddit.com 127.0.0.1
  hostess add www.x.com 127.0.0.1
  hostess add www.linkedin.com 127.0.0.1
  hostess add www.instagram.com 127.0.0.1
  echo Workmode set to WORK
fi
