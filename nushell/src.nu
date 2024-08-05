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

def matches [
  search_repo: record
  repo: record
  column: string
] {
  let search_repo_column = ($search_repo | get $column)

  return (
    (
      $search_repo_column | is-empty
    ) or ($search_repo_column == ($repo | get $column))
  )
}

def choose_from_list [options: list] {
  return (
    $options
    | to text
    | fzf --exact --scheme path
  )
}

# Change directory to a repo
def --env "src cd" [
  repo?: string # The repo name
  --domain: string # The domain
  --user: string # The username
] {
  if ($repo | is-empty) {
    let directory = (get_src_directory)

    let directory = if ($user | is-empty) {
      if ($domain | is-empty) {
        $directory
      } else {
        $directory 
        | path join $domain
      }
    } else {
      if ($domain | is-empty) {
        let matching_users = (
          ls $directory
          | each {|domain| ls $domain.name | get name}
          | flatten
          | filter {|found_user| $user == ($found_user | path basename)}
        )

        if ($matching_users | length) == 1 {
          $matching_users 
          | first
        } else {
          choose_from_list $matching_users
        }
      } else {
        $directory 
        | path join $domain 
        | path join $user
      }
    }

    cd $directory

    return
  }

  let search_repo = {
    domain: $domain
    user: $user
    repo: $repo
  }

  let matching_repos = (
    get_repos --as-table
    | filter {
        |repo| 

        let matches_domain = (matches $search_repo $repo "domain")
        let matches_user = (matches $search_repo $repo "user")
        let matches_repo = (matches $search_repo $repo "repo")

        [
          $matches_domain 
          $matches_user 
          $matches_repo
        ] | all {|item| $item}
      }
  )

  if ($matching_repos | length) == 1 {
    let $repo_path = ($matching_repos | first | values | path join)

    cd (get_src_directory | path join $repo_path)
  } else {
    choose_from_list $matching_repos
  }
}

def list_repos [user?: string] {
  let repos = if ($user | is-empty) {
    gh repo list --visibility public --json name,owner
  } else {
    gh repo list --visibility public $user --json name,owner
  }

  return (
    $repos
    | from json
    | select owner name
    | each {
        |repo| 

        {
          domain: "github.com"
          user: $repo.owner.login
          repo: $repo.name
        }
      }
  )
}

def get_github_user [] {
  return (
    gh api user 
    | from json 
    | get login
  )
}

# Clone repo at URL
def --env "src clone" [
  repo?: string # The name or URL of the repo to clone
  --user: string # List repos for user
] {
  if ($repo | is-empty) {
    list_repos $user
    | par-each {
        |repo|

        src clone $repo.repo --user $repo.user
      }
    | null

    cd (
      get_src_directory
      | path join "github.com"
      | path join (get_github_user)
    )

    return
  }

  let values = if (
    $repo
    | str starts-with "git@"
  ) {
    $repo
    | split row "@"
    | split row ":"
    | split row "/"
    | drop nth 0
  } else if (
   $repo
    | str starts-with "http"
  ) {
    $repo
    | split row "://"
    | split row "/"
    | drop nth 0
  } else {
    [
      "github.com"
      (
        if ($user | is-empty) { 
          get_github_user
        } else { 
          $user 
        }
      )
      $repo
    ]
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
    if ($repo | str starts-with "git@") or ($repo | str starts-with "http") {
      git clone $repo $target
    } else {
      gh repo clone $repo $target
    }
  }

  cd $target
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

# List repos
def "src list" [
  --remote # List remote repos
  --user: string # List repos for user
] {
  if $remote {
    return (
      list_repos $user
      | table --index false
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
