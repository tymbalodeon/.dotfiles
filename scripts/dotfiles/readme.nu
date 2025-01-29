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

  return $"<!-- `($command)` ($type) -->"
}

def make-command-regex [start end] {
  return $"($start)\(.|\\s\)*($end)"
}

def make-command-output [
  start: string
  output: string
  end: string
] {
  return $"($start)\n\n($output)\n\n($end)\n"
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

  (
    open README.md
    | str replace
      --regex
      (make-command-regex $just_start $just_end)
      (make-command-output $just_start $just_output $just_end)
    | save --force README.md
  )
}
