def main [] {
  let nb_home = ($env.HOME | path join .nb)

  mkdir $nb_home

  let notebooks = (ls $nb_home | get name)

  for remote in (remotes | enumerate) {
    let name = if $remote.index == 0 {
      "home"
    } else {
      $"($remote.item)"
      | str replace --all --regex "(git@|.com|.git)" ""
      | split row --regex "(/|:)"
      | str join "-"
    }

    if $name not-in $notebooks {
      let directory = ($nb_home | path join $name)

      mkdir $directory
      cd $directory

      git init

      try {
        git remote add origin $remote.item

        # TODO: add an option to specify the branch if it's not "trunk"
        git branch -m trunk
      }
    }
  }
}
