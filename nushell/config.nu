source ($nu.default-config-dir | path join "aliases.nu")
source ($nu.default-config-dir | path join "functions.nu")
source ($nu.default-config-dir | path join "theme.nu")

$env.config = {
    color_config: (get_theme)

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
