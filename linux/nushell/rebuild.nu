def get_flake_path [attribute] {
    return $"($env.HOME | path join ".dotfiles")#($attribute)"
}

# Rebuild and switch to (or --test) a configuration for (--hosts)
export def main [
    host?: string # The target host configuration (auto-detected if not specified)
    --hosts # List available hosts
    --test # Apply the configuration without adding it to the boot menu
] {

    if $hosts {
        return (
            nix eval (get_flake_path "nixosConfigurations")
                --apply builtins.attrNames
                err> /dev/null
            | str replace --all --regex '\[ | \]|"' ""
            | split row " "
            | str join "\n"
        )
    }

    let host_name = if ($host | is-empty) {
        cat /etc/hostname | str trim
    } else {
        $host
    }

    let host = get_flake_path $host_name

    if $test {
        sudo nixos-rebuild test --flake $host
    } else {
        sudo nixos-rebuild switch --flake $host
    }

    bat cache --build
}
