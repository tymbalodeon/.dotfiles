use std assert

use ../readme.nu get-macos-recipes

let recipes = "
# Rollback to a previous generation
[macos]
@rollback *id:
    ../scripts/dotfiles/rollback.nu {{ id }}

# Open Nix REPL with flake loaded
[no-cd]
@shell *host:
    ./scripts/dotfiles/shell.nu {{ host }}
"

assert equal (get-macos-recipes $recipes) [rollback]
