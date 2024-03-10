use ($nu.default-config-dir | path join "colors.nu") *

def create_left_prompt [] {
    let home =  $nu.home-path

    let dir = (
        if (
            $env.PWD 
            | path split 
            | zip ($home | path split) 
            | all { $in.0 == $in.1 }
        ) {
            ($env.PWD | str replace $home "~")
        } else {
            $env.PWD
        }
    )

    let path_color = (
        if (is-admin) { $red_bold } else { $blue_bold }
    )

    let separator_color = (
        if (is-admin) { $light_red_bold } else { $light_blue_bold }
    )

    let prompt = (
        $"($path_color)($dir)"
        | str replace --all 
            (char path_sep) 
            $"($separator_color)(char path_sep)($path_color)"
    ) 
    
    if (
        do --ignore-errors { git rev-parse --abbrev-ref HEAD } 
        | is-empty
    ) == false {
        let branch_info = git branch --list
        | lines
        | filter {|branch| $branch | str contains "*" }
        | each {|branch| $branch | str replace "* " ""}
        | get 0

        $"($prompt) ($branch_color)($branch_info)" + $"\n" + $"($green_bold)"   
     } else {
        $prompt + $"\n" + $"($green_bold)"    
    }
}

$env.BAT_THEME = "gruvbox-dark"
$env.EDITOR = "hx"

$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

$env.LS_COLORS = (vivid generate gruvbox-dark)
$env.NU_LIB_DIRS = [($nu.default-config-dir | path join 'scripts')]
$env.NU_PLUGIN_DIRS = [($nu.default-config-dir | path join 'plugins')]

$env.PATH = (
    $env.PATH
    | split row (char esep) 
    | append ($env.HOME | path join ".nix-profile/bin") 
    | append ($env.HOME | path join ".cargo/bin") 
    | append "/nix/var/nix/profiles/default/bin" 
    | uniq
)

$env.PROMPT_COMMAND = {|| create_left_prompt}
$env.PROMPT_COMMAND_RIGHT = {|| null}
$env.PROMPT_INDICATOR_VI_INSERT = {|| $"($prompt_insert_color)> "}

$env.PROMPT_INDICATOR_VI_NORMAL = {|| 
    $"($prompt_normal_color)>>($prompt_insert_color) " 
}

$env.PROMPT_MULTILINE_INDICATOR = {|| 
    $"($prompt_multiline_color):::($prompt_insert_color) "
}

