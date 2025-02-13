#!/usr/bin/env nu

use ./hosts.nu get-all-configurations
use ./hosts.nu get-all-hosts
use ./hosts.nu get-all-systems
use ./hosts.nu get-built-host-name
use ./hosts.nu get-current-system
use ./hosts.nu validate-configuration-name

def validate-source [source?: string] {
  if ($source | is-empty) {
    (get-current-system) | str downcase
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
  let configuration_files = (
    fd --hidden --type file "" (fd --type directory $configuration)
    | lines
  )

  let configuration_files = if $configuration in (get-all-hosts) {
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

def get-file-base [file: string] {
  let pattern = "[^/]+/"

  $file
  | split row --regex $"hosts/($pattern)"
  | split row --regex $"systems/($pattern)"
  | last
}

def get-file-path [file: string] {
  $file
  | str replace configuration/ ""
  | str replace --regex 'systems/[^/]+/' ""
  | str replace --regex 'hosts/[^/]+/' ""
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

# View the diff between configurations
def main [
  file?: string # View the diff for a specific file
  --source: string # Host or system name
  --target: string # Host or system to compare to
  --side-by-side # Force side-by-side layout
  --single-column # Force a single column layout
] {
  let source = (validate-source $source)
  let target = (validate-target $target)

  let source_files = (get-configuration-files $source)

  let target_files = (
    get-configuration-files $target
    | where $it =~ $target
  )

  let side_by_side = $side_by_side or not $single_column and (
    (tput cols | into int) > 158 
  )

  if ($file | is-empty) {
    for source_file in $source_files {
      let target_files = (
        $target_files
        | filter {
            |target_file|

            (get-file-path $target_file) == (get-file-path $source_file)
        }
      )

      for target_file in $target_files {
        if $source_file != $target_file {
          diff $source_file $target_file $side_by_side
        }
      }
    }
  } else {
    let source_files = (get-configuration-matching-files $source_files $file)
    let target_files = (get-configuration-matching-files $target_files $file)

    for source_file in $source_files {
      for target_file in $target_files {
        if $source_file != $target_file {
          diff $source_file $target_file $side_by_side
        }
      }
    }
  }
}
