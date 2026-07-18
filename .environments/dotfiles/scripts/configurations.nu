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
    | lines
    | parse "{key}={value}"
    | where key == NAME
    | first
    | get value
  } else {
    (uname).kernel-name
  }
  | str lowercase

  if ($system != nixos) {
    "home-manager"
  } else {
    $system
  }
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
  | where {($in | path split | length) == 4}
  | parse "configuration/hosts/{system}/{host}/"
}

export def get-built-host-name [] {
  (uname).nodename
}

# List configurations
export def main [] {
  main hosts
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
  host: record<host: string, system: string>
  --color
] {
  let system = $"($host.system)"

  let system = if $color {
    get-colorized-configuration-name ($host.system) (get-colors)
  } else {
    $host.system
  }

  $"($host.host) ($system)"
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
