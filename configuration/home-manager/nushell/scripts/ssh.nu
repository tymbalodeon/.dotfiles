#!/usr/bin/env nu

def --wrapped main [...args: string] {
  if $env.TERM == xterm-kitty {
    kitten ssh ...$args
  } else {
    ssh ...$args
  }
}
