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

def get-file-color [
  file: string
  colors: record<
    kernel_colors: list<record<kernel: string, color: string>>,
    host_colors: list<record<host: string, color: string>>,
  >
  unique: bool
  configuration?: string
] {
  for $host_and_color in $colors.host_colors {
    if $host_and_color.host in $file {
      return $host_and_color.color
    }
  }

  for $kernel_and_color in $colors.kernel_colors {
    if $kernel_and_color.kernel in $file {
      return $kernel_and_color.color
    }
  }

  "default"
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
      |file|

      let color = (get-file-color $file $colors $unique $configuration)

      $"(ansi $color)($file)(ansi reset)"
    }
}

def get-configuration-name [file: string configuration_type: string] {
  try {
    $file
    | rg $"($configuration_type)s/\([^/]+\)/" --only-matching --replace "$1"
  }
}

def colorize-configuration-name [
  file: string
  configuration_type: string
  colors: record<
    kernel_colors: table<kernel: string, color: string>,
    host_colors: table<host: string, color: string>
  >
] {
  let configuration_name = (
    get-configuration-name $file $configuration_type
  )

  if ($configuration_name | is-empty) {
    return null
  }

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

  let configuration_name = (
    $"(ansi $color)($configuration_name)(ansi reset)"
  )

  $configuration_name
}

# List configuration files
def main [
  configuration?: string # Configuration name
  --group-by-configuration # List configuration files sorted by configuration
  --group-by-file # List configuration files sorted by file
  --no-colors # Don't colorize output
  --no-labels # Don't show labels in output
  --shared # List only shared configuration files
  --tree # View file tree for $configuration
  --unique # List files unique to $configuration
  --unique-filenames # List unique filenames for $configuration
] {
  if $tree {
    try {
      let configuration = if ($configuration | is-empty) {
        "configuration"
      } else {
        ($"configuration/**/($configuration)" | into glob)
      }

      return (
        eza
          --all
          --color always
          --tree $configuration
          err> /dev/null
      )
    } catch {
      return
    }
  }

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
      let files = (
        $files
        | filter {|file| $configuration in $file}
      )

      if $shared {
        $files
        | filter {|file| "hosts" not-in $file}
      } else {
        $files
      }
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

  let files = if $group_by_file or $unique_filenames {
    let files = (
      $files
      | each {
          |file|

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

          let kernel = if not $no_colors {
            colorize-configuration-name $file "kernel" $colors
          } else {
            get-configuration-name $file "kernel"
          }

          let host = if not $no_colors {
            colorize-configuration-name $file "host" $colors
          } else {
            get-configuration-name $file "host"
          }

          let file_color = (
            get-file-color $file $colors $unique $configuration
          )

          let file = if not $no_colors and not $unique_filenames {
            $"(ansi $file_color)($file_path)(ansi reset)"
          } else {
            $file_path
          }

          $file
          | append (
              if ($host | is-not-empty) and ($kernel | is-not-empty) {
                $"($kernel) ($host)"
              } else if ($kernel | is-not-empty) {
                $kernel
              } else {
                ""
              }
            )
          | str join " "
          | str trim
        }
    )

    if $unique_filenames {
      mut filenames = {}

      for file in $files {
        let split = (
          $file
          | split row " "
        )

        let filename = (
          $split
          | first
        )

        let configurations = (
          $split
          | drop nth 0
        )

        if $filename in ($filenames | columns) {
          $filenames = (
            $filenames
            | update $filename (
                $filenames
                | get $filename
                | append $configurations
                | flatten
              )
          )
        } else {
          $filenames = (
            $filenames
            | insert $filename $configurations
          )
        }
      }

    $filenames
    | transpose filename configurations
    | each {
        |file|

        $file.filename
        | append (
          $file.configurations
          | uniq
          | sort-by --custom {|a, b| ($a | ansi strip) < ($b | ansi strip)}
          | str join " "
        )
        | str join " "
        | str trim
      }
    } else {
      $files
      | sort-by --custom {
          |a, b|

          let a = ($a | ansi strip)
          let b = ($b | ansi strip)

          if $unique_filenames or not $group_by_configuration {
            return ($a < $b)
          }

          let a_parts = ($a | split row " ")
          let b_parts = ($b | split row " ")
          let a_parts_length = ($a_parts | length)
          let b_parts_length = ($b_parts | length)

          if ([$a_parts_length $b_parts_length] | all {$in > 2}) {
            $a_parts.2 < $b_parts.2
          } else if ([$a_parts_length $b_parts_length] | all {$in > 1}) {
            $a_parts.1 < $b_parts.1
          }

          if not (
            [$a_parts_length $b_parts_length]
            | any {$in > 1}
          ) {
            $a < $b
          } else if $a_parts_length == 1 and $b_parts_length > 1 {
            true
          } else if $b_parts_length == 1 and $a_parts_length > 1 {
            false
          } else if $a_parts.1 == $b_parts.1 {
             if ([$a_parts_length $b_parts_length] | all {$in == 3}) {
              $a_parts.2 < $b_parts.2
            } else {
              $a_parts_length < $b_parts_length
            }
          } else {
            $a_parts.1 < $b_parts.1
          }
        }
    }
  } else if $group_by_configuration {
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

        if not no_labels and ($files | length) > 1 {
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
  } else if not $no_colors and (
    not $group_by_configuration and not (
      $unique and $is_host_configuration
    ) or (
      $configuration | is-empty
    ) and not $is_host_configuration and (
      not $shared and $is_kernel_configuration or not $unique
    )
  ) {
    colorize-files $files $colors $unique $configuration
  } else {
    $files
  }

  if $group_by_file or $unique_filenames {
    $files
    | to text
    | column -t
  } else {
    $files
    | str join "\n"
  }
}
