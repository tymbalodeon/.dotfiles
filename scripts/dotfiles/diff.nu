#!/usr/bin/env nu

use ./color.nu colorize
use ./color.nu colorize-file
use ./configurations.nu get-all-configurations
use ./configurations.nu get-all-hosts
use ./configurations.nu get-all-systems
use ./configurations.nu get-built-host-name
use ./configurations.nu get-current-system
use ./configurations.nu get-file-path
use ./configurations.nu validate-configuration-name

def validate-file [file: string] {
  let file = if not ($file | str contains configuration/) {
    "configuration"
    | path join $file
  } else {
    $file
  }

  if not ($file | path exists) {
    error make --unspanned {msg: $'"($file)" does not exist'}
  }

  $file
}

def diff [source: string target: string side_by_side: bool] {
  let width = (tput cols)

  do --ignore-errors {
    if $side_by_side {
      (
        ^delta
          --diff-so-fancy
          --paging never
          --side-by-side
          --width $width
          $source
          $target
      )
    } else {
      (
        ^delta
        --diff-so-fancy
        --paging never
        --width $width
        $source
        $target
      )
    }
  }
  | complete
  | get stdout
}

def validate-source [source?: string] {
  if ($source | is-empty) {
    get-current-system
  } else {
    validate-configuration-name $source
  }
}

def validate-target [target?: string] {
  if ($target | is-empty) {
    get-built-host-name
  } else {
    validate-configuration-name $target
  }
}

def get-configuration-files [configuration: string] {
  let base_directory = if ($configuration == "shared") {
    "configuration"
  } else {
    $configuration
  }

  let configuration_files = (
    fd --hidden --type file "" (fd --type directory $base_directory)
    | lines
  )

  let configuration_files = if ($configuration == "shared") {
    $configuration_files
    | where $it !~ hosts and $it !~ systems
  } else if ($configuration in (get-all-hosts)) {
    let system = (
      $configuration_files
      | first
      | rg "systems/([^/]+)" --only-matching --replace "$1"
    )

    $configuration_files
    | append (
        fd --hidden --type file "" (fd --type directory $system)
        | lines
        | where $it !~ hosts
      )
  } else {
    $configuration_files
    | where $it !~ hosts
  }

  $configuration_files
  | append (
      fd --hidden --type file "" configuration
      | lines
      | where $it !~ system
  )
  | uniq
}

def get-diff-files-filename [file: string index: int] {
  $file
  | split row " "
  | get $index
}

export def sort-diff-files [a: string b: string sort_by_target: bool] {
  let index = if $sort_by_target {
    2
  } else {
    0
  }

  (get-diff-files-filename $a $index) < (
    get-diff-files-filename $b $index
  )
}

export def list-files [
  source_files: list<string>
  target_files: list<string>
  sort_by_target: bool
  file?: string
] {
  let output = (
    $source_files
    | each {
        |source_file|

        $target_files
        | filter {
            |target_file|

            (get-file-path $target_file) == (get-file-path $source_file)
          }
        | where $it != $source_files
        | each {
            |target_file|

            colorize-file $target_file (get-file-path $target_file) green_bold
          }
        | each {
            |target_file|

            let source_file_path = (
              get-file-path $source_file
            )

            let source_file = (
              colorize-file
                $source_file
                (get-file-path $source_file)
                yellow_bold
            )

            $"(colorize $source_file yellow) -> (colorize $target_file green)"
          }
      }
    | flatten
    | sort-by --custom {
        |a, b|

        sort-diff-files $a $b $sort_by_target
      }
    | to text
    | column -t
  )

  if ($file | is-not-empty) {
    $output
    | lines
    | where $it =~ $file
    | str join "\n"
  } else {
    $output
  }
}

def get-delta-args [target_files: list<string> source_file: string] {
  $target_files
  | filter {
      |target_file|

      $target_file != $source_file
    }
  | each {
      |target_file|

      {
        source_file: $source_file
        target_file: $target_file
      }
    }
}

def get-configuration-matching-files [
  configuration_files: list<string>
  file_path: string
] {
  $configuration_files
  | filter {
      |file|

      $file
      | str ends-with $file_path
    }
}

