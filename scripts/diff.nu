#!/usr/bin/env nu

use ./hosts.nu 
use ./hosts.nu get_available_hosts
use ./hosts.nu get_built_host_name

def raise_configuration_error [configuration: string] {
  print $"Unrecognized host or system name: `($configuration)`\n"
  print "Please specify a valid host or system name:"
  print (hosts)

  exit 1
  
}

def validate_configuration [configuration?: string] {
   if (
    not ($configuration | is-empty) and not (
      $configuration in (
        (get_available_hosts | values | flatten) 
        ++ (get_available_hosts | columns | str downcase)
      )
    )
  ) {
    raise_configuration_error $configuration
  }

  return (
    if not ($configuration | is-empty) {
      $configuration | str downcase
    } else {
      $configuration
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
  return (
    $paths
    | each {|file| $file | path parse}
    | update parent {|row| $row.parent | path basename}
  )
}

def get_host_files [host: string] {
  return (
    split_paths (
      fd --hidden "" $host
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

def get_common_files [
  target: string 
  source_files: list<table> 
  target_files: list<table>
] {
  let systems = (
    get_available_hosts | columns | str downcase
  ) 

  let common_files = (
    $target_files 
    | each {
        |target_file|

        $source_files 
        | filter {
            |source_file| 

            let parent = $source_file.parent

            if $parent in $systems or ($parent | is-empty) {
              (
                $source_file.stem == $target_file.stem
                and $source_file.extension == $target_file.extension
              )
            } else {
              (
                $parent == $target_file.parent
                and $source_file.stem == $target_file.stem
                and $source_file.extension == $target_file.extension
              )
            }
          }
      } 
    | flatten
  )

  let source_files = (
    $common_files
    | filter {
        |file| 

        let parent = $file.parent

        ($parent | is-empty) or not (
          $target 
          | str contains $file.parent
        )
      }
    | path join
  )

  let target_files = (
    $common_files
    | filter {
        |file| 

        let parent = $file.parent

        not ($parent | is-empty) and (
          $target 
          | str contains $file.parent
        )
      }
    | path join
  )

  return ($source_files | zip $target_files)
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

# View the diff between configurations
export def main [
  source?: string # Host or system name
  target?: string # Host or system to compare to
  --file_name: string # View the diff for a specific filename
  --files # View files relevant to a host or system configuration
  --shared-files # View only files shared across all configurations
  --unique-files # View only files unique to a host or system configuration
] {
  let source = validate_configuration $source

  if $shared_files {
    return (get_shared_configuration_files $source)
  }

  let target = validate_configuration $target

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
  let common_files = (get_common_files $source $source_files $target_files)

  for files in $common_files {
    let source_file = ($files | first) 

    let target_file = (
      $files 
      | last 
      | path split 
      | drop nth 0 
      | path join
    )

    let target_file = $"($target_directory)/($target_file)"

    do --ignore-errors {
      delta $source_file $target_directory
    }
  }
}
