#!/usr/bin/env nu

def --wrapped main [...args: string] {
  {
    password: (
      open ($env.HOME | path join .config/sops-nix/secrets/gmail/password)
    )
  }
  | to text
}
