def shell [] {
  let configuration = if (uname | get operating-system) == "Darwin" {
    "homeConfigurations"
  } else {
    $"nixOsConfigurations.(cat /etc/hostname | str trim)"
  }

  let configuration = $".#($configuration)"

  nix --extra-experimental-features repl-flake repl $configuration
}
