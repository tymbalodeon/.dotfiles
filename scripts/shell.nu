def get_hosts [configuration] {
  return (
      nix eval $".#($configuration)" --apply builtins.attrNames err> /dev/null
      | str replace --all --regex '\[ | \]|"' ""
      | split row " "
  )
}

# Open Nix REPL with flake loaded
export def main [
    host?: string # The target host configuration (auto-detected if not specified)
    --hosts # List available hosts
] {
  let available_hosts = (
    (get_hosts "homeConfigurations")
    | wrap Darwin
    | merge (
        (get_hosts "nixosConfigurations")
        | wrap Linux
    )
  )

  if $hosts {
    return ($available_hosts | table --index false)
  }

  let is_darwin = (uname | get kernel-name) == "Darwin"

  let base_configurations = {
    Darwin: "homeConfigurations",
    Linux: "nixosConfigurations"
  }

  let base = if ($host | is-empty) {
    $base_configurations
    | get (uname | get kernel-name)
  } else {
    if $host in ($available_hosts | get Darwin) {
      $base_configurations
      | get Darwin
    } else if $host in ($available_hosts | get Linux) {
      $base_configurations
      | get Linux
    } else {
      error make {msg: "Invalid host name."}
    }
  }

  let host = if ($host | is-empty) {
    if $is_darwin {
      "benrosen"
    } else {
      cat /etc/hostname | str trim
    }
  } else {
    $host
  }

  let configuration = $".#($base).($host)"

  nix --extra-experimental-features repl-flake repl $configuration
}
