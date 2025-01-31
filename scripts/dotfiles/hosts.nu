#!/usr/bin/env nu

use ../environment.nu get-project-path

export def is-nixos [] {
  "NixOS" in (uname | get kernel-version)
}

export def get-kernels [] {
  ls configuration/kernels 
  | get name
  | path basename
}

def get-hosts [kernel: string] {
  ls (
    "configuration"
    | path join kernels
    | path join $kernel
    | path join hosts
  ) | get name
  | path basename
}

export def get-available-hosts [--list] {
  if $list {
    get-kernels
    | each {|kernel| get-hosts $kernel}
    | flatten
    | sort
  } else {
    mut hosts = {}

    for kernel in (get-kernels) {
      $hosts = (
        $hosts
        | insert $kernel (get-hosts $kernel)
      )
    }

    $hosts
  }
}
  
export def get-configuration [host?: string, --with-packages-path] {
  let available_hosts = (get-available-hosts)

  if ($host | is-not-empty) and ($host not-in $available_hosts) {
    error make {msg: "Invalid host name."}
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

export def get-available-configurations [] {
  (get-available-hosts --list) ++ (get-kernels)
}

export def get-darwin-configurations [--with-kernel] {
  let hosts = (get-available-hosts | get Darwin)

  if $with_kernel {
    ($hosts | append "darwin")
  } else {
    $hosts
  }
}

export def get-nixos-configurations [--with-kernel] {
  let hosts = (get-available-hosts | get NixOs)

  if $with_kernel {
    ($hosts | append "nixos")
  } else {
    $hosts
  }
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

# View available hosts
export def main [] {
  if (is-nixos) {
    get-available-hosts
    | get NixOS
    | str join "\n"
  } else {
    get-available-hosts
    | get Darwin
    | str join "\n"
  }
}
