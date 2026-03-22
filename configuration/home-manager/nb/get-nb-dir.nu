export def get-nb-dir [] {
  nb settings get nb_dir
  | path join (nb notebooks current)
}
