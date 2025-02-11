#!/usr/bin/env nu

use ./hosts.nu get-all-configurations
use ./hosts.nu get-all-systems
use ./hosts.nu get-built-host-name
use ./hosts.nu get-current-system
use ./hosts.nu validate-configuration-name

def validate-source-and-target [source?: string target?: string] {
  let validated_source = if (
    ($source | is-empty) or ($target | is-empty)
  ) {
    get-built-host-name
  } else {
    validate-configuration-name $source
  }

  let validated_target = if ($target | is-empty) {
    if ($source | is-empty) {
      (get-current-system) | str downcase
    } else {
      validate-configuration-name $source
    }
  } else {
    validate-configuration-name $target
  }

  {
    source: $validated_source
    target: $validated_target
  }
}

def get-configuration-files [configuration: string] {
  fd --type file "" (fd --type directory $configuration)
  | lines
}

def get-configuration-file [configuration: string file: string] {
  fd --type file $file (fd --type directory $configuration)
  | lines
}

def diff [source: string target: string side_by_side: bool] {
  do --ignore-errors {
    if $side_by_side {
      ^delta --diff-so-fancy --paging never --side-by-side $source $target
    } else {
      ^delta --diff-so-fancy --paging never $source $target
    }
  }
}

def get-file-base [file: string] {
  let pattern = "[^/]+/"

  $file
  | split row --regex $"hosts/($pattern)"
  | split row --regex $"systems/($pattern)"
  | last
}

# View the diff between configurations
def main [
  file?: string # View the diff for a specific file
  --source: string # Host or system name
  --target: string # Host or system to compare to
  --single-column # Force a single column layout
  --side-by-side # Force side-by-side layout
] {
  let validated_args = (validate-source-and-target $source $target)
  let source = ($validated_args | get source)
  let target = ($validated_args | get target)

  if ($file | is-empty) {
    let source_files = (get-configuration-files $source)
    let target_files = (get-configuration-files $target)

    let file_paths = (
      $source_files
      | str replace (fd $source) ""
    )

    let all_files = (
      | append $target_files
      | append (
          fd --type file "" (fd --type directory configuration)
          | lines
          | filter {
              |line|

              "systems" not-in $line
          }
        )
      | uniq
      | filter {
          |file|

          (get-file-base $file) in $file_paths
      }
    )

    for source_file in $source_files {
      let files = (
        $all_files
        | filter {
            |target_file|

            (get-file-base $source_file) in $target_file
          }
      )

      let side_by_side = if $single_column {
        false
      } else if $side_by_side {
        $side_by_side
      } else if (tput cols | into int) > 158 {
        true
      } else {
        false
      }

      for target_file in $files {
        diff $source_file $target_file $side_by_side
      }
    }
  } else {
    print $source
    print $target
    print (get-configuration-file $source $file)
    print (get-configuration-file $target $file)
  }
}
