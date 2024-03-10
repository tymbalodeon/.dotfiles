let bg = "#282828"
let red = "#cc241d" 
let green = "#98971a"
let yellow = "#d79921"
let blue = "#458588"
let purple = "#b16286"
let aqua = "#689d6a"
let gray = "#a89984"

let gray_bright = "#928374"
let red_bright = "#fb4934"
let green_bright = "#b8bb26"
let yellow_bright = "#fabd2f"
let blue_bright = "#83a598"
let purple_bright = "#d3869b"
let aqua_bright = "#8ec07c"
let fg = "ebdbb2"

let bg0_h = "#1d2021"
let bg0 = $bg
let bg1 = "#3c3836"
let bg2 = "#504945"
let bg3 = "#665c54"
let bg4 = "#7c6f64"
let orange = "#d65d0e"

let bg0_s = "#32302f"
let fg4 = "#a89984" 
let fg3 = "#bdae93"
let fg2 = "#d5c4a1"
let fg1 = $fg
let fg0 = "#fbf1c7"
let orange_bright = "#fe8019"

def create_left_prompt [] {
    let home =  $nu.home-path

    let dir = (
        if ($env.PWD | path split | zip ($home | path split) | all { $in.0 == $in.1 }) {
            ($env.PWD | str replace $home "~")
        } else {
            $env.PWD
        }
    )

    let red_bold = ansi --escape { fg: $red attr: b}
    let blue_bold = ansi --escape { fg: $blue attr: b}
    let light_red_bold = { fg: $red_bright attr: b}
    let light_blue_bold = { fg: $blue_bright attr: b}
    let green_bold = ansi --escape { fg: $green attr: b}
    let branch_color = ansi --escape { fg: $gray }

    let path_color = (
        if (is-admin) { $red_bold } else { $blue_bold }
    )

    let separator_color = (
        if (is-admin) { ansi --escape $light_red_bold } else { ansi --escape $light_blue_bold }
    )

    let prompt = (
        $"($path_color)($dir)"
        | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
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

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| null }

let prompt_insert_color = ansi --escape { fg: $green }
let prompt_normal_color = ansi --escape { fg: $yellow }
let prompt_multiline_color = ansi --escape { fg: $gray }

# The prompt indicators are environmental variables that represent
# the state of the prompt
# $env.PROMPT_INDICATOR = {|| $"($prompt_normal_color)--($prompt_insert_color) " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| $"($prompt_insert_color)> " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| $"($prompt_normal_color)>>($prompt_insert_color) " }
$env.PROMPT_MULTILINE_INDICATOR = {|| $"($prompt_multiline_color):::($prompt_insert_color) " }

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
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

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # FIXME: This default is not implemented in rust code as of 2023-09-06.
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    # FIXME: This default is not implemented in rust code as of 2023-09-06.
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

$env.BAT_THEME = "gruvbox-dark"
$env.EDITOR = "hx"

$env.PATH = [
    /Users/benrosen/.nix-profile/bin
    /usr/local/opt/llvm/bin
    /Users/benrosen/.cargo/bin
    /Users/benrosen/Library/pnpm
    /Users/benrosen/.emacs.d/bin
    /Applications/kitty.app/Contents/MacOS
    /Users/benrosen/.local/bin
    /usr/local/bin
    /nix/var/nix/profiles/default/bin
] ++ $env.PATH

$env.LS_COLORS = (vivid generate gruvbox-dark)
