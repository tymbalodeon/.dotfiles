# Collect garbage and remove old generations
export def main [
  --older-than: string # Remove generations older than this amount
] {
  if ($older_than | is-empty) {
    nix-collect-garbage
  } else {
    nix-collect-garbage --delete-older-than $older_than
  }
}
