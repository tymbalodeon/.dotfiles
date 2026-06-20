def --wrapped ssh [...args: string] {
  if $env.TERM == xterm-kitty {
    kitten ssh ...$args
  } else {
    ^ssh ...$args
  }
}
