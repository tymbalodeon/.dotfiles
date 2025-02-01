#!/usr/bin/env nu

use ../environment.nu get-project-path

export def is-nixos [] {
  "NixOS" in (uname | get kernel-version)
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

export def get-all-hosts [--list] {
  if $list {
    get-all-kernels
    | each {|kernel| get-hosts $kernel}
    | flatten
    | sort
  } else {
    mut hosts = {}

    for kernel in (get-all-kernels) {
      $hosts = (
        $hosts
        | insert $kernel (get-hosts $kernel)
      )
    }

    $hosts
  }
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
    Darwin: "darwinConfigurations",
    NixOS: "nixosConfigurations"
  }

  let base = if ($host | is-empty) {
    $base_configurations
    | get $kernel
  } else {
    if $host in ($available_hosts | get Darwin) {
      $base_configurations
      | get Darwin
    } else if $host in ($available_hosts | get NixOS) {
      $base_configurations
      | get NixOS
    } 
  }

  let host = if ($host | is-empty) {
    if $kernel == "Darwin" {
      (whoami)
    } else {
      cat /etc/hostname
      | str trim
    }
  } else {
    $host
  }

  let paths = {
    Darwin: ".config.home.packages",
    NixOS: ".config.home-manager.users.benrosen.home.packages"
  }

  let packages_path = if $with_packages_path {
    if ($host | is-empty) {
      $paths
      | get $kernel
    } else {
      if $host in ($available_hosts | get Darwin) {
        $paths | get Darwin
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
        (get-project-path configuration/kernels/darwin/hosts/work/.gitconfig)
      | is-not-empty
    ) {
      "work"
    } else {
      whoami
    }
  }
}

export def validate-configuration-name [configuration?: string] {
  if ($configuration | is-not-empty) and not (
    $configuration in (get-all-hosts --list)
  ) and not ($configuration in (get-all-kernels)) {
    let available_configurations = (
      get-all-configurations
      | each {|configuration| $"• ($configuration)"}
      | str join "\n"
    )

    error make --unspanned {
      msg: $"unrecognized configuration name '($configuration)'

Available configurations:
($available_configurations)"
    }
  }
}

# FIXME
# View available hosts
export def main [] {
  let kernel = ((uname).kernel-name | str downcase)
  let hosts = (get-all-hosts)

  let available_hosts = (
    $hosts
    | get $kernel
    | str join "\n"
  )

  let other_hosts = (
    $hosts
    | reject $kernel
    | each {|kernel| $kernel | values}
    | flatten
    | str join "\n"
  )

  print $available_hosts
  # print $other_hosts
}
