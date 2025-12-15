# List fonts
def fonts [] {
  run-external fc-list : family
  | lines
  | sort
  | to text --no-newline
}

# Update the font cache
def "fonts update" [] {
  fc-cache --really-force
}
