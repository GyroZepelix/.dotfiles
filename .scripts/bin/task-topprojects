#!/bin/bash

task status:pending export | jq -r '
  group_by(.project) |
  map(sort_by(-.urgency) | .[0]) |
  sort_by(-.urgency) |
  .[] |
  [.project, "\(.urgency)", .description] |
  @tsv
' | awk '{print (NR%2 != 0 ? "\033[38;5;250m" : "\033[38;5;255m") $0 "\033[0m"}' | 
    column -t -s $'\t' -N "Project,Urgency,Description"
