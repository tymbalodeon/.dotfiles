# List fonts
def fonts [] {
  fc-list ": family"
  | lines
  | sort
  | to text --no-newline
}
