#!/usr/bin/env nu

# use ./hosts.nu
# use ./hosts.nu get-available-configurations
# use ./hosts.nu get-available-hosts
# use ./hosts.nu get-built-host-name
# use ./hosts.nu get-darwin-configurations
# use ./hosts.nu get-kernels
# use ./hosts.nu get-nixos-configurations
# use ./hosts.nu is-nixos
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
      if (is-nixos) {
        "darwin"
      } else {
        "nixos"
      }
    } else {
      validate-configuration-name $source
    }
  } else {
    validate-configuration-name $target
  }

  return (
    {
      source: $validated_source
      target: $validated_target
    }
  )
}

def split-paths [paths: list<string>] {
  let systems = (get-kernels)

  return (
    $paths
    | each {|file| $file | path parse}
    | insert system {
        |row|

        let dirname = (
          $row.parent
          | path dirname
        )

        if $dirname in $systems {
          $dirname
        } else {
          null
        }
      }
    | update parent {|row| $row.parent | path basename}
  )
}

def get-excluded-paths-pattern [name: string] {
  {
    benrosen: "work"
    bumbirich: "ruzia"
    ruzia: "bumbirich"
    work: "benrosen"
  } | get $name
}

def get-host-files [host_directory: string --with-shared] {
  let nested_path = ("/" in $host_directory)

  let system_directory = (
    get-project-path configuration
    | path join (
        if $nested_path {
          $host_directory | path dirname
        } else {
          $host_directory
        }
      )
  )

  let host_name = if $nested_path {
    $host_directory | path basename
  } else {
    $host_directory
  }

  let files = (
    if $nested_path {
      let exclude_pattern = (get-excluded-paths-pattern $host_name)

      (
        fd
          --exclude $"*($exclude_pattern)*"
          --hidden
          --type "file"
          ""
          $system_directory
      )
    } else {
      (
        fd
          --hidden
          --type "file"
          ""
          $system_directory
      )
    }
    | lines
  )

  let host_files = (split-paths $files)

  return (
    if $with_shared {
      $host_files ++ (
        split-paths (
          get-shared-configuration-files
          | lines
        )
      )
    } else {
      $host_files
    }
  )
}

def get-file-and-system [row: record] {
  return {
    file: (
      ($row | reject system)
      | path join
    )

    system: $row.system
  }
}

def get-full-path [file: record] {
  let path = ($file | reject system | path join)

  return (
    if ($file.system | is-empty) {
      $path
    } else {
      $file.system | path join $path
    }
  )
}

def get-common-files [
  target: string
  source_files: list
  target_files: list
] {
  let systems = (get-kernels)

  let available_hosts = (
    (get-available-configurations)
    | append ""
  )

  mut $common_files = {
    source: []
    target: []
  }

  for source_file in $source_files {
    let matching_files = (
      $target_files
      | filter {
          |target_file|

          (
            $target_file.stem == $source_file.stem
            and (
              $target_file.parent == $source_file.parent
              or $target_file.parent in $available_hosts
            )
          )
        }
    )

    $common_files.target = (
      $common_files.target
      | append $matching_files
    )

    if not ($matching_files | is-empty) {
      $common_files.source = (
        $common_files.source
        | append $source_file
      )
    }
  }

  $common_files.source = (
    $common_files.source
    | each {|file| (get-full-path $file)}
  )

  $common_files.target = (
    $common_files.target
    | each {|file| (get-full-path $file)}
  )

  return $common_files
}

def get-configuration-directory [configuration: string] {
  if $configuration in (get-darwin-configurations) {
    return $"darwin/($configuration)"
  } else if $configuration in (get-nixos-configurations) {
    return "nixos"
  } else {
    return $configuration
  }
}

def list-files [unique_files: bool configuration?: string] {
  let configurations = if ($configuration | is-empty) {
    get-available-configurations
  } else {
    [$configuration]
  }

  let kernels = (get-kernels)
  let base_directory = "configuration/kernels"
  let darwin_hosts = (get-darwin-configurations)
  let nixos_hosts = (get-nixos-configurations)

  let configuration_files = (
    $configurations
    | each {
        |configuration|

        if ($configuration in $kernels) {
          (
            fd
              --hidden
              --type file
              ""
              (
                $base_directory
                | path join $configuration
              )
          ) | lines
        } else {
          let kernel_directory = (
            $base_directory
            | path join (
              if $configuration in $darwin_hosts {
                "darwin"
              } else if $configuration in $nixos_hosts {
                "nixos"
              } else {
                raise_configuration_error $configuration
              }
            )
          )

          let exclude_pattern = (get-excluded-paths-pattern $configuration)

          (
            fd
              --exclude $"*($exclude_pattern)*"
              --hidden
              --type file
              ""
              $kernel_directory
          ) | lines
        }
      }
    | append (
        fd --exclude kernels --type file "" configuration
        | lines
      )
    | flatten
    | uniq
    | to text
  )

  format-files $configuration_files $unique_files $configuration
}

def get-matching-files [files: string file: string] {
  return (
    $files
    | rg $file
    | lines
    | each {
        |line|

        let parent = (
          $line
          | split row " "
          | last
          | str replace "[" ""
          | str replace "]" ""
        )

        let file = (
          $line
          | split row " "
          | first
        )

        $"($parent)($file)"
        | ansi strip
    }
  )
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

# View the diff between configurations
def main [
  source?: string # Host or system name
  target?: string # Host or system to compare to
  --file: string # View the diff for a specific file
  --side-by-side # View the diff in side-by-side layout
] {
  let validated_args = (validate-source-and-target $source $target)
  let source = ($validated_args | get source)
  let target = ($validated_args | get target)

  if not ($file | is-empty) {
    let target_files = (list-files true $target)
    let source_files = (list-files true $source)
    let matching_source_files = (get-matching-files $source_files $file)
    let matching_target_files = (get-matching-files $target_files $file)

    print $matching_source_files
    print $matching_target_files

    for source_file in $matching_source_files {
      for target_file in $matching_target_files {
        if $target_file in $matching_source_files {
          continue
        }

        diff $source_file $target_file $side_by_side
      }
    }

    return
  }

  let source_directory = (get-configuration-directory $source)
  let target_directory = (get-configuration-directory $target)
  let source_files = (get-host-files $source_directory --with-shared)
  let target_files = (get-host-files $target_directory)

  let common_files = (
    get-common-files
      $target
      $source_files
      $target_files
  )

  let source_files = ($common_files | get source)
  let target_files = ($common_files | get target)

  for files in ($source_files | zip $target_files) {
    let source = ($files | get 0)
    let target = ($files | get 1)

    diff $source $target $side_by_side
  }
}
