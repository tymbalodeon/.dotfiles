export def main [...args: string] {
  ^nb ...$args
}

# Cd to the `nb` home  directory
export def --env cd [] {
  ^cd (nb settings get nb_dir | path join (nb notebooks current))
}

