def get_hosts [configuration] {
  return (
      nix eval $".#($configuration)" --apply builtins.attrNames err> /dev/null
      | str replace --all --regex '\[ | \]|"' ""
      | split row " "
  )
}

# Open Nix REPL with flake loaded
def shell [
    host?: string # The target host configuration (auto-detected if not specified)
    --hosts # List available hosts
] {
  let available_hosts = (
    (get_hosts "homeConfigurations")
    | wrap Darwin
    | merge (
        (get_hosts "nixosConfigurations")
        | wrap NixOS
    )
  )

  if $hosts {
    return ($available_hosts | table --index false)
  }

  let is_darwin = (uname | get operating-system) == "Darwin"

  let base_configurations = {
    Darwin: "homeConfigurations",
    NixOS: "nixosConfigurations"
  }

  let base = if ($host | is-empty) {
    $base_configurations
    | get (uname | get operating-system)
  } else {
    if $host in ($available_hosts | get Darwin) {
      $base_configurations
      | get Darwin
    } else if $host in ($available_hosts | get NixOS) {
      $base_configurations
      | get NixOS
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
