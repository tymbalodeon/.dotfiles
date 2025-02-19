#!/usr/bin/env nu

use ./color.nu colorize
use ./diff.nu get-file-path
use ./diff.nu colorize-file
use ./hosts.nu get-all-configurations
use ./hosts.nu get-all-hosts
use ./hosts.nu get-all-systems
use ./hosts.nu get-hosts
use ./hosts.nu validate-configuration-name

def --wrapped eza [...$args: string] {
  ^eza ...$args
}

def matches_system_name [file: string system_name?: string] {
  if ($system_name | is-empty) {
    false
  } else {
    $file
    | str contains $system_name
  }
}

def matches_systems [file: string] {
  $file
  | str contains systems
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
    $text == "Host" and $configuration in (get-all-systems)
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
        # `delta` seems able to do this--use that as an example!
        ) and not ("black" in $color) and not ("purple" in $color) or (
          "xterm" in $color
        )
      }
    | sort-by {|a, b| "light" in $a}
    | take (get-all-configurations | length)
  )

  get-all-configurations
  | wrap configuration
  | merge ($colors | wrap name)
}

def get-file-color [
  file: string
  colors: table<configuration: string, name: string>
  unique: bool
  configuration?: string
] {
  let hosts = (get-all-hosts)

  let color = (
    $colors
    | filter {
        |color|

        $color.configuration in $file and $color.configuration in $hosts
      }
  )

  let color = if ($color | is-empty) {
    let systems = (get-all-systems)

    $colors
    | filter {
        |color|

        $color.configuration in $file and $color.configuration in $systems
      }
  } else {
    $color
  }

  if ($color | is-empty) {
    return "default"
  }

  let color = ($color | first)

  $color.name
}

def colorize-files [
  files: list<string>
  colors: table<configuration: string, name: string>
  unique: bool
  configuration?: string
] {
  $files
  | each {
      |file|

      colorize $file (get-file-color $file $colors $unique $configuration)
    }
}

def get-configuration-name [file: string configuration_type: string] {
  try {
    $file
    | rg $"($configuration_type)s/\([^/]+\)/" --only-matching --replace "$1"
  }
}

def get-colorized-configuration-name [
  configuration_name: string
  colors: table<configuration: string, name: string>
] {
  let color = (
    $colors
    | filter {
        |color|

        $color.configuration == $configuration_name
      }
    | first
    | get name
  )

  colorize $configuration_name $color
}

def colorize-configuration-name [
  file: string
  configuration_type: string
  colors: table<configuration: string, name: string>
] {
  let configuration_name = (
    get-configuration-name $file $configuration_type
  )

  if ($configuration_name | is-empty) {
    return null
  }

  get-colorized-configuration-name $configuration_name $colors
}

def strip-configuration-name [configuration: string] {
  $configuration
  | ansi strip
  | str replace --all --regex '(\[|\])' ""
}

