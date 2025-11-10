# List fonts
def fonts [] {
  run-external fc-list : family
  | lines
  | sort
  | to text --no-newline
}
