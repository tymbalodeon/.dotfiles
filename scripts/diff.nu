#!/usr/bin/env nu

use ./hosts.nu 
use ./hosts.nu get_available_hosts
use ./hosts.nu get_built_host_name
use ./hosts.nu get_systems
use ./hosts.nu is_nixos

def raise_configuration_error [configuration: string] {
  print $"Unrecognized host or system name: `($configuration)`\n"
  print "Please specify a valid host or system name:"
  print (hosts)

  exit 1
  
}

def validate_configuration [configuration: string] {
  let configuration = ($configuration | str downcase)

  if not (
    $configuration in (
      (get_available_hosts | values | flatten) ++ (get_systems)
    )
  ) {
    raise_configuration_error $configuration
  }

  return $configuration
}

def validate_source_and_target [source?: string target?: string] {
  let validated_source = if (
    ($source | is-empty) or ($target | is-empty)
  ) {
    get_built_host_name
  } else {
    validate_configuration $source
  }

  let validated_target = if ($target | is-empty) {
    if ($source | is-empty) {
      if (is_nixos) {
        "darwin"
      } else {
        "nixos"
      }
    } else {
      validate_configuration $source
    }
  } else {
    validate_configuration $target
  }

  return (
    {
      source: $validated_source
      target: $validated_target
    }
  )
}

def get_shared_configuration_files [configuration?: string] {
  if ($configuration | is-empty) {
    return (
      fd 
        --exclude ".git"
        --exclude ".gitignore"
        --exclude ".pre-commit-config.yaml"
        --exclude ".stylelintrc.json"
        --exclude "Justfile"
        --exclude "README.md"
        --exclude "darwin"
        --exclude "flake.lock"
        --exclude "nixos"
        --exclude "scripts"
        --hidden
        --type "file"
        ""
    )
  } else {
    let excludes = {
      benrosen: ["nixos" "work"]
      bumbirich: ["darwin" "ruzia"]
      darwin: ["benrosen" "nixos" "work"]
      nixos: ["bumbirich" "darwin" "ruzia"]
      ruzia: ["bumbirich" "darwin"]
      work: ["benrosen" "nixos"]
    } | get $configuration

    return (
      (
        fd 
          --exclude ".git"
          --exclude ".gitignore"
          --exclude ".pre-commit-config.yaml"
          --exclude ".stylelintrc.json"
          --exclude "Justfile"
          --exclude "README.md"
          --exclude "flake.lock"
          --exclude "scripts"
          --hidden
          --type "file"
          ""
      )
      | lines
      | filter {
          |line|

          mut keep = true

          for exclude in $excludes {
            if $exclude in $line {
              $keep = false
              break
            }            
          }

          $keep
      }
      | to text
    )
  }
}

def format_files [
  configuration: string 
  files: string 
  include_shared: bool
  unique_files: bool
] {
  let files = (
    $files 
    | lines
    | each {
        |line| 
        
        let directories = (
          $line 
          | path split 
        )

        let $base = ($directories | first)

        let file_configuration = if (
          $directories | get 1
        ) in ["benrosen" "work"] {
          $base | path join ($directories | get 1)
        } else {
          $base
        }

        (
          $line 
          | str replace $"($file_configuration)/" ""
        ) + $" [($file_configuration)/]"
    }
  )

  let files = if $include_shared {
    (get_shared_configuration_files | lines) ++ $files
  } else {
    $files
  }

  return (
    $files
    | sort
    | each {
        |line| 

        if "[" in $line {
          let file_configuration = if "bumbirich" in $line {
            "bumbirich"
          } else if "ruzia" in $line {
            "ruzia"
          } else (
            $line
            | rg '\[.+\]' --only-matching
            | str replace "[" ""
            | str replace "]" ""
            | split row "/"
            | filter {|directory| not ($directory | is-empty)}
            | last
          )

          let color = if $include_shared or $unique_files {
            let is_darwin_configuration = (
              $configuration in ["benrosen" "darwin" "work"]
            )

            let is_nixos_configuration = (
              $configuration in ["bumbirich" "nixos" "ruzia"]
            )

            let is_host_configuration = (
              $configuration in ["bumbirich" "benrosen" "ruzia" "work"]
            )

            let host_color = if $is_host_configuration {
              "n"
            } else {
              "ub"
            }

            let darwin_color = if $is_darwin_configuration {
              "n"
            } else {
              "pb"
            }

            let nixos_color = if $is_nixos_configuration {
              "n"
            } else {
              "ub"
            }

            let darwin_host_color = if $is_darwin_configuration {
              $host_color
            } else {
              "yb"
            }

            let nixos_host_color = if $is_nixos_configuration {
              $host_color
            } else {
              "cb"
            }

            {
              "benrosen": $darwin_host_color
              "bumbirich": $nixos_host_color
              "darwin": $darwin_color
              "nixos": $nixos_color
              "ruzia": $nixos_host_color
              "work": $darwin_host_color
            } | get $file_configuration
          } else {
            mut color = "n"

            for host in ["benrosen" "bumbirich" "ruzia" "work"] {
              if $host in $line {
                $color = "cb"

                break
              }
            }

            $color
          }

          $"(ansi $color)($line)(ansi reset)"
        } else { 
          $line 
        }
    }
    | to text
  )
}

def get_files [configuration: string files: string unique_files: bool] {
  let include_shared = not $unique_files

  return (
    format_files 
      $configuration 
      $files 
      $include_shared 
      $unique_files
  )
}

