#!/usr/bin/env nu

use ./color.nu colorize
use ./color.nu colorize-file
use ./color.nu get-colorized-configuration-name
use ./color.nu get-colors
use ./configurations.nu get-all-configurations
use ./configurations.nu get-all-hosts
use ./configurations.nu get-all-systems
use ./configurations.nu get-configuration-data
use ./configurations.nu get-file-path
use ./configurations.nu get-hosts
use ./configurations.nu validate-configuration-name

export def get-tree-ignore-glob [
  configuration_data: record<
    systems: list<string>,
    hosts: list<string>,
    system_hosts: record
  >
  shared: bool
  configuration?: string
] {
  if ($configuration | is-empty) {
    if $shared {
      "hosts|systems"
    } else {
      null
    }
  } else {
    if ($configuration in $configuration_data.systems) {
      if $shared {
        [hosts]
      } else {
        []
      } | append (
          $configuration_data.systems
          | where $it != $configuration
        )
      | str join "|"
    } else if ($configuration in $configuration_data.hosts) {
      $configuration_data.hosts
      | where $it != $configuration
      | append (
          $configuration_data.systems
          | filter {
              |system|

              $configuration not-in (
                $configuration_data.system_hosts
                | get $system
              )
            }
          )
        | str join "|"
    } else {
      null
    }
  }
}

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

def matches_configuration [file: string configuration: string] {
  $file
  | str contains $configuration
}

def matches_hosts [file: string] {
  $file
  | str contains hosts
}

def matches_systems [file: string] {
  $file
  | str contains systems
}

export def filter-files [
  files: list<string>
  system_names: list<string>
  host_names: list<string>
  shared: bool
  unique: bool
  system_name?: string
  configuration?: string
] {
  if $unique and ($configuration | is-not-empty) {
    let files = (
      $files
      | filter {|file| $configuration in $file}
    )

    if $shared and ($configuration not-in $host_names) {
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
      let configuration_is_system_name = ($configuration in $system_names)
      let configuration_is_host_name = ($configuration in $host_names)

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

def strip-configuration-name [configuration: string] {
  $configuration
  | ansi strip
  | str replace --all --regex '(\[|\])' ""
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

export def annotate-files-with-configurations [
  files: list<string>
  colors: table<configuration: string, name: string>
  group_by_file: bool
  is_host_configuration: bool
  is_system_configuration: bool
  no_full_path: bool
  no_labels: bool
  use_colors: bool
  unique: bool
  unique_filenames: bool
  configuration?: string
] {
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

      let file = (
        $file
        | append (
            if (
              $unique and (
                not $is_system_configuration
              ) and not $is_host_configuration
            ) or not $unique and (
              $host | is-not-empty
            ) and ($system | is-not-empty) {
              $"($system) ($host)"
            } else if not $unique and ($system | is-not-empty) {
              $system
            } else if $unique and $is_system_configuration and (
              $host | is-not-empty
            ) {
              $host
            } else {
              ""
            }
          )
        | str join " "
      )

      let parts = ($file | split row " ")
      let filename = ($parts | first)
      let configurations = ($parts | drop nth 0 | uniq)

      $filename
      | append $configurations
      | str join " "
      | str trim
    }
}

export def get-unique-filenames [
  files: list<string>
  colors: table<configuration: string, name: string>
  all_configurations: list<string>
  use_colors: bool
] {
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
        $files
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

  let files = (
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
  )

  if $use_colors {
    $files
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
  } else {
    $files
  }
}

def group-files-by-filenames [
  files: list<string>
  group_by_configuration: bool
  group_by_file: bool
  no_full_path: bool
  no_labels: bool
  unique_filenames: bool
  use_colors: bool
] {
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
    $use_colors and $group_by_file and (
      not $no_full_path or $no_labels
    )
  ) {
    $files
    | each {
        |file|

        colorize-file $file (get-file-path $file) default_bold
      }
  } else {
    $files
  }
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

export def group-files-by-configuration [
  files: list<string>
  colors: table<configuration: string, name: string>
  is_system_configuration: bool
  no_labels: bool
  unique: bool
  use_colors: bool
  configuration?: string
] {
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
}

def use-colors [color: string] {
  $color == "always" or (
    $color != "never"
  ) and (
    is-terminal --stdout
  )
}

# View files as a tree
def "main tree" [
  configuration?: string # Configuration (system or host) name
  --color = "auto" # When to use colored output
  --shared # List only shared configuration files
  --unique # List files unique to $configuration
] {
  try {
    let configuration_directory = if (
      $configuration | is-empty
    ) or not $unique {
      "configuration"
    } else {
      ($"configuration/**/($configuration)" | into glob)
    }

    let color = if (use-colors $color) {
      "always"
    } else {
      "never"
    }

    let ignore_glob = (
      get-tree-ignore-glob
        (get-configuration-data)
        $shared
        $configuration
    )

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

# List configuration files
def main [
  configuration?: string # Configuration (system or host) name
  --color = "auto" # When to use colored output
  --group-by-configuration # List configuration files sorted by configuration
  --group-by-file # List configuration files sorted by file
  --no-full-path # When --group-by-file, don't use the full path
  --no-labels # Don't show labels in output
  --shared # List only shared configuration files
  --unique # List files unique to $configuration
  --unique-filenames # List unique filenames for $configuration
] {
  validate-configuration-name $configuration

  let use_colors = (use-colors $color)

  let files = (
    fd
      --exclude "flake.lock"
      --hidden
      --type "file"
      ""
      "configuration"
    | lines
  )

  let system_name = if ($configuration | is-empty) {
    null
  } else {
    ls ($"configuration/**/($configuration)" | into glob)
    | get name
    | split row "systems/"
    | last
    | path split
    | first
  }

  let all_systems = (get-all-systems)
  let all_hosts = (get-all-hosts)

  let files = (
    filter-files
    $files
    $all_systems
    $all_hosts
    $shared
    $unique
    $system_name
    $configuration
 )

  let all_configurations = (get-all-configurations)
  let is_system_configuration = ($configuration in $all_systems)
  let is_host_configuration = ($configuration in $all_hosts)
  let colors = (get-colors $all_configurations)

  let files = (
    if $group_by_file or $unique_filenames {
      let files = (
        annotate-files-with-configurations
        $files
        $colors
        $group_by_file
        $is_host_configuration
        $is_system_configuration
        $no_full_path
        $no_labels
        $use_colors
        $unique
        $unique_filenames
        $configuration
      )

      if $unique_filenames {
        (
          get-unique-filenames
            $files
            $colors
            $all_configurations
            $use_colors
        )
      } else {
        (
          group-files-by-filenames
            $files
            $group_by_configuration
            $group_by_file
            $no_full_path
            $no_labels
            $unique_filenames
            $use_colors
        )
      }
    } else if $group_by_configuration {
      (
        group-files-by-configuration
          $files
          $colors
          $is_system_configuration
          $no_labels
          $unique
          $use_colors
          $configuration
      )
    } else if $use_colors and not $group_by_configuration and (
        $is_host_configuration and not $unique
      ) or (
        $is_system_configuration and not ($shared and $unique)
      ) or (
        $configuration | is-empty
    ) {
      colorize-files $files $colors $unique $configuration
    } else {
      $files
    }
  )

  if $group_by_file or $unique_filenames {
    let files = (
      $files
      | to text
      | column -t
    )

    if $unique_filenames {
      $files
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
