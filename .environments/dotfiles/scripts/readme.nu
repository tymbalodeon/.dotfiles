#!/usr/bin/env nu

export def get-macos-recipes [justfile: string] {
  $justfile
  | split row "\n\n"
  | where {
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
}

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
  let just_output = (
    $"```nushell\n(
        just | ansi strip
      )\n```"
  )

  let macos_recipes = (get-macos-recipes (open just/dotfiles.just))

  let just_output = (
    $just_output
    | lines
    | where {
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

  let just_start = (make-command-comment "just")
  let just_end = (make-command-comment "just" --end)

  (
    open README.md
    | str replace
      --regex
      (make-command-regex $just_start $just_end)
      (make-command-output $just_start $just_output $just_end)
    | lines
    | str join "\n"
    | save --force README.md
  )
}
