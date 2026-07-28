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

def create-config-directory [] {
  let config_directory = (config-directory)

  mkdir $config_directory

  $config_directory
}


