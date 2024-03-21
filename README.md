# Dotfiles

## Installation

### Initial installation

NixOS:

(To see the available hosts, see the [hardware configurations](./linux/hardware-configurations).)

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#<HOST_NAME>
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

Requires [direnv](https://direnv.net/) and [nushell](https://www.nushell.sh/), which will be installed when following the [instructions](#installation) above.

```nu
cd ~/.dotfiles;
echo "use flake" | save --force .envrc;
direnv allow
```
