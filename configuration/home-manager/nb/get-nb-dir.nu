export def get-nb-dir [] {
  const NB_HOME = "~/.nb"

  $NB_HOME
  | path join (open ($NB_HOME | path join .current) | str trim)
}
