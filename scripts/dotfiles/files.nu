#!/usr/bin/env nu

use ./hosts.nu get-all-hosts
use ./hosts.nu validate-configuration-name

def matches_kernel_name [file: string kernel_name?: string] {
  if ($kernel_name | is-empty) {
    false
  } else {
    $file
    | str contains $kernel_name
  }
}

def matches_kernels [file: string] {
  $file | str contains kernels
}

def matches_hosts [file: string] {
  $file | str contains hosts
}

def matches_configuration [file: string configuration: string] {
  $file | str contains $configuration
}

def format-files [
  files: list<string>
  unique: bool
  configuration?: string
] {
  let files = (
    $files
    | each {
        |line|

        let directories = (
          $line
          | str replace (realpath . | path dirname) ""
          | path split
        )

        let $base = if "hosts" in $directories {
          $directories
          | get 4
        } else if "kernels" in $directories {
          $directories
          | get 2
        } else {
          "configuration"
        }

        let line = (
          $line
          | str replace $"configuration/" ""
        )

        if $base == "configuration" {
          $line
        } else {
          $line + $" [($base)/]"
        }
    }
  )

  let hosts = (get-all-hosts --list)
  let include_shared = not $unique

  $files
  | sort
  | each {
      |line|

      if "[" in $line {
        let file_configuration = if "bumbirich" in $line {
          "bumbirich"
        } else if "ruzia" in $line {
          "ruzia"
        } else (
          $line
          | rg '\[.+\]' --only-matching
          | str replace "[" ""
          | str replace "]" ""
          | split row "/"
          | filter {|directory| not ($directory | is-empty)}
          | last
        )

        let color = if $include_shared or $unique {
          let $configuration = if ($configuration | is-empty) {
            ""
          } else {
            $configuration
          }

          let is_darwin_configuration = ($configuration in $darwin_hosts)
          let is_nixos_configuration = ($configuration in $nixos_hosts)
          let is_host_configuration = ($configuration in $hosts)

          let host_color = if $is_host_configuration {
            "n"
          } else {
            "ub"
          }

          let darwin_color = if $is_darwin_configuration {
            "n"
          } else {
            "pb"
          }

          let nixos_color = if $is_nixos_configuration {
            "n"
          } else {
            "ub"
          }

          let darwin_host_color = if $is_darwin_configuration {
            $host_color
          } else {
            "yb"
          }

          let nixos_host_color = if $is_nixos_configuration {
            $host_color
          } else {
            "cb"
          }

          try {
            {
              "benrosen": $darwin_host_color
              "bumbirich": $nixos_host_color
              "darwin": $darwin_color
              "nixos": $nixos_color
              "ruzia": $nixos_host_color
              "work": $darwin_host_color
            } | get $file_configuration
          } catch {
            "n"
          }
        } else {
          mut color = "n"

          for host in $hosts {
            if $host in $line {
              $color = "cb"

              break
            }
          }

          $color
        }

        $"(ansi $color)($line)(ansi reset)"
      } else {
        $line
      }
    }
  | str join "\n"
}

# List configuration files
def main [
  configuration?: string # Configuration name
  --unique # View only files unique to a configuration
] {
  validate-configuration-name $configuration

  let files = (
    fd
      --exclude "flake.lock"
      --hidden
      --type "file"
      ""
      "configuration"
    | lines
  )

  let files = if $unique {
    $files
    | filter {|file| $configuration in $file}
  } else {
    if ($configuration | is-empty) {
      $files
      | filter {|file| not ($file | str contains kernels)}
      | str join "\n"
    } else {
      let configuration_is_kernel_name = (
        $configuration in (ls --short-names configuration/kernels).name
      )

      let configuration_is_host_name = (
        $configuration in (ls --short-names configuration/**/hosts/**).name
      )

      let kernel_name = if $configuration_is_host_name {
        ls ($"configuration/**/($configuration)" | into glob)
        | get name
        | split row "kernels/"
        | last
        | path split
        | first
      } else {
        null
      }
    
      $files
      | filter {
          |file|

          $configuration_is_kernel_name and (
            matches_configuration $file $configuration
          ) and not (matches_hosts $file) or not (
            matches_kernels $file
          ) or $configuration_is_host_name and (
            matches_configuration $file $configuration
          ) or not (matches_hosts $file) and (
            matches_kernel_name $file $kernel_name
          )
        }
    }
  }

  format-files $files $unique $configuration
}
