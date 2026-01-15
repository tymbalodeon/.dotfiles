#!/usr/bin/env nu

# FIXME: needs to be updated to accomated the hosts/${hostType}/${channel}
# pattern

def get-host-path [host_type: string] {
  $"configuration/hosts/($host_type)"  
}

def append-hosts [
  available_hosts: list<string>
  hosts: list<string>
  all: bool
  include_hosts: bool
] {
  if $include_hosts or $all {
    $hosts
    | append $available_hosts
  } else {
    $hosts
  }
}

def main [
  --darwin
  --home-manager
  --nixos
] {
  let darwin_hosts = (ls --short-names (get-host-path darwin)).name
  let home_manager_hosts = (ls --short-names (get-host-path home-manager)).name
  let nixos_hosts = (ls --short-names (get-host-path nixos)).name

  let all = not ([$darwin $home_manager $nixos] | any {|host_type| $host_type})
  mut hosts = []

  for host_type in [
    {
      available_hosts: $darwin_hosts
      include_hosts: $darwin
    }
    {
      available_hosts: $home_manager_hosts
      include_hosts: $home_manager
    }
    {
      available_hosts: $nixos_hosts
      include_hosts: $nixos
    }
  ] {
    $hosts = (
      append-hosts
        $host_type.available_hosts
        $hosts
        $all
        $host_type.include_hosts
    )
  }

  $hosts
  | sort
  | to text --no-newline
}
