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

export def get_configuration [host?: string, --with-packages-path] {
  let kernel_name = (uname | get kernel-name)

  let base_configurations = {
    Darwin: "homeConfigurations",
    Linux: "nixosConfigurations"
  }

  let available_hosts = (get_available_hosts)

  let base = if ($host | is-empty) {
    $base_configurations
    | get $kernel_name
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
    if $kernel_name == "Darwin" {
      "benrosen"
    } else {
      cat /etc/hostname | str trim
    }
  } else {
    $host
  }

  let paths = {
    Darwin: ".config.home.packages",
    Linux: ".config.home-manager.users.benrosen.home.packages"
  }

  let packages_path = if $with_packages_path {
    if ($host | is-empty) {
      $paths
      | get $kernel_name
    } else {
      if $host in ($available_hosts | get Darwin) {
        $paths | get Darwin
      } else if $host in ($available_hosts | get Linux) {
        $paths | get Linux
      } else {
        error make {msg: "Invalid host name."}
      }
    }
  } else {
    ""
  }

  return $".#($base).($host)($packages_path)"
}

# Show available hosts
export def main [] {
  return (get_available_hosts | table --index false)
}
