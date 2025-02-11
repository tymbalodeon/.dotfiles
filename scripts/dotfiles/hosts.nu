#!/usr/bin/env nu

export def get-current-system [] {
  open /etc/os-release
  | parse "{key}={value}"
  | where key == NAME
  | first
  | get value
}

export def is-nixos [] {
  (get-current-system) == "NixOS"
}

export def get-all-kernels [] {
  ls --short-names configuration/kernels
  | get name
}

def get-hosts [kernel: string] {
  ls --short-names (
    "configuration"
    | path join kernels
    | path join $kernel
    | path join hosts
  )
  | get name
}

export def get-all-hosts [] {
  get-all-kernels
  | each {|kernel| get-hosts $kernel}
  | flatten
  | sort
}

export def get-all-configurations [] {
  let kernels = (get-all-kernels)

  $kernels
  | append (
      $kernels
    | each {|kernel| get-hosts $kernel}
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
              ls ("**/kernels/darwin/hosts/work/git/.gitconfig" | into glob)
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

def raise_configuration_error [configuration: string --kernels] {
  let available_configurations = if $kernels {
    get-all-kernels
  } else {
    get-all-configurations
  }
  | each {|configuration| $"• ($configuration)"}
  | str join "\n"

  let type = if $kernels {
    "kernel"
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
  --validate-kernel
] {
  if ($configuration | is-empty) {
    return
  }

  if $validate_kernel and ($configuration not-in (get-all-kernels)) {
    raise_configuration_error $configuration --kernels
  }

  if not ($configuration in (get-all-hosts)) and not ($configuration in (get-all-kernels)) {
    raise_configuration_error $configuration
  }
}

# List hosts
export def main [
  kernel?: string # List hosts for $kernel
  --current-platform # List hosts available on the current platform only
] {
  validate-configuration-name $kernel --validate-kernel

  if ($kernel | is-empty) and not $current_platform {
    return (
      get-all-hosts
      | str join "\n"
    )
  }

  mut hosts = {}

  for kernel in (get-all-kernels) {
    $hosts = (
      $hosts
      | insert $kernel (get-hosts $kernel)
    )
  }

  let hosts = (
    if $current_platform {
      $hosts
      | get (get-current-system)
    } else {
      $hosts
      | get $kernel
    }
  )

  $hosts
  | str join "\n"
}
