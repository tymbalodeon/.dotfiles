#!/usr/bin/env nu

use ./hosts.nu

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

def format_files [files: string include_shared: bool] {
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

        let configuration = if (
          $directories | get 1
        ) in ["benrosen" "work"] {
          $base | path join ($directories | get 1)
        } else {
          $base
        }

        (
          $line 
          | str replace $"($configuration)/" ""
        ) + $" [($configuration)/]"
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
          let configuration = if "bumbirich" in $line {
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

          let color = {
            "benrosen": "gb"
            "bumbirich": "cb"
            "darwin": "ub"
            "nixos": "pb"
            "ruzia": "yb"
            "work": "dgrb"
          } | get $configuration

          $"(ansi $color)($line)(ansi reset)"
        } else { 
          $line 
        }
    }
    | to text
  )
}

def get_files [files: string unique_files: bool] {
  let include_shared = not $unique_files

  return (format_files $files $include_shared)
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

    return (get_files $configuration_files $unique_files)
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
