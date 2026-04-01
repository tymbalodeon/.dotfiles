# Cd to the currently selected notebook
def --env "nb cd" [] {
  let nb_home = ($env.HOME | path join .nb)
  let current_notebook_file = ($nb_home | path join .current)

  let current_notebook = if ($current_notebook_file | path exists) {
    $nb_home
    | path join (open $current_notebook_file | str trim)
  } else {
    let home_notebook = ($nb_home | path join home)

    if not ($home_notebook | path exists) {
      mkdir $home_notebook
    }

    $home_notebook
  }

  cd $current_notebook
}
