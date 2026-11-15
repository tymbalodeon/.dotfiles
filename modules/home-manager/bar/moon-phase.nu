def main [] {
  {
    text: (moon-phases --text-emoji)
    tooltip: (moon-phases)
  }
  | to json
  | jq --compact-output --unbuffered
}
