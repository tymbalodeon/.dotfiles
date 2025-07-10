source ($nu.default-config-dir | path join "cloud.nu")
source ($nu.default-config-dir | path join "f.nu")
source ($nu.default-config-dir | path join "src.nu")
source ($nu.default-config-dir | path join "theme-function.nu")
source ($nu.default-config-dir | path join "theme.nu")

$env.config = {
    color_config: $theme

    hooks: {
        env_change: {
            PWD: [
                {||
                    if (which direnv | is-empty) {
                        return
                    }

                    direnv export json | from json | default {} | load-env
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
