def main [] {
  print (remotes)

  # let nb_home = "$env.HOME/.nb"

  # mkdir $nb_home

  # let notebooks = (ls $nb_home)

  # for remote in (remotes | enumerate) {
  #   let name = if $remote.index == 0 {
  #     "home"
  #   } else {
  #     $"($remote.item)"
  #     | str replace --all --regex "(git@|.com|.git)" ""
  #     | split row --regex "(/|:)"
  #     | str join "-"
  #   }

  #   if ($name | not-in $notebooks) {
  #     let directory = ($nb_home | path join $name)

  #     mkdir $directory
  #     cd $directory

  #     git init
  #     git remote add origin $remote

  #     # TODO: add an option to specify the branch if it's not "trunk"
  #     git branch -m trunk
  #   }
  # }
}
