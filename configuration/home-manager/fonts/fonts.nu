# List fonts
export def main [] {
  run-external fc-list : family
  | lines
  | sort
  | to text --no-newline
}

# Update the font cache
export def update [] {
  fc-cache --really-force
}
