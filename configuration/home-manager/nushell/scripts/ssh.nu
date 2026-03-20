#!/usr/bin/env nu

export def --wrapped main [...args: string] {
  if $env.TERM == xterm-kitty {
    kitten ssh ...$args
  } else {
    ssh ...$args
  }
}
