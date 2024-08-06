def get_src_directory [] {
 return ($env.HOME | path join "src")
}

def get_repos [
  --as-table
  --status
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

          let repo = {
            domain: ($repo | last)
            user: ($repo | get 1)
            repo: ($repo | first)
          }

          if $status {
            $repo 
            | insert "synced" (is_synced $repo)
          } else {
            $repo
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
        | path join (get_domain $domain)
      }
    } else {
      if ($domain | is-empty) {
        let matching_users = (
          ls $directory
          | par-each {|domain| ls $domain.name | get name}
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

    if ($directory | path exists) {
      cd $directory
    } else {
      print $"\"($directory)/\" does not exist."
    }

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

def is_synced [repo: record] {
  let path = (
    get_src_directory
    | path join $repo.domain
    | path join $repo.user
    | path join $repo.repo
  )

  if not ($path | path exists) {
    return false
  }

  cd $path

  let default_branch = (
    git remote show origin
    | sed -n '/HEAD branch/s/.*: //p'
  )

  if (git branch --show-current) != $default_branch {
    git checkout $default_branch    
  }

  return (git fetch --dry-run | is-empty)
}

def get_remote_user [domain: string = "github"] {
  if $domain == "github" {
    return (
      gh api user 
      | from json 
      | get login
    )
  } else if $domain == "gitlab" {
    return (
      glab api user err> /dev/null
      | from json 
      | get username
    )
  }
}


def list_repos [
  user?: string
  --domain: string = "github"
  --status
] {
  let repos = if $domain == "github" {
    if ($user | is-empty) {
      gh repo list --visibility public --json name,owner
    } else {
      gh repo list --visibility public $user --json name,owner
    }
  } else if $domain == "gitlab" {
    let remote_user =  (get_remote_user $domain)

    if $user != $remote_user {
      return
    }

    glab repo list err> /dev/null
    | lines
    | filter {|line| $line | str starts-with $remote_user}
    | par-each {|line| $line | str trim | split row "\t" | first}
  } else {
    return []
  }

  let repos = if $domain == "github" {
    $repos
    | from json
    | select owner name
  } else if $domain == "gitlab" {
    $repos
  }

  return (
    $repos
    | par-each {
        |repo| 

        let repo = if $domain == "github" {
          {
            domain: "github.com"
            user: $repo.owner.login
            repo: $repo.name
          }
        } else if $domain == "gitlab" {
          let data = ($repo | split row "/")

          {
            domain: "gitlab.com"
            user: ($data | first)
            repo: ($data | last)
          }
        }

        if $status {
          $repo 
          | insert "synced" (is_synced $repo)
        } else {
          $repo
        }
      }
    | sort-by --ignore-case "repo"
  )
}

def get_domain [domain: string] {
  if "github" in $domain {
    return "github.com"
  } else if "gitlab" in $domain {
    return "gitlab.com"
  }
}

# Clone repo at URL
def --env "src clone" [
  repo?: string # The name or URL of the repo to clone
  --domain: string = "github" # Clone repos at this domain
  --user: string # Clone repos for user
] {
  if ($repo | is-empty) {
    let repos = (list_repos $user --domain $domain)

    if not ($repos | length | into bool) {
      return
    }

    $repos
    | par-each {
        |repo|

        src clone $repo.repo --domain $domain --user $repo.user
      }
    | null
    
    let user_directory = (
      get_src_directory
      | path join (get_domain $domain)
      | path join (get_remote_user $domain)
    )

    mkdir $user_directory
    cd $user_directory

    return (ls)
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
      (get_domain $domain)
      (
        if ($user | is-empty) { 
          get_remote_user
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
      if $domain == "github" {
        gh repo clone $repo $target
      } else if $domain == "gitlab" {
        glab repo clone $repo $target
      } else {
        return
      }
    }
  }

  cd $target
}

# Initialize an environment
def --env --wrapped "src init" [
  ...args: string
] {
  let file = (get_init_file)

  let lines = (
    nu $file ...$args --return-name 
    | tee { par-each { print --no-newline }}
    | lines
  )

  if ($lines | length | into bool) {
    let path = ($lines | last)

    if ($path | path exists) {
      cd $path
    }
  }

  rm --force $file
}

# List repos
def "src list" [
  --remote # List remote repos
  --domain: string = "github" # List repos at this domain
  --status # Show sync status
  --user: string # List repos for user
] {
  if $remote {
    let repos = if $status {
      list_repos $user --domain $domain --status
    } else {
      list_repos $user --domain $domain
    }

    return (
      $repos
      | table --index false
    )
  }

  let repos = if $status {
    get_repos --as-table --status
  } else {
    get_repos --as-table
  }

  let repos = if ($user | is-empty) {
    $repos
  } else {
    $repos | where user == $user
  }

  return (
    $repos 
    | sort-by --ignore-case "user" "repo"
    | table --index false
  )
}

def get_init_file [] {
  let file = (mktemp --tmpdir dev-scripts-init.XXX)

  http get --raw "https://raw.githubusercontent.com/tymbalodeon/dev-scripts/trunk/init.nu"
  | save --force $file

  return $file
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
