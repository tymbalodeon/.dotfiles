use ./hosts.nu get_configuration

# List dependencies
export def main [
  host?: string # The target host configuration (auto-detected if not specified)
] {
  let configuration = (get_configuration $host)

  (
    nix eval
      $"($configuration).config.home.packages"
      --apply "builtins.map (p: p.name)"
  ) | split row " "
  | filter {|line| not ($line in ["[" "]"])}
  | each {
      |line|

      $line
      | str replace --all '"' ""
    }
  | sort
  | str join "\n"
}
