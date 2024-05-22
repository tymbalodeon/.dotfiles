# Rebuild and switch to (or --test) a configuration for (--hosts)
def rebuild [
    host?: string # The target host configuration (auto-detected if not specified)
    --hosts # List available hosts
] {
    def get_flake_path [attribute] {
        let dotfiles = ($env.HOME | path join ".dotfiles")

        $"($dotfiles)#($attribute)"
    }

    if $hosts {
        return (
            nix eval (get_flake_path "homeConfigurations") --apply builtins.attrNames
            | str replace --all --regex '\[ | \]|"' ""
            | split row " "
            | str join "\n"
        )
    }

    let host_name = if ($host | is-empty) {
        "benrosen"
    } else {
        $host
    }

    let host = get_flake_path $host_name

    home-manager switch --flake $host

    bat cache --build
}
