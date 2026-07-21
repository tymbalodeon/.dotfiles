#!/usr/bin/env nu

def main [address: string hostname?: string] {
  let key = if ($hostname | is-not-empty) {
    $"($address)-($hostname)"
  } else {
    $address
  }

  (
    pass-cli item view
      --item-title $key
      --output json
      --vault-name ".dotfiles"
    | from json
    | get item.content.content.Login.password
  )
}
