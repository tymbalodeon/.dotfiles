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

def get-header [text?: string configuration?: string] {
  if ($text | is-empty) {
    return null
  }

  let header = $text

  if ($configuration | is-empty) or (
    $text == "Host" and $configuration in (get-all-kernels)
  ) {
    $"($text)s"
  } else {
    $text
  }
}

def get-colors [] {
  let colors = (
    ansi --list
    | get name
    | filter {
        |color|

        $color not-in [reset title identity escape size] and not (
          [_bold _underline _italic _dimmed _reverse bg_]
          | each {|name| $name in $color}
          | any {|color| $color}
        # TODO is it possible to programmatically detect which colors will work?
        ) and not ("black" in $color) and not ("purple" in $color) or (
          "xterm" in $color
        )
      }
    | sort-by {|a, b| "light" in $a}
    | take (get-all-kernels | append (get-all-hosts) | length)
  )

  let kernel_colors = (
    get-all-kernels
    | wrap kernel
    | merge ($colors | wrap color)
  )

  {
    kernel_colors: $kernel_colors

    host_colors: (
      get-all-hosts
      | wrap host
      | merge (
          $colors
          | drop nth 0..(($kernel_colors | length) - 1)
          | wrap color
        )
    )
  }
}

def colorize-files [
  files: list<string>
  colors: record<
    kernel_colors: list<record<kernel: string, color: string>>,
    host_colors: list<record<host: string, color: string>>,
  >
  unique: bool
  configuration?: string
] {
  $files
  | each {
      |line|

      mut line = $line
      mut matched_host = false

      for $host_and_color in $colors.host_colors {
        if $host_and_color.host in $line {
          $line = $"(ansi $host_and_color.color)($line)(ansi reset)"
          $matched_host = true

          break
        }
      }

      if not $matched_host and (($configuration | is-empty) or not $unique) {
        for $kernel_and_color in $colors.kernel_colors {
          if $kernel_and_color.kernel in $line {
            $line = $"(ansi $kernel_and_color.color)($line)(ansi reset)"

            break
          }
        }
      }

      $line
    }
}

def get-configuration-name [
  file: string
  configuration_type: string
  colors: record<
    kernel_colors: table<kernel: string, color: string>,
    host_colors: table<host: string, color: string>
  >
] {
  try {
    let configuration_name = (
      $file
      | rg $"($configuration_type)s/\([^/]+\)/" --only-matching --replace "$1"
    )

    let color = (
      $colors
      | get $"($configuration_type)_colors"
      | filter {
          |color|

          ($color | get $configuration_type) == $configuration_name
        }
      | first
      | get color
    )

    $"[(ansi $color)($configuration_name)(ansi reset)]"
  } catch {
    null
  }
}

# List configuration files
def main [
  configuration?: string # Configuration name
  --no-colors # Don't colorize output
  --no-headers # Don't show headers in output
  --shared # List only shared configuration files
  --sort-by-configuration # List configuration files sorted by configuration
  --sort-by-file # List configuration files sorted by file
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
  let colors = (get-colors)

  let files = if $sort_by_file {
    return (
      $files
      | each {
          |file|

          let kernel = (get-configuration-name $file "kernel" $colors)
          let host = (get-configuration-name $file "host" $colors)

          let file_path = (
            $file
            | path split
            | filter {
                |path|

                $path not-in (
                  [configuration kernels hosts] ++ (
                    get-all-kernels
                  ) ++ (get-all-hosts)
                )
              }
            | path join
          )

          # $file_path
          # | wrap file
          # | merge ($kernel | wrap kernel)
          # | merge ($host | wrap host)
          $file_path
          | append (
              if ($host | is-not-empty) and ($kernel | is-not-empty) {
                $"($kernel)/($host)"
              } else if ($kernel | is-not-empty) {
                $kernel
              } else {
                ""
              }
            )
          | str join " "
        }
      | sort-by --custom {|a, b| ($a | ansi strip) < ($b | ansi strip)}
      | to text
      # | sort-by file
      # | table --index false
    )
  } else if $sort_by_configuration {
    let shared_files = (
      $files
      | filter {|file| "kernels" not-in $file}
    )

    let shared_kernel_files = (
      $files
      | filter {|file| "kernels" in $file and "hosts" not-in $file}
    )

    let shared_kernel_files = if not $no_colors and (
      $configuration | is-empty
    ) {
      colorize-files $shared_kernel_files $colors $unique $configuration
    } else {
      $shared_kernel_files
    }

    let shared_host_files = (
      $files
      | filter {|file| "hosts" in $file}
    )

    let shared_host_files = if not $no_colors and (
      $configuration | is-empty
    ) or $is_kernel_configuration {
      colorize-files $shared_host_files $colors $unique $configuration
    } else {
      $shared_host_files
    }

    let files = (
      [$shared_files $shared_kernel_files $shared_host_files]
      | filter {
          |files|

          $files
          | is-not-empty
        }
    )

    $files
    | each {
        |configuration_files|

        let configuration_files = ($configuration_files | to text)

        if not $no_headers and ($files | length) > 1 {
          let configuration_type = if "hosts" in $configuration_files {
            "Host"
          } else if "kernel" in $configuration_files {
            "Kernel"
          } else {
            null
          }

          let header = (
            get-header $configuration_type $configuration
          )

          if ($header | is-not-empty) {
            $configuration_files 
            | prepend [$"($header):"]
            | str join "\n"
          } else {
            $configuration_files
          }
        } else {
          $configuration_files
        }
    }
    | str join "\n"
  } else if not $no_colors and (not $sort_by_configuration and not (
    $unique and $is_host_configuration
  ) or (
    $configuration | is-empty
  ) and not $is_host_configuration and (
    not $shared and $is_kernel_configuration or not $unique
  )) {
    colorize-files $files $colors $unique $configuration
  } else {
    $files
  }

  $files
  | str join "\n"
}
