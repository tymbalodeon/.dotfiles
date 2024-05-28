use ./hosts.nu get_configuration
use ./hosts.nu is_nixos

# List dependencies
export def main [
  host?: string # The target host configuration (auto-detected if not specified)
  --find: string # Search for a dependency
  --installed # View packages installed by Home Manager
] {
  if $installed {
    if (is_nixos) {
      exit 1
    }

    return (home-manager packages)    
  }

  let configuration = (get_configuration $host --with-packages-path)

  let dependencies = (
    nix eval $configuration --apply "builtins.map (p: p.name)"
    | split row " "
    | filter {|line| not ($line in ["[" "]"])}
    | each {
        |line|

        $line
        | str replace --all '"' ""
      }
    | sort
    | str join "\n"
  )

  if ($find | is-empty) {
    return $dependencies
  } else {
    return (
      $dependencies
      | find $find
      | str join "\n"
    )
  }
}