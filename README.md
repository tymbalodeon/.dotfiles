# Dotfiles

Personal "dotfile" configurations, managed with [Nix](https://nix.dev/).
Supports [NixOS](https://nixos.org/manual/nixos/stable/) and
[Darwin (macOS)](https://www.apple.com/macos/).

## Installation

_Note: The commands below assume that the repository is cloned to `~/.dotfiles`:_

```sh
git clone git@github.com:tymbalodeon/.dotfiles.git ~/.dotfiles
```

### Initial build

NixOS:

(Available hosts can be found in
[hardware configurations](./nixos/hardware-configurations).)

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#<HOST>

# For example:
# sudo nixos-rebuild switch --flake ~/.dotfiles#ruzia
```

Darwin:

Install Nix using the Determinate Systems
[Nix Installer](https://github.com/DeterminateSystems/nix-installer).

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
    annotate *filename       # View file annotated with version control information
    check *args              # Check flake and run pre-commit hooks
    clean *all               # Run `prune` and `optimise`
    deps *args               # List dependencies
    diff *args               # View the diff between hosts
    diff-env *args           # View the diff between environments
    find-recipe *search_term # Search available `just` recipes
    generations *help        # View generations
    help *recipe             # View help text
    history *args            # View project history
    hosts *help              # List available hosts
    init *help               # Initialize direnv environment
    issue *args              # View issues
    optimise *help           # Replace identical files in the Nix store by hard links
    prune *args              # Collect garbage and remove old generations
    rebuild *args            # Rebuild and switch to (or --test) a configuration
    release *args            # Create a new release
    remote *web              # View remote repository
    rollback *id             # Rollback to a previous generation
    shell *host              # Open Nix REPL with flake loaded
    stats *help              # View repository analytics
    update-deps *help        # Update dependencies
    view-source *recipe      # View the source code for a recipe
```

<!-- `just` end -->
