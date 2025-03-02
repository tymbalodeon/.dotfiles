#!/usr/bin/env nu

use ./color.nu colorize
use ./color.nu get-colorized-configuration-name
use ./color.nu get-colors

export def get-current-system [] {
  let release_file = "/etc/os-release"

  let system = if ($release_file | path exists) {
    open /etc/os-release
    | parse "{key}={value}"
    | where key == NAME
    | first
    | get value
  } else {
    (uname).kernel-name
  }

  $system
  | str downcase
}

export def is-nixos [] {
  (get-current-system) == "NixOS"
}

export def get-all-systems [] {
  ls --short-names configuration/systems
  | get name
}

export def get-hosts [system: string] {
  ls --short-names (
    "configuration"
    | path join systems
    | path join $system
    | path join hosts
  )
  | get name
}

export def get-all-hosts [] {
  get-all-systems
  | each {|system| get-hosts $system}
  | flatten
  | sort
}

export def get-all-configurations [] {
  let systems = (get-all-systems)

  $systems
  | append (
      $systems
    | each {|system| get-hosts $system}
  )
  | flatten
  | sort
}

export def get-configuration-data [] {
  let systems = (get-all-systems)

  mut system_hosts = {}

  for system in $systems {
    $system_hosts = (
      $system_hosts
      | insert $system (
          get-hosts $system
        )
    )
  }

  {
    systems: $systems
    hosts: (get-all-hosts)
    system_hosts: $system_hosts
  }
}

export def get-built-host-name [] {
  if (is-nixos) {
    cat /etc/hostname
    | str trim
  } else {
    if (
      try {
        (
          rg
            (git config user.email)
            (
              ls ("**/systems/darwin/hosts/work/git/.gitconfig" | into glob)
              | get name
              | first
            )
        )
        | is-not-empty
      } catch {
        false
      }
    ) {
      "work"
    } else {
      whoami
    }
  }
}

def raise_configuration_error [configuration: string --systems] {
  let available_configurations = if $systems {
    get-all-systems
  } else {
    get-all-configurations
  }
  | each {|configuration| $"• ($configuration)"}
  | str join "\n"

  let type = if $systems {
    "system"
  } else {
    "configuration"
  }

  error make --unspanned {
    msg: $"unrecognized ($type) name '($configuration)'

Available ($type)s:
($available_configurations)"
    }
}

export def validate-configuration-name [
  configuration?: string
  --validate-system
] {
  if ($configuration | is-empty) {
    return
  }

  if $validate_system and ($configuration not-in (get-all-systems)) {
    raise_configuration_error $configuration --systems
  }

  if not ($configuration in (get-all-hosts)) and not ($configuration in (get-all-systems)) {
    raise_configuration_error $configuration
  }

  $configuration
}

export def get-file-path [file: string] {
  $file
  | str replace configuration/ ""
  | str replace --regex 'systems/[^/]+/' ""
  | str replace --regex 'hosts/[^/]+/' ""
}

# List configurations
export def main [
  system?: string # List hosts for $system
  --current-host # View current host
  --current-system # View current system
  --current-system-hosts # List hosts for current system
  --hosts # List hosts
  --systems # List systems
] {
  if $current_host {
    return (get-built-host-name)
  }

  if $current_system {
    return (get-current-system)
  }

  let configuration_data = (get-configuration-data)

  let output = if $current_system_hosts {
    $configuration_data.system_hosts
    | get (get-current-system)
  } else if $systems {
    $configuration_data.systems
  } else if ($system | is-not-empty) {
    validate-configuration-name $system --validate-system

    $configuration_data.system_hosts
    | get $system
  } else if $hosts {
    $configuration_data.hosts
  } else {
    null
  }

  if ($output | is-not-empty) {
    return ($output | str join "\n")
  }

  let colors = (get-colors (get-all-configurations))

  $configuration_data.systems
  | each {
      |host_system|

      $configuration_data.system_hosts
      | get $host_system
      | each {
          |host|

          $"($host) (get-colorized-configuration-name $host_system $colors)"
        }
    }
  | flatten
  | sort
  | to text
  | column -t
}
