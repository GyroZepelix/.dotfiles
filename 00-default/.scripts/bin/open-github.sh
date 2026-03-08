#! /bin/bash

url=$(git remote get-url origin 2>/dev/null)

if [[ -z "$url" ]]; then
  echo "No remote found"
  exit 1
fi

if [[ $url == git@* ]]; then
  url="${url#git@}"
  url="${url/:/\/}"
  url="https://$url"
fi

xdg-open "$url" || echo "No remotes found"
