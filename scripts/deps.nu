#!/usr/bin/env nu

use ./hosts.nu get_configuration
use ./hosts.nu is_nixos

# List dependencies
def main [
  host?: string # The target host configuration (auto-detected if not specified)
  --dev # View dev dependencies
  --find: string # Search for a dependency
  --installed # View packages installed by Home Manager
] {
  let dependencies = if $dev {
    open flake.nix
    | rg --multiline "packages = .+\\[(\n|[^;])+\\];"
    | lines
    | drop
    | drop nth 0
    | str trim
    | to text
  } else if $installed {
    if (is_nixos) {
      exit 1
    }
    
    try {
      home-manager packages
    } catch {
      exit 1
    }
  } else {
    let configuration = (get_configuration $host --with-packages-path)

    nix eval $configuration --apply "builtins.map (package: package.name)"
    | split row " "
    | filter {|line| not ($line in ["[" "]"])}
    | each {
        |line|

        $line
        | str replace --all '"' ""
      }
    | sort
    | to text
  }

  if ($find | is-empty) {
    return $dependencies
  } else {
    return (
      $dependencies
      | rg --color always $find
    )
  }
}
