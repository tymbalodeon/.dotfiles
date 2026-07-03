def merge-lines [
  local_text: string
  testing: string
] {
  let queries = (
    $testing
    | lines
    | append ($local_text | lines)
    | uniq
  )

  let commented_out_lines = (
    $queries
    | where {str starts-with "#"}
  )

  let commented_out_queries = (
    $commented_out_lines
    | each {str replace --regex "^# ?" ""}
  )

  $queries
  | where {$in not-in $commented_out_queries}
  | append $commented_out_lines
  | sort
}

def main [] {
  let config_path = (config-path)
  let remote_config = (remote-config)

  let config = if (config-path | path type) != file {
    rm --force --recursive $config_path

    $remote_config
  } else {
    let local_config = (open $config_path)

    if ($local_config == $remote_config) {
      return
    }

    let local_parts = ($local_config | split row "\n\n")
    let remote_parts = ($remote_config | split row "\n\n")
    let queries = (merge-lines ($local_parts | first) ($remote_parts | first))
    let urls = (merge-lines ($local_parts | last) ($remote_parts | last))

    $queries
    | append ""
    | append $urls
  }

  $config
  | save --force $config_path
}