# List configuration files
def main [
  configuration?: string # Configuration (system or host) name
  --group-by-configuration # List configuration files sorted by configuration
  --group-by-file # List configuration files sorted by file
  --color = "auto" # When to use colored output
  --no-full-path # When --group-by-file, don't use the full path
  --no-labels # Don't show labels in output
  --shared # List only shared configuration files
  --tree # View file tree for $configuration
  --unique # List files unique to $configuration
  --unique-filenames # List unique filenames for $configuration
] {
  validate-configuration-name $configuration

  let use_colors = (
    $color == "always" or (
      $color != "never"
    ) and (
      is-terminal --stdout
    )
  )

  if $tree {
    try {
      let configuration_directory = if (
        $configuration | is-empty
      ) or not $unique {
        "configuration"
      } else {
        ($"configuration/**/($configuration)" | into glob)
      }

      let color = if $use_colors {
        "always"
      } else {
        "never"
      }

      let ignore_glob = if ($configuration | is-empty) {
        null
      } else {
        let systems = (get-all-systems)
        let hosts = (get-all-hosts)

        if ($configuration in $systems) {
          $systems
          | where $it != $configuration
          | str join "|"
        } else if ($configuration in $hosts) {
          $hosts
          | where $it != $configuration
          | append (
            $systems
            | filter {
                |system|

                $configuration not-in (get-hosts $system)
              }
            )
          | str join "|"
        } else {
          null
        }
      }

      let args = [
        --all
        --color $color
        --tree $configuration_directory
        err> /dev/null
      ]

      let args = if ($ignore_glob | is-not-empty) {
        $args
        | append [--ignore-glob $ignore_glob]
        | flatten
      } else {
        $args
      }

      return (eza ...$args)
    } catch {
      return
    }
  }

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
          | filter {|file| not ($file | str contains systems)}
        }
      } else {
        let configuration_is_system_name = (
          $configuration in (ls --short-names configuration/systems).name
        )

        let configuration_is_host_name = (
          $configuration in (ls --short-names configuration/**/hosts/**).name
        )

        let system_name = (
          ls ($"configuration/**/($configuration)" | into glob)
          | get name
          | split row "systems/"
          | last
          | path split
          | first
        )

        $files
        | filter {
            |file|

            $configuration_is_system_name and not $shared and (
              matches_system_name $file $system_name
            ) or (matches_configuration $file $configuration) and not (
              matches_hosts $file
            ) or not (matches_systems $file) or (
              $configuration_is_host_name
            ) and (matches_configuration $file $configuration) or not (
              matches_hosts $file
            ) and (matches_system_name $file $system_name)
          }
      }
    }
  )

  let is_system_configuration = ($configuration in (get-all-systems))
  let is_host_configuration = ($configuration in (get-all-hosts))
  let colors = (get-colors)

  let files = if $group_by_file or $unique_filenames {
    let files = (
      $files
      | par-each {
          |file|

          let file_path = if $group_by_file and $no_labels or not $no_full_path {
            $file
          } else {
            get-file-path $file
          }

          if $no_labels {
            return $file
          }

          let system = if not $use_colors or $unique_filenames {
            get-configuration-name $file "system"
          } else {
            colorize-configuration-name $file "system" $colors
          }

          let host = if not $use_colors or $unique_filenames {
            get-configuration-name $file "host"
          } else {
            colorize-configuration-name $file "host" $colors
          }

          let file_color = (
            get-file-color $file $colors $unique $configuration
          )

          let file = if $use_colors and $unique_filenames {
            colorize $file_path $file_color
          } else {
            $file_path
          }

          $file
          | append (
              if ($host | is-not-empty) and ($system | is-not-empty) {
                $"($system) ($host)"
              } else if ($system | is-not-empty) {
                $system
              } else {
                ""
              }
            )
          | str join " "
          | str trim
        }
    )

    let all_configurations = (get-all-configurations)

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

        let configurations = (
          $all_configurations
          | each {
              |configuration|

              if $configuration in $configurations {
                $configuration
              } else {
                $"[($configuration)]"
              }
          }
        )

        if $filename in ($filenames | columns) {
          let existing_configurations = (
            $filenames
            | get $filename
          )

          let updated_configurations = (
            $existing_configurations
            | append (
                $configurations
                | filter {
                    |configuration|

                    $configuration not-in $existing_configurations
                  }
              )
          )

          $filenames = (
            $filenames
            | update $filename (
                $updated_configurations
                | filter {
                    |configuration|

                    not ($configuration | str starts-with "[") or (
                      (strip-configuration-name $configuration) not-in (
                        $updated_configurations
                        | ansi strip
                      )
                    )
                }
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
          | sort-by --custom {
              |a, b|

              let a = (strip-configuration-name $a)
              let b = (strip-configuration-name $b)

              $a < $b
            }
          | str replace --regex '\[.+\]' "•"
          | str join " "
        )
        | str join " "
        | str trim
      }
    } else {
      let files = (
        $files
        | sort-by --custom {
            |a, b|

            let a = ($a | ansi strip)
            let b = ($b | ansi strip)

            if $unique_filenames or not $group_by_configuration {
              if $group_by_file and not $no_full_path {
                return (
                  (get-file-path $a) < (get-file-path $b)
                )
              } else {
                return ($a < $b)
              }
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
      )

      if (
        $group_by_file and (
          not $no_full_path or $no_labels and $use_colors
        )
      ) {
        $files
        | each {
            |file|

            colorize-file $file default_bold
        }
      } else {
        $files
      }
    }
  } else if $group_by_configuration {
    let shared_files = (
      $files
      | filter {|file| "systems" not-in $file}
    )

    let shared_system_files = (
      $files
      | filter {|file| "systems" in $file and "hosts" not-in $file}
    )

    let shared_system_files = if $use_colors and (
      $configuration | is-empty
    ) {
      colorize-files $shared_system_files $colors $unique $configuration
    } else {
      $shared_system_files
    }

    let shared_host_files = (
      $files
      | filter {|file| "hosts" in $file}
    )

    let shared_host_files = if $use_colors and (
      ($configuration | is-empty) or $is_system_configuration
    ) {
      colorize-files $shared_host_files $colors $unique $configuration
    } else {
      $shared_host_files
    }

    let files = (
      [$shared_files $shared_system_files $shared_host_files]
      | filter {
          |files|

          $files
          | is-not-empty
        }
    )

    $files
    | enumerate
    | each {
        |configuration_files|

        let index = $configuration_files.index
        let configuration_files = ($configuration_files.item | to text)

        if not $no_labels and ($files | length) > 1 {
          let configuration_type = if "hosts" in $configuration_files {
            "Host"
          } else if "system" in $configuration_files {
            "System"
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
        } else if $index > 0 {
          $configuration_files
          | prepend "---"
          | str join "\n"
        } else {
          $configuration_files
        }
    }
  } else if $use_colors and (
    not $group_by_configuration and not (
      $unique and $is_host_configuration
    ) or (
      $configuration | is-empty
    ) and not $is_host_configuration and (
      not $shared and $is_system_configuration or not $unique
    )
  ) {
    colorize-files $files $colors $unique $configuration
  } else {
    $files
  }

  if $group_by_file or $unique_filenames {
    let files = (
      $files
      | to text
      | column -t
    )

    if $unique_filenames {
      let all_configurations = (get-all-configurations)

      $files
      | lines
      | each {
          |file|

          let parts = (
            $file
            | split row " "
          )

          let file = ($parts | first)

          let configurations = (
            $parts
            | drop nth 0
            | each {
                |configuration|

                if $configuration in $all_configurations {
                  get-colorized-configuration-name $configuration $colors
                } else {
                  $configuration
                }
            }
          )

          $file
          | append $configurations
          | str join " "
        }
      | str join "\n"
      | str replace --all "•" " "
    } else {
      $files
    }
  } else if $no_labels and $group_by_configuration {
    $files
    | str join
  } else {
    $files
    | str join "\n"
  }
}
