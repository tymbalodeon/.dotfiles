export def get-nb-dir [] {
  nb settings get nb_dir
  | path join (open ~/.nb/.current | str trim)
}
