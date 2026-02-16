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

export def is-darwin [] {
  (get-current-system) == darwin
}

export def is-home-manager [] {
  (get-current-system) == home-manager
}

export def is-nixos [] {
  (get-current-system) == nixos
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
export def main [] {
  main hosts
}

# List channels
export def "main channels" [] {
  get-configuration-data
  | get channel
  | uniq
  | str replace _ .
  | sort
  | to text --no-newline
}

# List darwin hosts
export def "main darwin" [] {
  get-configuration-data
  | where system == darwin
  | get host
  | to text --no-newline
}

# List home-manager hosts
export def "main home-manager" [] {
  get-configuration-data
  | where system == home-manager
  | get host
  | to text --no-newline
}

# List nixos hosts
export def "main nixos" [] {
  get-configuration-data
  | where system == nixos
  | get host
  | to text --no-newline
}

def colorize-host [
  colors: table<configuration: string, name: string>
  host: record<channel: string, host: string, system: string>
] {
  let system_and_channel = $"($host.system) \((
    $host.channel
    | str replace _ .
  )\)"

  let system_and_channel = (
    get-colorized-configuration-name ($system_and_channel) $colors
  )

  $"($host.host) ($system_and_channel)"
}

# List current configuration
export def "main current" [] {
  let colors = (get-colors (get-all-configurations) (get-all-systems))

  let host = (
    get-configuration-data
    | where host == (get-built-host-name)
    | first
  )

  colorize-host $colors $host
}

# List current channel
export def "main current channel" [] {
  get-configuration-data
  | where host == (get-built-host-name)
  | first
  | get channel
}

# List current host
export def "main current host" [] {
  get-built-host-name
}

# List current system
export def "main current system" [] {
  get-current-system 
}

# List hosts for current system
export def "main current system hosts" [] {
  get-system-hosts (get-current-system)
  | to text --no-newline
}

# List hosts
export def "main hosts" [] {
  let colors = (get-colors (get-all-configurations) (get-all-systems))
  let configuration_data = (get-configuration-data)

  $configuration_data
  | each {|host| colorize-host $colors $host}
  | flatten
  | sort
  | to text
  | column -t
}

# List systems
export def "main systems" [] {
  get-configuration-data
  | get system
  | uniq
  | sort
  | to text --no-newline
}
