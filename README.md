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
[/configuration/kernels/nixos/hosts](./configuration/kernels/nixos/hosts).)

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
installed (which you will after [installing](#Installation) the configuration),
a development environment can be activated using
[https://github.com/tymbalodeon/environments](environments) by running:

```nushell
just env activate
```

Run `just` to see available "recipes," and `just <recipe> --help/-h` to get more
information about a particular recipe.

<!-- `just` start -->

````nushell
Available recipes:
    check *args              # Check flake and run pre-commit hooks
    clean *all               # alias for `dotfiles clean`
    dependencies *args       # List dependencies (alias: `deps`) [alias: deps]
    diff *args               # alias for `dotfiles diff`
    environment *args        # Manage environments [alias: env]
    files *configuration     # alias for `dotfiles files`
    find-recipe *search_term # Search available `just` recipes [alias: find]
    generations *help        # alias for `dotfiles generations`
    help *recipe             # View help text
    history *args            # View project history
    hosts *help              # alias for `dotfiles hosts`
    inputs *help             # alias for `dotfiles inputs`
    issue *args              # View issues
    optimise *help           # alias for `dotfiles optimise`
    prune *args              # alias for `dotfiles prune`
    rebuild *args            # alias for `dotfiles rebuild`
    release *preview         # Create a new release
    remote *web              # View remote repository
    rollback *id             # alias for `dotfiles rollback`
    shell *host              # alias for `dotfiles shell`
    stats *help              # View repository analytics
    test *args               # Run tests
    update *help             # alias for `dotfiles update`
    view-source *recipe      # View the source code for a recipe [alias: src]
    dotfiles:
        clean *all           # Run `prune` and `optimise`
        diff *args           # View the diff between hosts
        files *configuration # List configuration files
        generations *help    # View generations
        help *recipe         # View help text
        hosts *help          # List available hosts
        inputs *help         # List flake inputs
        optimise *help       # Replace identical files in the Nix store by hard links
        prune *args          # Collect garbage and remove old generations
        rebuild *args        # Rebuild and switch to (or --test) a configuration
        rollback *id         # Rollback to a previous generation
        shell *host          # Open Nix REPL with flake loaded
        update *help         # Update dependencies```
````

<!-- `just` end -->
