def main [] {
  open ($env.HOME | path join .config/sops-nix/secrets/gmail/password)
}
