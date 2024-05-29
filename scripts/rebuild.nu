use ./hosts.nu get_available_hosts
use ./hosts.nu is_nixos
use ./update-deps.nu

# Rebuild and switch to (or --test) a configuration
export def main [
    host?: string # The target host configuration (auto-detected if not specified)
    --hosts # The available hosts on the current system
    --test # Apply the configuration without adding it to the boot menu
    --update # Update the flake lock before rebuilding
] {
  if $update {
    update-deps
  }

  let is_nixos = (is_nixos)

  if $hosts {
    let hosts = if $is_nixos {
      get_available_hosts | get NixOS
    } else {
      get_available_hosts | get Darwin 
    }

    return ($hosts | str join "\n")
  }

  let host = if ($host | is-empty) {
    if $is_nixos {
      cat /etc/hostname | str trim
    } else {
      "benrosen"
    }
  } else {
    $host
  }

  let host = $".#($host)"

  git add .

  if $is_nixos {
    if $test {
        sudo nixos-rebuild test --flake $host
    } else {
        sudo nixos-rebuild switch --flake $host
    }
  } else {
    home-manager switch --flake $host
  }

  bat cache --build

  if not (git status --short | is-empty) {
    git status
  }
}
