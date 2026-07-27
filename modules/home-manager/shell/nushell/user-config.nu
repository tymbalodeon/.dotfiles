def config-directory [] {
  let base = try {
    $env.XDG_CONFIG_HOME
  } catch {
    $env.HOME | path join ".config"
  }

  $base
  | path join (whoami)
}

def get-config-file [script: string] {
  config-directory
  | path join $"($script).toml"
}

def create-config-dir [] {
  let config_dir = (user-config config-directory)

  mkdir $config_dir

  $config_dir
}


