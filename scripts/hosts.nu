def get_hosts [configuration] {
  return (
      nix eval $".#($configuration)" --apply builtins.attrNames err> /dev/null
      | str replace --all --regex '\[ | \]|"' ""
      | split row " "
  )
}

def get_available_hosts [] {
  return (
    (get_hosts "homeConfigurations")
    | wrap Darwin
    | merge (
        (get_hosts "nixosConfigurations")
        | wrap Linux
    )
  )
}

export def get_configuration [host?: string] {
  let is_darwin = (uname | get kernel-name) == "Darwin"

  let base_configurations = {
    Darwin: "homeConfigurations",
    Linux: "nixosConfigurations"
  }

  let available_hosts = (get_available_hosts)

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

  return $".#($base).($host)"
}

# Show available hosts
export def main [] {
  return (get_available_hosts | table --index false)
}
