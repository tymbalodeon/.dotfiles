def src [
  --clone: string # Clone repo at URL
  --list # List cloned repos
  --sync # Sync all repos
  --user: string # List cloned repos for user
] {
  let src_directory = ($env.HOME | path join "src")

  if not ($clone | is-empty) {
    let values = if (
      $clone
      | str starts-with "git@"
    ) {
      $clone 
      | split row "@" 
      | split row ":"
      | split row "/"
      | drop nth 0
    } else if (
      $clone
      | str starts-with "http"
    ) {
      $clone 
      | split row "://" 
      | split row "/"
      | drop nth 0
    } else {
      return "Unable to parse URL."
    }

    let target = (
      $src_directory
      | path join (
        $values | first
      ) | path join (
        $values | get 1
      ) | path join (
        $values | last | str replace ".git" ""    
      )
    ) 

    if not ($target | path exists) {
      git clone $clone $target 
    }

    return
  }

  let repos = (
    ls ($src_directory ++ "/**" | into glob)
    | filter {
        |item| 

        ($item.type == "dir") and (
          $item.name | path join ".git" | path exists
        )
      }
    | get name
  )

  if $sync {
    print "Syncing repos..."

    for repo in $repos {
      cd $repo

      let result = (git pull out> /dev/null | complete)

      if $result.exit_code != 0 {
        (
          print 
            --stderr 
            $"\nThere was a problem syncing \"($repo)\":\n\n($result.stderr)"
        )
      }

      print $"Synced ($repo)."
    }

    cd -
  }

  if $list {
    let repos = (
      $repos
      | each {
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

    let repos = if ($user | is-empty) {
      $repos
    } else {
      $repos | where user == $user
    }

    return ($repos | table --index false)
  }
}
