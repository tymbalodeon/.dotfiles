# Dotfiles

Personal "dotfile" configurations, managed with [Nix](https://nix.dev/).
Supports [NixOS](https://nixos.org/manual/nixos/stable/) and
[Darwin (macOS)](https://www.apple.com/macos/).

## Installation

```sh
git clone git@github.com:tymbalodeon/.dotfiles.git ~/.dotfiles
```

### Initial build

NixOS:

(Available hosts can be found in
[/configuration/systems/nixos/hosts](./configuration/systems/nixos/hosts).)

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#<HOST>

# For example:
# sudo nixos-rebuild switch --flake ~/.dotfiles#ruzia
```

Darwin:

Install Nix using the Determinate Systems
[Nix Installer](https://github.com/DeterminateSystems/nix-installer).

```sh
nix run "nix-darwin/master#darwin-rebuild" -- switch --flake ~/.dotfiles/configuration#benrosen
```

### Subsequent builds

Subsequent builds can be handled with a [just](https://just.systems/man/en/)
recipe from the included `Justfile`:

```nushell
just rebuild # <HOST>

# For example:
# just rebuild
# just rebuild ruzia
```

```nushell
# To see available hosts on the current system:
just hosts
```

## Development environment

Assuming you already have [direnv](https://direnv.net/),
[just](https://just.systems/man/en/), and [nushell](https://www.nushell.sh/)
installed (which you will after [installing](#installation) the configuration),
a development environment can be activated using
[environments](https://github.com/tymbalodeon/environments) by running:

```nushell
just env activate
```

Run `just` to see available "recipes," and `just <recipe> --help/-h` to get more
information about a particular recipe.

<!-- `just` start -->

```nushell
Available recipes:
    check *args       # Check flake and run pre-commit hooks
    environment *args # Manage environments [alias: env]
    find-recipe *args # Search available `just` recipes [alias: find]
    help *args        # View full help text, or for a specific recipe
    history *args     # View project history
    issue *args       # View issues
    remote *args      # View remote repository
    replace *args     # Find/replace
    stats *args       # View repository analytics
    theme *args       # Set helix theme
    todo *args        # List TODO-style comments [alias: todos]
    view-source *args # View the source code for a recipe [alias: src]
    dotfiles: [alias: dot]
        check *args          # Check configuration flake
        clean *args          # Run `prune` and `optimise` [main alias]
        configurations *args # List available configurations [alias: configs] [main alias]
        diff *args           # View the diff between hosts [main alias]
        files *args          # List configuration files [main alias]
        generations *help    # View generations [main alias]
        help *args           # View help text
        inputs *help         # List flake inputs [main alias]
        optimise *help       # Replace identical files in the Nix store by hard links [main alias]
        prune *args          # Collect garbage and remove old generations [main alias]
        rebuild *args        # Rebuild and switch to (or --test) a configuration [main alias]
        shell *help          # Open Nix REPL with flake loaded
        update *inputs       # Update dependencies [main alias]

    haskell: [alias: hs]
        help # View help text

    nix:
        help *args  # View help text
        shell *args # Open an interactive nix shell
```

<!-- `just` end -->
