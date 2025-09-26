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
  sudo hostess rm studio.youtube.com
  sudo hostess rm www.youtube.com
  sudo hostess rm music.youtube.com
  sudo hostess rm www.reddit.com
  sudo hostess rm www.x.com
  sudo hostess rm www.linkedin.com
  sudo hostess rm www.instagram.com
  sudo hostess rm www.facebook.com
  echo Workmode set to WASTE
else
  sudo hostess add studio.youtube.com 127.0.0.1
  sudo hostess add www.youtube.com 127.0.0.1
  sudo hostess add music.youtube.com 127.0.0.1
  sudo hostess add www.reddit.com 127.0.0.1
  sudo hostess add www.x.com 127.0.0.1
  sudo hostess add www.linkedin.com 127.0.0.1
  sudo hostess add www.instagram.com 127.0.0.1
  sudo hostess add www.facebook.com 127.0.0.1
  echo Workmode set to WORK
fi
