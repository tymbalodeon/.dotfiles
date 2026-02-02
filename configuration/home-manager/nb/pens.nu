def get-path [name: string] {
  nb --path $"($name).csv"
  | ansi strip
  | split row " "
  | last
}

def open-csv [name: string interactive = false] {
  let path = (get-path $name)

  if $interactive {
    nb csv $path
  } else {
    open $path
  }
}

# Show pen collection
def pens [
  --interactive
] {
  open-csv pens $interactive
}

# Show ink collection
def inks [
  --interactive
] {
  open-csv inks $interactive
}

# Show the inks currently recorded as being in each pen
def currently-inked [
  --raw # Display as raw text instead of a nushell table
] {
  let inks = (open-csv inks)
  let currently_inked = (open-csv currently-inked)

  let currently_inked = (
    open-csv pens
    | each {
        |pen|

        let current_ink = try {
          let current_ink = (
            $inks
            | where index == (
                $currently_inked
                | where "pen id" == $pen.index
                | first
                | get "ink id"
              )
            | first
          )

          $"($current_ink.manufacturer) ($current_ink.'model name')"
        } catch {
          ""
        }

        {
          pen: $"($pen.manufacturer) ($pen.'model name') \(($pen.style)\)"
          ink: $current_ink
        }
      }
    | flatten
    | sort-by ink
  )

  if $raw {
    $currently_inked
    | each {|pen| $"($pen.pen) | ($pen.ink)"}
    | to text --no-newline
    | column -t -s "|"
  } else {
    $currently_inked
  }
}
