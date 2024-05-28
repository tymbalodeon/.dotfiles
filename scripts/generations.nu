use ./hosts.nu is_nixos

# View generations
export def main [] {
  if (is_nixos) {
    exit 1
  }

  home-manager generations
}
