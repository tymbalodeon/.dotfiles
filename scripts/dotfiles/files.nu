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

def get-header [text: string configuration?: string] {
  let header = $text

  if ($configuration | is-empty) or (
    $text == "Host" and $configuration in (get-all-kernels)
  ) {
    $"($text)s"
  } else {
    $text
  }
}

# List configuration files
def main [
  configuration?: string # Configuration name
  --no-colors # Don't colorize output
  --no-headers # Don't show headers in output
  --shared # List only shared configuration files
  --sort-by-configuration # List configuration files sorted by configuration
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
    if $unique and ($configuration | is-not-empty) {
      $files
      | filter {|file| $configuration in $file}
    } else {
      if ($configuration | is-empty) {
        if not $shared {
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

        let kernel_name = (
          ls ($"configuration/**/($configuration)" | into glob)
          | get name
          | split row "kernels/"
          | last
          | path split
          | first
        )
    
        $files
        | filter {
            |file|

            $configuration_is_kernel_name and not $shared and (
              matches_kernel_name $file $kernel_name
            ) or (matches_configuration $file $configuration) and not (
              matches_hosts $file
            ) or not (matches_kernels $file) or (
              $configuration_is_host_name
            ) and (matches_configuration $file $configuration) or not (
              matches_hosts $file
            ) and (matches_kernel_name $file $kernel_name)
          }
      }
    }
  )

  let is_kernel_configuration = ($configuration in (get-all-kernels))
  let is_host_configuration = ($configuration in (get-all-hosts))

  let files = (
    if not $is_host_configuration and not (
      $no_colors
    ) and not $sort_by_configuration or (
      $configuration | is-empty
    ) and (
      not $shared and $is_kernel_configuration or not $unique
    ) {
      let colors = (
        ansi --list
        | get name
        | filter {
            |color|

            $color not-in [reset title identity escape size] and (
             "_" not-in $color 
            # TODO is it possible to programmatically detect which colors will work?
            ) and not ("black" in $color) and not ("purple" in $color) or (
              "xterm" in $color
            )
          }
      )

      let kernels_and_colors = (
        get-all-kernels
        | zip $colors
      )

      let hosts_and_colors = (
        get-all-hosts
        | zip ($colors | drop nth 0..(($kernels_and_colors | length) - 1))
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

          if not $matched_host and (($configuration | is-empty) or not $unique) {
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

  let files = if $sort_by_configuration and (
    not $is_host_configuration
  ) {
    let shared_files = (
      $files
      | filter {|file| "kernels" not-in $file}
    )

    let shared_kernel_files = (
      $files
      | filter {|file| "kernels" in $file and "hosts" not-in $file}
    )

    let shared_kernel_files = (
      let kernel_header = (get-header "Kernel" $configuration);

      if not $no_headers {
        $shared_kernel_files
        | prepend [$"($kernel_header):"]
      } else {
        $shared_kernel_files
      }
    )

    let shared_host_files = (
      $files
      | filter {|file| "hosts" in $file}
    )

    let shared_host_files = (
      let host_header = (get-header "Host" $configuration);

      if not $no_headers {
        $shared_host_files
        | prepend [$"($host_header):"]
      } else {
        $shared_host_files
      }
    )

    let kernel_and_host_files = (
      $shared_kernel_files
      | to text
      | append $shared_host_files
    )

    if ($shared_files | is-empty) {
      $kernel_and_host_files
    } else {
      $shared_files
      | to text
      | append $kernel_and_host_files
    }
  } else {
    $files
  }

  $files
  | str join "\n"
}
