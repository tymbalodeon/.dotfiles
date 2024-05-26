source ($nu.default-config-dir | path join "aliases.nu")
use ($nu.default-config-dir | path join "cloud.nu")
use ($nu.default-config-dir | path join "f.nu")
use ($nu.default-config-dir | path join "theme-function.nu")
source ($nu.default-config-dir | path join "theme.nu")

$env.config = {
    color_config: $theme

    cursor_shape: {
        vi_insert: line
        vi_normal: block
    }

    datetime_format: { normal: '%A, %B %d, %Y %H:%M:%S' }
    edit_mode: vi

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

    show_banner: false
}

let themes = (open ($nu.default-config-dir | path join "themes.toml"))
$env.FZF_DEFAULT_OPTS = ($themes | get FZF_DEFAULT_OPTS)

if not (which tinty | is-empty) {
    tinty apply ($themes | get shell_theme)
}


source ($nu.default-config-dir | path join "zoxide.nu")
