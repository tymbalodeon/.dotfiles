#!/usr/bin/env nu

use color.nu colorize
use color.nu get-colorized-configuration-name
use color.nu get-colors
use ../../default/scripts/print.nu print-error

export def get-current-system [] {
  let release_file = "/etc/os-release"

  # TODO (nixos): use ID instead?
  let system = if ($release_file | path exists) {
    open /etc/os-release
    | parse "{key}={value}"
    | where key == NAME
    | first
    | get value
  } else {
    (uname).kernel-name
  }
  | str downcase

  if ($system not-in [darwin nixos]) {
    "home-manager"
  } else {
    $system
  }
}

export def is-nixos [] {
  (get-current-system) == "nixos"
}

export def is-linux [] {
  (is-nixos) or "linux" in (get-current-system)
}

export def get-all-systems [] {
  ls --short-names configuration/hosts
  | get name
}

export def get-hosts [system: string] {
  ls --short-names $"configuration/hosts/($system)"
  | get name
  | where {($in | path split | length) == 5}
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
  | append shared
  | flatten
  | sort
}

export def get-configuration-data [] {
  fd "" configuration/hosts
  | lines
  | where {($in | path split | length) == 5}
  | parse "configuration/hosts/{system}/{channel}/{host}/"
}

export def get-built-host-name [] {
  (uname).nodename
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

def validate-system-name [system?: string] {
  if ($system | is-empty) {
    return
  }

  if ($system not-in (get-all-systems)) {
    raise_configuration_error $system --systems
  }
}

export def validate-configuration-name [
  configuration?: string
  --validate-system
] {
  if ($configuration | is-empty) {
    return
  }

  if ($configuration not-in (get-all-configurations)) {
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

def get-system-hosts [system: string] {
  get-configuration-data
  | where system == $system
  | get host
  | sort
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

  let output = if $current_system_hosts {
    get-system-hosts (get-current-system)
  } else if $systems {
    (get-configuration-data).system
    | uniq
    | sort
  } else if ($system | is-not-empty) {
    validate-system-name $system

    (get-configuration-data)
    | where system == $system
    | get host
  } else if $hosts {
    (get-configuration-data).host
  } else {
    null
  }

  if ($output | is-not-empty) {
    return ($output | to text --no-newline)
  }

  let colors = (get-colors (get-all-configurations) (get-all-systems))
  let configuration_data = (get-configuration-data)

  $configuration_data
  | each {
      |host|

      $"($host.host) (get-colorized-configuration-name $host.system $colors)"
    }
  | flatten
  | sort
  | to text
  | column -t
}
