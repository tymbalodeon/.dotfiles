# Dotfiles

Personal "dotfile" configurations, managed with [Nix](https://nix.dev/).
Supports [NixOS](https://nixos.org/manual/nixos/stable/) and
[Darwin (macOS)](https://www.apple.com/macos/).

## Installation

_Note: The commands below assume that the repository is cloned to `~/.dotfiles`:_

```sh
git clone git@github.com:tymbalodeon/.dotfiles.git ~/.dotfiles
```

_(On non-NixOS systems only:)_ Install Nix using the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer).

### Initial build

NixOS:

(Available hosts can be found in
[hardware configurations](./nixos/hardware-configurations).)

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#<HOST>

# For example:
# sudo nixos-rebuild switch --flake ~/.dotfiles#ruzia
```

macOS:

```sh
nix run home-manager -- switch --flake ~/.dotfiles

# Or, for a "work" configuration
# nix run home-manager -- switch --flake ~/.dotfiles#work
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
just rebuild --hosts
```

## Development environment

Assuming you already have [direnv](https://direnv.net/),
[just](https://just.systems/man/en/), and [nushell](https://www.nushell.sh/)
installed (which you will after [installing](#installation) the configuration),
a development environment can be created by running:

```nushell
just init
```

Run `just` to see available "recipes," and `just <recipe> --help/-h` to get more
information about a particular recipe.

<!-- `just` start -->
```nushell
Available recipes:
(run `just <recipe> --help/-h` for more info)
    check *args              # Run pre-commit hooks
    deps *args               # List dependencies
    find-recipe *search_term # Search available `just` recipes
    generations *help        # View generations
    history *search_term     # Search project history
    hosts *help              # List available hosts
    init *help               # Initialize direnv environment
    issue *args              # View issues
    prune *older_than        # Collect garbage and remove old generations
    readme *help             # Update README command output
    rebuild *args            # Rebuild and switch to (or --test) a configuration
    remote *web              # View remote repository
    rollback *generation-id  # Rollback to a previous generation
    shell *host              # Open Nix REPL with flake loaded
    stats *help              # View repository analytics
    update *help             # Update dependencies
    view-source *recipe      # View the source code for a recipe
```
<!-- `just` end -->