export def get-diff-files [
  source_files: list<string>
  target_files: list<string>
  file?: string
] {
  if ($file | is-empty) {
    $source_files
    | each {
        |source_file|

        let target_files = (
          $target_files
          | filter {
              |target_file|

              (get-file-path $target_file) == (get-file-path $source_file)
            }
        )

        get-delta-args $target_files $source_file
      }
  } else {
    let $source_files = (get-configuration-matching-files $source_files $file)
    let target_files = (get-configuration-matching-files $target_files $file)

    $source_files
    | each {
        |source_file|

        get-delta-args $target_files $source_file
      }
  }
  | flatten
}

def get-delta-filename [diff: string index: int] {
  $diff
  | lines
  | get 2
  | split row " "
  | where $it != ""
  | get $index
}

export def sort-delta-files [a: string b: string sort_by_target: bool] {
  let index = if $sort_by_target {
    3
  } else {
    1
  }

  (get-delta-filename $a $index) < (
    get-delta-filename $b $index
  )
}

export def get-source-or-target-files [
  all_files: list<string>
  all_other_files: list<string>
  comparing_to_shared: bool
  other_configuration: string
] {
  if not $comparing_to_shared or ($other_configuration == "shared") {
    $all_files
    | where not ($it in $all_files and $it in $all_other_files)
  } else {
    $all_files
  }
}

def parse-args [
  side_by_side: bool
  single_column: bool
  source?: string
  target?: string
  source_file?: string
  target_file?: string
] {
  let side_by_side = $side_by_side or not $single_column and (
    (tput cols | into int) > 158
  )

  let full_paths = (
    [$source_file $target_file]
    | all {|file| $file | is-not-empty}
  )

  let source_file = if $full_paths {
    validate-file $source_file
  } else {
    $source_file
  }

  let target_file = if $full_paths {
    validate-file $target_file
  } else {
    $target_file
  }

  if $full_paths {
    return (diff $source_file $target_file $side_by_side)
  }

  let source = (validate-source $source)
  let target = (validate-target $target)
  let all_source_files = (get-configuration-files $source | sort)
  let all_target_files = (get-configuration-files $target)
  let comparing_to_shared = ([$source $target] | any {$in == "shared"})

  let source_files = (
    get-source-or-target-files
      $all_source_files
      $all_target_files
      $comparing_to_shared
      $target
  )

  let target_files = (
    get-source-or-target-files
      $all_target_files
      $all_source_files
      $comparing_to_shared
      $source
  )

  {
    side_by_side: $side_by_side
    source_file: $source_file
    source_files: $source_files
    target_file: $target_file
    target_files: $target_files
  }
}

def "main filenames" [
  filename?: string # Filter to a specific filename
  --side-by-side # Force side-by-side layout
  --single-column # Force a single column layout
  --sort-by-target # Sort by target files
  --source: string # Host or system name
  --target: string # Host or system name
] {
  let args = (
    parse-args
      $side_by_side
      $single_column
      $source
      $target
      $filename
  )

  list-files $args.source_files $args.target_files $sort_by_target $filename
}

# View the diff between configurations
def main [
  source_file?: string # View the diff for a specific file
  target_file?: string # View the diff for a specific file
  --paging: string # When to use paging (*auto*, never, always)
  --side-by-side # Force side-by-side layout
  --single-column # Force a single column layout
  --sort-by-target # Sort by target files
  --source: string # Host or system name
  --target: string # Host or system name
] {
  let args = (
    parse-args
      $side_by_side
      $single_column
      $source
      $target
      $source_file
      $target_file
  )

  let paging = if ($paging | is-empty) {
    "auto"
  } else {
    $paging
  }

  get-diff-files $args.source_files $args.target_files $args.source_file
  | each {
      |files|

      diff $files.source_file $files.target_file $args.side_by_side
    }
  | flatten
  | sort-by --custom {
      |a, b|

      sort-delta-files $a $b $sort_by_target
    }
  | str join "\n"
  | bat --paging $paging
}
