#!/usr/bin/env nu

def main [hostname: string] {
  (
    pass-cli item view
      --item-title $"protonmail-bridge-($hostname)"
      --output json
      --vault-name ".dotfiles"
    | from json
    | get item.content.content.Login.password
  )
}
