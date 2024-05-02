# Dotfiles

## Installation

_Note: The commands below assume that the repository is cloned to `~/.dotfiles`:_

```sh
git clone git@github.com:tymbalodeon/.dotfiles.git ~/.dotfiles
```

### Initial installation

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

# To see available hosts:
rebuild --hosts

# For example:
# rebuild
# rebuild work
```

## Development environment

After running the [initial installation](#initial-installation) and opening
an interactive [nu](https://www.nushell.sh/) shell, a development environment
managed automatically by [direnv](https://direnv.net/) can be created with:

```nushell
cd ~/.dotfiles;
echo "use flake" | save --force .envrc;
direnv allow
```
