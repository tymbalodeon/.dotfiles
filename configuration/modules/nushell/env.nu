source ($nu.default-config-dir | path join "colors.nu")
source ($nu.default-config-dir | path join "prompt.nu")

$env.PATH = (
    $env.PATH
    | append "/nix/var/nix/profiles/default/bin"
    | append ($env.HOME | path join ".nix-profile/bin")
    | append ($env.HOME | path join ".cargo/bin")
    | append ($env.HOME | path join ".local/bin")
    | append "/usr/local/bin"
    | uniq
)

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

$env.LS_COLORS = (
    vivid generate ($env.HOME | path join ".config/vivid/themes/theme.yml")
)

$env.NU_LIB_DIRS = [($nu.default-config-dir | path join 'scripts')]
$env.NU_PLUGIN_DIRS = [($nu.default-config-dir | path join 'plugins')]

if (uname).kernel-name == "Darwin" {
    $env.SHELL = "nu"
}

# TODO: can this just be symlinked by Nix?
(
    zoxide init nushell
    | save --force ($nu.default-config-dir | path join "zoxide.nu")
)
