#!/usr/bin/env nu

use color.nu colorize
use color.nu get-colorized-configuration-name
use color.nu get-colors
use ../../default/scripts/print.nu print-error

def get-current-system [] {
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

export def is-linux [] {
  (uname).kernel-name == Linux
}

export def is-home-manager [] {
  (get-current-system) == home-manager
}

export def is-nixos [] {
  (get-current-system) == nixos
}

export def get-all-hosts [] {
  ls --short-names configuration/hosts
  | get name
  | each {|system| get-hosts $system}
  | flatten
  | sort
}

def get-configuration-data [] {
  fd "" configuration/hosts
  | lines
  | where {($in | path split | length) == 5}
  | parse "configuration/hosts/{system}/{channel}/{host}/"
}

export def get-built-host-name [] {
  (uname).nodename
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

def format-host [
  host: record<channel: string, host: string, system: string>
  --color
] {
  let system_and_channel = $"($host.system) \((
    $host.channel
    | str replace _ .
  )\)"

  let system_and_channel = if $color {
    let system = (get-colorized-configuration-name ($host.system) (get-colors))

    let channel_color = if $host.channel == unstable {
      "light_cyan"
    } else {
      "light_yellow"
    }

    let channel = $"(ansi $channel_color)\(($host.channel)\)(ansi reset)"

    $"($system) ($channel)"
  } else {
    $"($host.system) \((
      $host.channel
      | str replace _ .
    )\)"
  }

  $"($host.host) ($system_and_channel)"
}

# List current configuration
export def "main current" [] {
  let host = (
    get-configuration-data
    | where host == (get-built-host-name)
    | first
  )

  format-host $host
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
  get-configuration-data
  | where system == (get-current-system)
  | get host
  | sort
  | to text --no-newline
}

# List hosts
export def "main hosts" [] {
  let configuration_data = (get-configuration-data)

  $configuration_data
  | each {|host| format-host --color $host}
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
