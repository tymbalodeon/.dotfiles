#!/usr/bin/env nu

def make-command-comment [
  command: string
  --end
  --start
] {
  let type = if $end {
    "end"
  } else {
    "start"
  }

  $"<!-- `($command)` ($type) -->"
}

def make-command-regex [start: string end: string] {
  $"($start)\(.|\\s\)*($end)"
}

def make-command-output [
  start: string
  output: string
  end: string
] {
  $"($start)\n\n($output)\n\n($end)\n"
}

# Update README command output
def main [] {
  let just_start = (make-command-comment "just")
  let just_end = (make-command-comment "just" --end)

  let just_output = (
    $"```nushell\n(
        just | ansi strip
      )\n```"
  )

  let macos_recipes = (
    open just/dotfiles.just
    | split row "\n\n"
    | filter {
        |recipe|

        "macos" in $recipe
      }
    | each {
        |recipe|

        $recipe
        | split row "@"
        | last
        | split row " "
        | first
    }
  )

  let just_output = (
    $just_output
    | lines
    | filter {
        |line|

        (
          $line
          | str trim
          | split row " "
          | first
        ) not-in $macos_recipes
      }
    | str join "\n"
  )

  (
    open README.md
    | str replace
      --regex
      (make-command-regex $just_start $just_end)
      (make-command-output $just_start $just_output $just_end)
    | save --force README.md
  )
}
