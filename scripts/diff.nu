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

def include_shared_files [files: string] {
  return (
    (get_shared_configuration_files | lines) ++ ($files | lines)
    | sort
    | to text
  )
}

def get_files [files: string unique_files: bool] {
  if $unique_files {
    return $files
  } else {
    return (include_shared_files $files)
  }
}

# View the diff between configurations
export def main [
  source: string # Host or system name
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
    let source_files = if ($source in ["darwin" "nixos"]) {
      fd --type file "" $source
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
      
      fd --exclude $"*($exclude_pattern)*" --type file "" $system_directory
    }

    return (get_files $source_files $unique_files)
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
