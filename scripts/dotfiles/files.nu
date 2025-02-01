#!/usr/bin/env nu

def matches_kernel_name [file: string kernel_name?: string] {
  if ($kernel_name | is-empty) {
    false
  } else {
    $file
    | str contains $kernel_name
  }
}

def matches_kernels [file: string] {
  $file | str contains kernels
}

def matches_hosts [file: string] {
  $file | str contains hosts
}

def matches_configuration [file: string configuration: string] {
  $file | str contains $configuration
}

# List configuration files
def main [
  configuration?: string # Configuration name
  --unique # View only files unique to a configuration
] {
  if ($configuration | is-not-empty) and not (
    [
      $"configuration/kernels/($configuration)"
      $"configuration/**/hosts/($configuration)"
    ] | each {
        |glob|

        try {
          ls ($glob | into glob)
          | get name

          true
        } catch {
          false
        }
      }
    | any {|item| $item | into bool}
  ) {
    error make { msg: $"unrecognized configuration name '($configuration)'" }
  }

  if $unique {
    # list-files $unique
  } else {
    let files = (
      fd
        --exclude "flake.lock"
        --hidden
        --type "file"
        ""
        "configuration"
    )

    if ($configuration | is-empty) {
      $files
      | lines
      | filter {|file| not ($file | str contains kernels)}
      | str join "\n"
    } else {
      let configuration_is_kernel_name = (
        $configuration in (ls configuration/kernels --short-names).name
      )

      let configuration_is_host_name = (
        $configuration in (ls configuration/**/hosts/** --short-names).name
      )

      let kernel_name = if $configuration_is_host_name {
        ls ($"configuration/**/($configuration)" | into glob)
        | get name
        | split row "kernels/"
        | last
        | path split
        | first
      } else {
        null
      }
    
      $files
      | lines
      | filter {
          |file|

          $configuration_is_kernel_name and (
            matches_configuration $file $configuration
          ) and not (matches_hosts $file) or not (
            matches_kernels $file
          ) or $configuration_is_host_name and (
            matches_configuration $file $configuration
          ) or not (matches_hosts $file) and (
            matches_kernel_name $file $kernel_name
          )
        }
      | str join "\n"
    }
  }
}
