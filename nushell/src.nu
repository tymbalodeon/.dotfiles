def get_src_directory [] {
 return ($env.HOME | path join "src")
}

def parse_git_url [origin: string] {
  let values = (
    if ($origin | str starts-with "git@") {
      $origin 
      | parse "git@{domain}:{user}/{repo}.git"
    } else if ($origin | str starts-with "http") {
      $origin 
      | str replace --regex "https?://" "" 
      | parse "https://{domain}/{user}/{repo}.git"
    } else if ($origin | str starts-with "ssh://") {
      $origin 
      | parse "ssh://git@{domain}/{user}/{repo}.git"
    } else {
      print --stderr $"Unable to parse remote origin: \"($origin)\""

      exit 1
    }
  )

  return ($values | first)
}

def into_repo [] {
  $in
  | into record
  | transpose
  | transpose
  | get 1
  | reject column0
  | rename domain user repo
}

def get_local_repos [
  --as-table
  --domain: string
  --status
  --user: string
] {
  if $as_table {
    return (
      get_local_repos
      | par-each {
          |repo|

          cd $repo

          let origin = (
            git remote get-url origin err> /dev/null
            | complete
          )

          let origin = if $origin.exit_code != 0 {
            ""
          } else {
            $origin.stdout 
            | str trim
          }

          let repo = if ($origin | str starts-with "git@") or (
            $origin | str starts-with "http"
          ) {
            parse_git_url $origin
          } else {
              $repo
              | split row "/"
              | reverse
              | take 3
              | reverse
              | into_repo
          }

          if $status {
            $repo 
            | insert "synced" (is_synced $repo)
          } else {
            $repo
          }
        }
      | filter {
          |repo|

          ($domain | is-empty) or (
            $repo.domain == $domain
          ) and ($user | is-empty) or (
            $repo.user == $user
          )
      }
    )
  } else {
    return (
      ls ((get_src_directory) ++ "/**" | into glob)
      | append (ls --all $env.HOME | where name =~ ".dotfiles")
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

    return (ls)
  }

  let search_repo = {
    domain: $domain
    user: $user
    repo: $repo
  }

  let matching_repos = (
    get_local_repos --as-table
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
    let repo = ($matching_repos | first)

    let $repo_path = if $repo.repo == ".dotfiles" {
      $env.HOME      
      | path join $repo.repo
    } else {
      get_src_directory
      | path join $repo.domain
      | path join $repo.user
      | path join $repo.repo
    }

    cd $repo_path
  } else {
    cd (choose_from_list $matching_repos)
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

def get_remote_repos [
  user?: string
  --domain: string = "github"
  --status
  --visibility: string
] {
  let repos = if $domain == "github" {
    if ($user | is-empty) {
      if ($visibility | is-empty) {
        gh repo list --json name,owner
      } else {
        gh repo list --visibility $visibility --json name,owner
      }
    } else {
      if ($visibility | is-empty) {
        gh repo list $user --json name,owner
      } else {
        gh repo list --visibility $visibility $user --json name,owner
      }
    }
  } else if $domain == "gitlab" {
    let remote_user =  (get_remote_user $domain)

    let user = if ($user | is-empty) {
      $remote_user
    } else {
      $user
    }

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
  --visibility: string # Limit to public or private repos
] {
  if ($repo | is-empty) {
    let repos = (
      get_remote_repos $user --domain $domain --visibility $visibility
    )

    if not ($repos | length | into bool) {
      return
    }

    $repos
    | par-each {
        |repo|

        (
          src clone 
            $repo.repo 
            --domain $domain 
            --user $repo.user
            --visibility $visibility
        )
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

  let repo_data = if ($repo | str starts-with "git@") or (
    $repo | str starts-with "http"
  ) {
    parse_git_url $repo
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
    ] | into_repo
  }

  let target = if $repo_data.repo == ".dotfiles" {
    $env.HOME 
    | path join $repo_data.repo  
  } else {
    get_src_directory
    | path join (
        $repo_data.domain
      ) | path join (
        $repo_data.user
      ) | path join (
        $repo_data.repo
      )
  }

  if not ($target | path exists) {
    if ($repo | str starts-with "git@") or ($repo | str starts-with "http") {
      git clone $repo $target
    } else if "github" in $domain {
      gh repo clone $repo_data.repo $target
    } else if "gitlab" in $domain {
      glab repo clone $repo_data.repo $target
    } else {
      return
    }
  }

  cd $target
}

def get_environment_command_source [] {
  let file = (mktemp --tmpdir dev-scripts-environment-XXX.nu)

  (
    http get 
      --raw "https://raw.githubusercontent.com/tymbalodeon/dev-scripts/trunk/environment.nu"
    | save --force $file
  )

  return $file
}

# Create a new project
def --env --wrapped "src environment" [
  ...args: string
] {
  let file = (get_environment_command_source)

  let lines = (
    nu $file ...$args 
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
  --domain: string # List repos at this domain
  --status # Show sync status
  --user: string # List repos for user
  --visibility: string # Limit to public or private repos
] {
  if $remote {
    let repos = if $status {
      if ($domain | is-empty) {
        get_remote_repos $user --status --visibility $visibility
      } else {
        (
          get_remote_repos 
            $user
            --domain $domain 
            --status 
            --visibility $visibility
        )
      }
    } else {
      if ($domain | is-empty) {
        get_remote_repos $user --visibility $visibility
      } else {
        get_remote_repos $user --domain $domain --visibility $visibility
      }
    }

    return (
      $repos
      | table --index false
    )
  }

  let repos = if $status {
    if ($domain | is-empty) {
      get_local_repos --as-table --status --user $user
    } else {
      get_local_repos --as-table --domain (get_domain $domain) --status --user $user
    }
  } else {
    if ($domain | is-empty) {
      get_local_repos --as-table --user $user
    } else {
      get_local_repos --as-table --domain (get_domain $domain) --user $user
    }
  }

  return (
    $repos 
    | sort-by --ignore-case "user" "repo"
    | table --index false
  )
}

# Sync all repos
def "src sync" [] {
  print "Syncing repos..."

  get_local_repos
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

      print $"Synced \"($repo)/\""
    } | null
}
