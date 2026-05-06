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

if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$url"
elif command -v open >/dev/null 2>&1; then
  open "$url"
else
  echo "No supported opener found (xdg-open/open)"
  exit 1
fi
