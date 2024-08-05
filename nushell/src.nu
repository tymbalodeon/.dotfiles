def get_src_directory [] {
 return ($env.HOME | path join "src")
}

def get_repos [
  --as-table
] {
  if $as_table {
    return (
      get_repos
      | par-each {
          |repo|

          let repo = (
            $repo
            | split row "/"
            | reverse
            | take 3
          )

          {
            domain: ($repo | last)
            user: ($repo | get 1)
            repo: ($repo | first)
          }
      }
    )
  } else {
    return (
      ls ((get_src_directory) ++ "/**" | into glob)
      | filter {
          |item|

          ($item.type == "dir") and (
            $item.name | path join ".git" | path exists
          )
        }
      | get name
    )
  }
}

# Change directory to a repo
def --env "src cd" [
  repo: string # The repo name
  user?: string # The username
  domain?: string # The domain
] {
  let matching_repos = (
    get_repos --as-table
    | filter {|repo_data| $repo_data.repo == $repo}
  )

  if ($matching_repos | length) == 1 {
    let $repo_path = ($matching_repos | first | values | path join)

    cd (get_src_directory | path join $repo_path)
  }
}

# Clone repo at URL
def "src clone" [
  url: string # The URL of the repo to clone
] {
  let values = if (
    $url
    | str starts-with "git@"
  ) {
    $url
    | split row "@"
    | split row ":"
    | split row "/"
    | drop nth 0
  } else if (
    $url
    | str starts-with "http"
  ) {
    $url
    | split row "://"
    | split row "/"
    | drop nth 0
  } else {
    return "Unable to parse URL."
  }

  let target = (
    get_src_directory
    | path join (
        $values | first
      ) | path join (
        $values | get 1
      ) | path join (
        $values | last | str replace ".git" ""
      )
  )

  if not ($target | path exists) {
    git clone $url $target
  }
}

# Initialize an environment
def --env "src init" [
  environment?: string # The environment (`src list-environments`) to initialize
  name?: string # Where to download the environment
] {
  let file = (get_init_file)

  cd (
    nu $file $environment $name --return-name 
    | tee { each { print --no-newline }}
    | lines
    | last
  )

  rm --force $file
}

# List cloned repos
def "src list" [
  --remote # List remote repos
  --user: string # List cloned repos for user
] {
  if $remote {
    let repos = if ($user | is-empty) {
      gh repo list --json name,visibility    
    } else {
      gh repo list $user --json name,visibility      
    }

    return (
      $repos
      | from json
      | filter {|repo| $repo.visibility == "PUBLIC"}
      | get name
      | to text
    )
  }

  let repos = (get_repos --as-table)

  let repos = if ($user | is-empty) {
    $repos
  } else {
    $repos | where user == $user
  }

  return ($repos | table --index false)
}

def get_init_file [] {
  let file = (mktemp --tmpdir dev-scripts-init.XXX)

  http get --raw "https://raw.githubusercontent.com/tymbalodeon/dev-scripts/trunk/init.nu"
  | save --force $file

  return $file
}

# List available development environments
def "src list-environments" [] {
  let file = (get_init_file)

  nu $file --list

  rm --force $file
}

# Sync all repos
def "src sync" [] {
  print "Syncing repos..."

  get_repos
  | par-each {
      |repo|
      cd $repo

      let result = (git pull out> /dev/null | complete)

      if $result.exit_code != 0 {
        (
          print
            --stderr
            $"\nThere was a problem syncing \"($repo)\":\n\n($result.stderr)"
        )
      }

      let repo_name = (
        $repo
        | str replace $"(get_src_directory)/" ""
      )

      print $"Synced ($repo_name)."
    } | null
}

def src [] {
  help src
}
