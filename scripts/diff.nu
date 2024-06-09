#!/usr/bin/env nu

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

# View the diff between configurations
export def main [
  source: string # Host or system name
  target?: string # Host or system to compare to
  --file_name: string # View the diff for a specific filename
  --files # View files unique to a host
] {
  if $files {
    if ($source in ["darwin" "nixos"]) {
      return (fd --type file "" $source)
    } else {
      let system_directory = if $source in ["benrosen" "work"] {
        "darwin"
      } else if $source in ["bumbirich" "ruzia"] {
        "nixos"
      } else {
        print $"Unrecognized host or system name: `($source)`"

        exit 1
      }

      let exclude_pattern = (
        {
          benrosen: "work"      
          bumbirich: "ruzia"      
          ruzia: "bumbirich"      
          work: "benrosen"      
        } 
        | get $source
      )
      
      return (
        fd --exclude $exclude_pattern --type file "" $system_directory
      )
    }
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
