#!/usr/bin/env nu

def main [...remotes: string] {
  let notebooks = (
    nb notebooks --path
    | lines
    | each {path parse | get stem}
  )

  print $notebooks

  # for remote in $remotes {
  #   print $remote
  # }
}
