#!/usr/bin/env nu

use ./hosts.nu get-all-hosts
use ./hosts.nu get-all-kernels
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
  $file
  | str contains kernels
}

def matches_hosts [file: string] {
  $file
  | str contains hosts
}

def matches_configuration [file: string configuration: string] {
  $file
  | str contains $configuration
}

# List configuration files
def main [
  configuration?: string # Configuration name
  --all # List files for all configuraitons
  --unique # List files unique to a configuration
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

  let files = (
    if $unique {
      $files
      | filter {|file| $configuration in $file}
    } else {
      if ($configuration | is-empty) {
        if $all {
          $files
        } else {
          $files
          | filter {|file| not ($file | str contains kernels)}
        }
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

      if not $unique and $base != "configuration" {
        $line + $" [($base)]"
      } else {
        $line
      }
    }
  )

  (
    if $all or not $unique {
      let colors = (
        ansi --list
        | get name
        | filter {
            |color|

            $color not-in [reset title identity escape size] and (
             "_" not-in $color 
            # TODO is it possible to programmatically detect which colors will work?
            ) and not ("black" in $color) or (
              "xterm" in $color
            )
          }
      )

      let kernels_and_colors = (
        get-all-kernels
        | zip $colors
      )

      let hosts_and_colors = (
        get-all-hosts --list
        | zip ($colors | drop nth (($kernels_and_colors | length) + 1))
      )

      $files
      | each {
          |line|

          mut line = $line
          mut matched_host = false

          for $host_and_color in $hosts_and_colors {
            if $host_and_color.0 in $line {
              $line = $"(ansi $host_and_color.1)($line)(ansi reset)"
              $matched_host = true

              break
            }
          }

          if not $matched_host {
            for $kernel_and_color in $kernels_and_colors {
              if $kernel_and_color.0 in $line {
                $line = $"(ansi $kernel_and_color.1)($line)(ansi reset)"

                break
              }
            }
          }

          $line
        }
    } else {
      $files
    }
  )
  | str join "\n"
}
