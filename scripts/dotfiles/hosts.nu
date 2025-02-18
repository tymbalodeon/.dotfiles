#!/usr/bin/env nu

export def get-current-system [] {
  let release_file = "/etc/os-release"

  if ($release_file | path exists) {
    open /etc/os-release
    | parse "{key}={value}"
    | where key == NAME
    | first
    | get value
  } else {
    (uname).kernel-name
  }
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

# List hosts
export def main [
  system?: string # List hosts for $system
  --current-host # View current host
  --current-system # List hosts available on the current platform only
] {
  if $current_host {
    return (get-built-host-name)
  }

  validate-configuration-name $system --validate-system

  if ($system | is-empty) and not $current_system {
    return (
      get-all-hosts
      | str join "\n"
    )
  }

  mut hosts = {}

  for system in (get-all-systems) {
    $hosts = (
      $hosts
      | insert $system (get-hosts $system)
    )
  }

  let hosts = (
    if $current_system {
      $hosts
      | get (get-current-system)
    } else {
      $hosts
      | get $system
    }
  )

  $hosts
  | str join "\n"
}
