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
      | parse "{domain}/{user}/{repo}.git"
    } else if ($origin | str starts-with "ssh://") {
      $origin
      | parse "ssh://git@{domain}/{user}/{repo}"
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

def get_visibility [path: string] {
  print $"Checking remote visibility for ($path)..."

  cd $path

  let origin = (git remote get-url origin err> /dev/null)

  let visibility = (
    if "github" in $origin {
      gh repo view --json visibility
      | from json
      | get visibility
    } else if "gitlab" in $origin {
      glab repo view --output json err> /dev/null
      | from json
      | get visibility
    }
  )

  return (
    if ($visibility | is-empty) {
      $visibility
    } else {
      $visibility
      | str downcase
    }
  )
}

def get_remote_domain [path: string] {
  if ($path | path exists) {
    cd $path

    let origin = (git remote get-url origin)

    return (get_domain $origin)
  }
}

def get_local_repo_paths [args: record] {
  let glob = if ($args.domain | is-empty) {
    "/**"
  } else {
    $"/($args.domain)/**"
  }

  let glob = if ($args.user | is-empty) {
    $glob
  } else {
    $"($glob)/($args.user)/*"
  }

  let repos = (
    try {
      (
        glob
          --exclude [**/.git/**]
          --no-file
          $"\(?i\)(get_src_directory)($glob)"
      )
    } catch {
      return []
    }
  )

  let dotfiles = ($env.HOME | path join ".dotfiles")

  let repos = if ($args.domain | is-empty) or (
    $args.domain == (get_remote_domain $dotfiles.name)
  ) {
    $repos
    | append $dotfiles
  } else {
    $repos
  }

  return (
    $repos
    | filter {
        |item|

        (
          (($item | path type) == "dir")
          and (
            $item
            | path join ".git"
            | path exists
          )
        )
      }
  )
}

def get_local_repos [args: record] {
  let repos = (
      get_local_repo_paths $args
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

          let repo_data = if ($origin | str starts-with "git@") or (
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
          } | insert path $repo

          let repo_data = if (
            not ($args.include_status | is-empty) and (
              $args.include_status == true
            )
          ) {
            $repo_data
            | insert "synced" (is_synced $repo_data)
          } else {
            $repo_data
          }

          let repo_data = if not ($args.visibility | is-empty) or (
            $args.include_visibility == true
          ) {
            $repo_data
            | insert "visibility" (get_visibility $repo)
          } else {
            $repo_data
          }

          $repo_data
        }
      | filter {
          |repo|

          (
            ($args.user | is-empty) or (
              ($repo.user | str downcase) == ($args.user | str downcase)
            )
          ) and (
            ($args.visibility | is-empty) or ($repo.visibility == $args.visibility)
          )
        }
  )

  return (
    if $args.paths {
      $repos
      | get path
    } else {
      $repos
      | reject path
    }
  )
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
    ) or (($repo | get $column) =~ $search_repo_column)
  )
}

def choose_from_list [options: list] {
  return (
    $options
    | to text
    | fzf --exact --scheme path
  )
}

def parse_repo_path [path: string] {
  return (
    if ($path | path basename) == ".dotfiles" {
      cd $path
      parse_git_url (git remote get-url origin)
    } else {
      $path
      | path parse
      | reject extension
      | insert user ($in.parent | path basename)
      | insert domain ($in.parent | path dirname | path basename)
      | reject parent
      | rename --column {stem: repo}
    }
  )
}

def parse_repo_path_path [repo: record] {
  return (
    if $repo.repo == ".dotfiles" {
      $env.HOME
      | path join $repo.repo
    } else {
      get_src_directory
      | path join $repo.domain
      | path join $repo.user
      | path join $repo.repo
    }
  )
}

# Change directory to a repo
def --env "src cd" [
  repo?: string # The repo name
  --domain: string # The domain
  --me # `cd` to the current user's repos (GitHub, if exists, else GitLab)
  --no-ls # Don't list directory contents
  --search # Search the `src` directory interactively
  --user: string # The username
] {
  let user = if not ($user | is-empty) {
    $user
  } else if $me {
    let github_user = (get_remote_user "github")

    if ($github_user | is-empty) {
      get_remote_user "gitlab"
    } else {
      $github_user
    }
  } else {
    ""
  }

  if $search {
    let files = (
      fd --max-depth 3 --type dir $user (get_src_directory)
      | lines
    )

    let files = if $me {
      $files
      | each {|path| fd --type dir "" $path | lines}
      | flatten
    } else {
      $files
    }

    cd (choose_from_list $files)

    return (if $no_ls { null } else { ls })
  }

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
          | filter {|found_user| ($found_user | path basename) =~ $user}
        )

        if not ($matching_users | length | into bool) {
          return
        }

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
      return $"\"($directory)/\" does not exist."
    }

    return (if $no_ls { null } else { ls })
  }

  let search_repo = {
    domain: $domain
    user: $user
    repo: $repo
  }

  let args = {
    domain: $domain
    paths: false
    user: $user
    include_status: null
    include_visibility: null
    visibility: null
  }

  let matching_repos = (
    get_local_repos $args
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
      parse_repo_path_path $repo
    }

    cd $repo_path
  } else if ($matching_repos | length | into bool) {
    let matching_repo = (choose_from_list $matching_repos)

    if ($matching_repo | path exists) {
      cd $matching_repo
    } else {
      return
    }
  } else {
    return
  }

    return (if $no_ls { null } else { ls })
}

def is_synced [repo: record] {
  let path = (parse_repo_path_path $repo)

  print $"Checking sync status for ($path)..."

  if not ($path | path exists) {
    return false
  }

  cd $path

  let default_branch = try {
    git remote show origin err> /dev/null
    | rg "HEAD branch: "
    | split row ": "
    | last
  } catch {
    ""
  }

  if ($default_branch | is-empty) {
    return null
  }

  let current_branch = (git branch --show-current)

  if $current_branch != $default_branch {
    if not (git status --short | is-empty) {
      return $"(ansi r)dirty"
    }

    git checkout $default_branch
  }

  let status = (git fetch --dry-run | is-empty)

  if $current_branch != $default_branch {
    git checkout $current_branch
  }

  return $status
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

def get_github_repos [
  user?: string
  visibility?: string
] {
  let repos = (
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
  )
  return (
    $repos
    | from json
    | select owner name
    | par-each {
        |repo|

        {
          domain: "github.com"
          user: $repo.owner.login
          repo: $repo.name
        }
      }
  )
}

def get_gitlab_repos [
  user?: string
  visibility?: string
] {
  let remote_user =  (get_remote_user "gitlab")

  let user = if ($user | is-empty) {
    $remote_user
  } else {
    $user
  }

  if $user != $remote_user {
    return
  }

  return (
    glab repo list err> /dev/null
    | lines
    | filter {|line| $line | str starts-with $remote_user}
    | par-each {
        |repo|

        let repo = (
          $repo
          | str trim | split row "\t"
          | first
        )

        let data = ($repo | split row "/")

        {
          domain: "gitlab.com"
          user: ($data | first)
          repo: ($data | last)
        }
      }
  )
}

def get_remote_repos [args: record] {
  let repos = if $args.domain == "github" {
    get_github_repos $args.user $args.visibility
  } else if $args.domain == "gitlab" {
    get_gitlab_repos $args.user $args.visibility
  } else {
    get_github_repos $args.user $args.visibility
    | append (get_gitlab_repos $args.user $args.visibility)
  }

  return (
    $repos
    | par-each {
        |repo|

        if $args.include_status {
          $repo
          | insert "synced" (is_synced $repo)
        } else {
          $repo
        }

        if $args.include_visibility {
          $repo
          | insert "visibility" (
              if ($args.visibility | is-empty) {
                get_visibility $repo
              } else {
                $args.visibility
              }
            )
        } else {
          $repo
        }
      }
    | sort-by --ignore-case "repo"
  )
}

def get_domain [domain?: string] {
  if ($domain | is-empty) {
    return
  }

  if "github" in $domain {
    return "github.com"
  } else if "gitlab" in $domain {
    return "gitlab.com"
  } else {
    let available_domains = (
      ["github.com" "gitlab.com"]
      | filter {|available_domain| $available_domain =~ $domain}
    )

    if not ($available_domains | length | into bool) {
      return
    } else if ($available_domains | length) == 1 {
      return ($available_domains | first)
    }

    let domain = (choose_from_list $available_domains)

    if ($domain | is-empty) {
      return
    } else {
      return $domain
    }
  }
}

# Clone repo at URL
def --env "src clone" [
  repo?: string # The name or URL of the repo to clone
  --domain: string = "github" # Clone repos at this domain
  --no-ls # Don't list directory contents
  --user: string # Clone repos for user
  --visibility: string # Limit to public or private repos
] {
  if ($repo | is-empty) {
    let args = {
      domain: $domain
      user: $user
      visibility: $visibility
    }

    let repos = (get_remote_repos $args)

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

    return (if $no_ls { null } else { ls })
  }

  let repo_data = if (
    ($repo | str starts-with "git@") or not (
      $repo
      | find --regex "https?://"
      | is-empty
    ) or (
      $repo
      | str starts-with "ssh://"
    )
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
      gh repo clone $"($repo_data.user)/($repo_data.repo)" $target
    } else if "gitlab" in $domain {
      glab repo clone $"($repo_data.user)/($repo_data.repo)" $target
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
def --env --wrapped "src new" [
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

def get_remote_users [] {
  return (
    ["github" "gitlab"]
    | each {|domain| git config $"($domain).user"}
  )
}

# List repos
def "src list" [
  --remote # List remote repos
  --domain: string # List repos at this domain
  --include: list<string> # Include columns in the output [status, visibility]
  --me # List only repos belonging to the current user
  --paths # List local paths
  --sort-by: list<string> # Sort the output by these columns
  --urls # List remote URLs
  --user: string # List repos for user
  --visibility: string # Limit to public or private repos
] {
  let include_status = (
    not ($include | is-empty) and ("status" in $include)
  )

  let include_visibility = (
    not ($include | is-empty) and ("visibility" in $include)
  )

  let repos = if $remote {
    let args = {
      domain: $domain
      include_status: $include_status
      include_visibility: $include_visibility
      user: $user
      visibility: $visibility
    }

    get_remote_repos $args
  } else {
    let args = {
      paths: $paths
      domain: (get_domain $domain)
      include_status: $include_status
      include_visibility: $include_visibility
      user: $user
      visibility: $visibility
    }

    get_local_repos $args
  }

  if $paths and not $remote {
    return (
      $repos
      | to text
      | ^sort --ignore-case
    )
  }

  let repos = if $include_visibility {
    $repos
  } else if "visibility" in ($repos | columns) {
    $repos
    | reject visibility
  } else {
    $repos
  }

  let repos = if $me {
    let users = (get_remote_users)

    $repos
    | filter {|repo| $repo.user in $users}
  } else {
    $repos
  }

  let sort_by = if ($sort_by | is-empty) {
    [domain user repo]
  } else {
    $sort_by
  }


  return (
    $repos
    | sort-by --ignore-case ...$sort_by
    | table --index false
  )
}

# Sync all repos
def "src sync" [
  --clone # clone repos that don't exist locally
  --domain: string # Sync repos at this domain
  --me # Sync only repos belonging to the current user
  --user: string # Sync repos for this user
  --visibility: string # Sync only private or public repos
] {
  let args = {
    paths: true
    domain: (get_domain $domain)
    include_status: null
    user: $user
    visibility: $visibility
  }

  let repos = (get_local_repos $args)

  if ($repos | length | into bool) {
    print "Syncing repos..."
  }

  let repos = (
    if $me {
      let users = (get_remote_users)

      $repos
      | filter {
          |repo|

          ($repo | path dirname | path basename) in $users
        }
    } else {
      $repos
    }
  )

  let synced_repos = (
    $repos
    | par-each {
        |repo|
        cd $repo

        let result = (git pull out> /dev/null | complete)

        if $result.exit_code != 0 {
          print --stderr $"(ansi y)Skipping \"($repo)\"(ansi reset)"
        }

        print $"Synced \"($repo)/\""

        parse_repo_path $repo
      }
  )

  if $clone {
    for repo in (
      let args = {
        domain: $domain
        user: $user
        visibility: $visibility
      }

      (
        get_remote_repos $args
        | filter {|repo| not ($repo in $synced_repos)}
      )
    ) {
      (
        src clone
          $repo.repo
          --domain $repo.domain
          --user $repo.user
      )
    }
  }
}

# TODO change `repo?` to `repo`
def "src remove" [repo?: string] {
  print "Implement me!"
}

def src [] {
  help src
}
