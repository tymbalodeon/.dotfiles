# Cd to the `nb`home  directory
def --env "nb cd" [] {
  cd (nb settings get nb_dir)
}
