#!/usr/bin/env nu

export def is-nixos [] {
  (uname | get kernel-version) == "NixOS"
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
  
export def get-configuration [host?: string, --with-packages-path] {
  let available_hosts = (get-all-hosts)

  if ($host | is-not-empty) and ($host not-in $available_hosts) {
    error make --unspanned { msg: "Invalid host name." }
  }

  let kernel = (uname).kernel-name

  let base_configurations = {
    darwin: "darwinConfigurations",
    NixOS: "nixosConfigurations"
  }

  let base = if ($host | is-empty) {
    $base_configurations
    | get $kernel
  } else {
    if $host in ($available_hosts | get darwin) {
      $base_configurations
      | get darwin
    } else if $host in ($available_hosts | get NixOS) {
      $base_configurations
      | get NixOS
    } 
  }

  let host = if ($host | is-empty) {
    if $kernel == "darwin" {
      (whoami)
    } else {
      cat /etc/hostname
      | str trim
    }
  } else {
    $host
  }

  let paths = {
    darwin: ".config.home.packages",
    NixOS: ".config.home-manager.users.benrosen.home.packages"
  }

  let packages_path = if $with_packages_path {
    if ($host | is-empty) {
      $paths
      | get $kernel
    } else {
      if $host in ($available_hosts | get darwin) {
        $paths | get darwin
      } else if $host in ($available_hosts | get NixOS) {
        $paths | get NixOS
      } 
    }
  } else {
    ""
  }

  $"./configuration#($base).($host)($packages_path)"
}

export def get-built-host-name [] {
  if (is-nixos) {
    cat /etc/hostname
    | str trim
  } else {
    if (
      rg
        (git config user.email)
        configuration/kernels/darwin/hosts/work/.gitconfig
      | is-not-empty
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
  --all # List all hosts
] {
  validate-configuration-name $kernel --validate-kernel

  mut hosts = {}

  for kernel in (get-all-kernels) {
    $hosts = (
      $hosts
      | insert $kernel (get-hosts $kernel)
    )
  }

  if ($kernel | is-empty) {
    let kernel = ((uname).kernel-name | str downcase)

    let available_hosts = (
      $hosts
      | get $kernel
    )

    if $all {
      let other_hosts = (
        $hosts
        | reject $kernel
        | each {|kernel| $kernel | values}
        | flatten
      )

      $available_hosts
      | append $other_hosts
      | sort
    } else {
      $available_hosts    
    }
  } else {
    $hosts
    | get $kernel
  }
  | str join "\n"
}
