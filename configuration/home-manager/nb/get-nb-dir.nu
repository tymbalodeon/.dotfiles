export def get-nb-dir [] {
  let nb_home = ($env.HOME | path join .nb)

  $nb_home
  | path join (open ($nb_home | path join .current) | str trim)
}
