source ($nu.default-config-dir | path join cloud.nu)
source ($nu.default-config-dir | path join f.nu)
source ($nu.default-config-dir | path join fonts.nu)
source ($nu.default-config-dir | path join music.nu)
source ($nu.default-config-dir | path join src.nu)

$env.config = {
  hooks: {
    env_change: {
      PWD: [
        {
          # TODO: auto-pull from https://github.com/nushell/nu_scripts/blob/main/nu-hooks/nu-hooks/direnv/config.nu

          if (which direnv | is-empty) {
            return
          }

          direnv export json
          | from json
          | default {}
          | load-env

          $env.PATH = ($env.PATH | split row (char env_sep))
        }
      ]
    }
  }
}

