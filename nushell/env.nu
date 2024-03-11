use ($nu.default-config-dir | path join "colors.nu") *
use ($nu.default-config-dir | path join "prompt.nu") *

$env.PATH = (
    $env.PATH
    | append ($env.HOME | path join ".nix-profile/bin") 
    | append ($env.HOME | path join ".cargo/bin") 
    | append "/nix/var/nix/profiles/default/bin" 
    | uniq
)

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

