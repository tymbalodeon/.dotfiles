source ($nu.default-config-dir | path join cloud.nu)
source ($nu.default-config-dir | path join f.nu)
source ($nu.default-config-dir | path join fonts.nu)
source ($nu.default-config-dir | path join music.nu)
source ($nu.default-config-dir | path join src.nu)
source ($nu.default-config-dir | path join theme-function.nu)
source ($nu.default-config-dir | path join theme.nu)

$env.config = {
  color_config: $theme

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

let themes = (open ($nu.default-config-dir | path join "themes.toml"))
$env.FZF_DEFAULT_OPTS = ($themes | get FZF_DEFAULT_OPTS)

if not (which tinty | is-empty) {
  tinty apply ($themes | get shell_theme)
}
