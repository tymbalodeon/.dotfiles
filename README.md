# Dotfiles

## Installation

Assumes that the repository is cloned to `~/.dotfiles`:

```sh
git clone git@github.com:tymbalodeon/.dotfiles.git ~/.dotfiles
```

### Initial installation

NixOS:

(Available hosts can be found in [hardware configurations](./linux/hardware-configurations).)

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#<HOST_NAME>

# For example:
# sudo nixos-rebuild switch --flake ~/.dotfiles#ruzia
```

macOS:

```sh
nix run home-manager -- switch --flake ~/.dotfiles

# Or, for a "work" configuration
# nix run home-manager -- switch --flake ~/.dotfiles#work
```

### Subsequent installations

```sh
rebuild
```

## Development environment

After running the [initial installation](#initial-installation) and opening an interactive [nu](https://www.nushell.sh/) shell, a development environment managed by [direnv](https://direnv.net/) with:

```nu
cd ~/.dotfiles;
echo "use flake" | save --force .envrc;
direnv allow
```