def split_paths [paths: list<string>] {
  let systems = (get_systems)

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

def get_host_files [host: string] {
  return (
    split_paths (
      fd --hidden --type "file" "" $host
      | lines
    )
  )
}

def get_source_files [host: string] {
  return (
    (get_host_files $host)
    ++ (
      split_paths (
        get_shared_configuration_files 
        | lines
      )
    )
  )
}

def get_file_and_system [row: record] {
  return {
    file: (
      ($row | reject system) 
      | path join
    )

    system: $row.system
  }
}

def get_common_files [
  target: string 
  source_files: list
  target_files: list
] {
  let systems = (get_systems) 

  let common_files = (
    $source_files 
    | each {
        |source_file|

        $target_files 
        | filter {
            |target_file| 

            let parent = $target_file.parent

            if $parent in $systems or ($parent | is-empty) {
              (
                $source_file.stem == $target_file.stem
                and $source_file.extension == $target_file.extension
              )
            } else {
              (
                $parent == $source_file.parent
                and $source_file.stem == $target_file.stem
                and $source_file.extension == $target_file.extension
              )
            }
          }
      } 
    | flatten
    | uniq
  )

  # print $source_files
  # print $target_files
  # print $common_files

  let target_files = (
    $common_files
    | filter {
        |file| 

        let parent = $file.parent

        ($parent | is-empty) or not (
          $target 
          | str contains $file.parent
        )
      }
    | each {|file| (get_file_and_system $file)}
    | uniq
  )

  let source_files = (
    $common_files
    | filter {
        |file| 

        let parent = $file.parent

        not ($parent | is-empty) and (
          $target 
          | str contains $file.parent
        )
      }
    | each {|file| (get_file_and_system $file)}
    | uniq
  )

  # print $source_files
  # print $target_files

  return (
    $target_files 
    | wrap source
    | merge (
        $source_files
        | wrap target
      )
  )
}

def get_configuration_directory [configuration: string] {
  if $configuration in ["benrosen" "work"] {
    return $"darwin/($configuration)"
  } else if $configuration in ["bumbirich" "ruzia"] {
    return "nixos"
  } else {
    return $configuration
  }
}

def get_full_path [file: string system?: string] {
  if ($system | is-empty) {
    $file
  } else {
    $system | path join $file
  }
}

# View the diff between configurations
export def main [
  source?: string # Host or system name
  target?: string # Host or system to compare to
  --file_name: string # View the diff for a specific filename
  --files # View files relevant to a host or system configuration
  --shared-files # View only files shared across all configurations
  --side-by-side # View the diff in side-by-side layout
  --unique-files # View only files unique to a host or system configuration
] {
  if $shared_files and ($source | is-empty) {
    return (get_shared_configuration_files)
  }

  let validated_args = (validate_source_and_target $source $target)
  let source = ($validated_args | get source)
  let target = ($validated_args | get target)

  if $shared_files {
    return (get_shared_configuration_files $target)
  }

  if $files or $unique_files {
    let configurations = if ($source | is-empty) {
      ["benrosen" "bumbirich" "darwin" "nixos" "ruzia" "work"]      
    } else {
      [$source]
    }

    let configuration_files = (
      $configurations 
      | each {
          |configuration|

          if ($configuration in ["darwin" "nixos"]) {
            fd --hidden --type file "" $configuration
            | lines
          } else {
            let system_directory = if $configuration in ["benrosen" "work"] {
              "darwin"
            } else if $configuration in ["bumbirich" "ruzia"] {
              "nixos"
            } else {
              raise_configuration_error $configuration
            }

            let exclude_pattern = (
              {
                benrosen: "work"      
                bumbirich: "ruzia"      
                ruzia: "bumbirich"      
                work: "benrosen"      
              } 
              | get $configuration
            )
      
            fd --exclude $"*($exclude_pattern)*" --hidden --type file "" $system_directory
            | lines
          }
      }
    )
    | flatten
    | uniq
    | to text

    let configuration = if ($source | is-empty) {
      ""
    } else {
      $source
    }

    return (get_files $configuration $configuration_files $unique_files)
  }

  let is_darwin_host = ((get_built_host_name) in ["benrosen" "work"])

  let source_directory = if ($target | is-empty) {
    if $is_darwin_host {
      "darwin"
    } else {
      "nixos"
    }
  } else {
    get_configuration_directory $source    
  } 

  let target_directory = get_configuration_directory (
    if ($target | is-empty) {
      if ($source | is-empty) {
        if $is_darwin_host {
          "nixos"
        } else {
          "darwin"
        }
      } else {
        get_configuration_directory $source
      }
    } else {
      $target
    }
  )

  let source_files = (get_source_files $source_directory)
  let target_files = (get_host_files $target_directory)

  let common_files = (
    get_common_files 
      # (
      #   if ($source | is-empty) {
      #     $source_directory      
      #   } else {
      #     $source
      #   }
      # ) 
      $target_directory
      $source_files $target_files
  )

  for files in $common_files {
    let source = ($files | get source)

    let source_file = (
      get_full_path ($source | get file) ($source | get system)
    )

    let target_file = if "target" in ($files | columns) {
      let target = ($files | get target)

      (
        get_full_path ($target | get file) ($target | get system)
      )

    } else {
      $"($target_directory)/($source | get file)"
    }

    # do --ignore-errors {
    #   if $side_by_side {
    #     delta --paging never --side-by-side $source_file $target_file
    #   } else {
    #     delta --paging never $source_file $target_file
    #   }
    # }
  }
}
