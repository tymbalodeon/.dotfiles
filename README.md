# Dotfiles

## Installation

_Note: The commands below assume that the repository is cloned to `~/.dotfiles`:_

```sh
git clone git@github.com:tymbalodeon/.dotfiles.git ~/.dotfiles
```

_(On non-NixOS systems only:)_ Install Nix using the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer).

### Initial build

NixOS:

(Available hosts can be found in
[hardware configurations](./linux/hardware-configurations).)

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

```nushell
rebuild # <HOST>

# For example:
# rebuild
# rebuild ruzia
```

```nushell
# To see available hosts:
rebuild --hosts
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
