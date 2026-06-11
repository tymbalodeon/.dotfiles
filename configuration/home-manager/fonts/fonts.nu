# List fonts
def font [] {
  run-external fc-list : family
  | lines
  | sort
  | to text --no-newline
}

alias fonts = font

# Preview fonts
def "font preview" [] {
  fontpreview
}

# Update the font cache
def "font update" [] {
  fc-cache --really-force
}
