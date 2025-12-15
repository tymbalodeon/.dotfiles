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

def pens [
  --interactive
] {
  open-csv pens $interactive
}

def inks [
  --interactive
] {
  open-csv inks $interactive
}

def currently-inked [] {
  let inks = (open-csv inks)
  let currently_inked = (open-csv currently-inked)

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
        pen: $"($pen.manufacturer) ($pen.'model name')"
        ink: $current_ink
      }
    }
  | flatten
  | sort-by ink
}
