#!/usr/bin/env nu

use ./hosts.nu 
use ./hosts.nu get_available_hosts

def get_file_info [host: string] {
  return (
    fd "" $host
    | lines
    | each {|file| $file | path parse}
    | update parent {|row| $row.parent | path basename}
  )
}

def get_common_files [source_files: list<table> target_files: list<table>] {
  return (
    $source_files 
    | each {
        |file|

        (
          $target_files 
          | where 
              parent == $file.parent
              and stem == $file.stem
              and extension == $file.extension
          | path join
          | to text
        ) 
    } | filter {|row| not ($row | is-empty)}
  )
}

def get_shared_configuration_files [] {
  (
    fd 
      --exclude "Justfile"
      --exclude "README.md"
      --exclude "darwin"
      --exclude "flake.lock"
      --exclude "nixos"
      --exclude "scripts"
      --type "file"
      ""
  )
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

# View the diff between configurations
export def main [
  source?: string # Host or system name
  target?: string # Host or system to compare to
  --file_name: string # View the diff for a specific filename
  --files # View files relevant to a host or system configuration
  --shared-files # View only files shared across all configurations
  --unique-files # View only files unique to a host or system configuration
] {
  if $shared_files {
    return (get_shared_configuration_files)
  }

  if $files or $unique_files {
    let source = if not ($source | is-empty) {
      $source | str downcase
    } else {
      $source
    }

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
            fd --type file "" $configuration
            | lines
          } else {
            let system_directory = if $configuration in ["benrosen" "work"] {
              "darwin"
            } else if $configuration in ["bumbirich" "ruzia"] {
              "nixos"
            } else {
              print $"Unrecognized host or system name: `($configuration)`\n"
              print "Please specify a valid host or system name:"
              print (hosts)

              exit 1
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
      
            fd --exclude $"*($exclude_pattern)*" --type file "" $system_directory
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
  
  let darwin_files = (get_file_info "darwin")
  let nixos_files = (get_file_info "nixos")

  mut common_files = (get_common_files $darwin_files $nixos_files)
  mut common_files = (get_common_files $nixos_files $darwin_files)

  $common_files =  ($common_files | uniq)

  for file in $common_files {
    do --ignore-errors {
      delta $"darwin/($file)" $"nixos/($file)"
    } 
  }
}
