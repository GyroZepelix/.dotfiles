#!/bin/bash

W=$(tmux display-message -p '#{window_width}')

# Calculate 80% of the width
L=$((W * 4 / 5))

# Resize left pane (pane 0) to 80% of size
tmux resize-pane -t 0 -x $L
