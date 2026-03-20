def main [] {
  help main
}

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

def edit [item: string] {
  ^$env.EDITOR (get-path $item)
}

# Edit ink records
export def "edit inks" [] {
  edit inks
}

# Edit pen records
export def "edit pens" [] {
  edit pens
}

# Clear the current ink record for a pen
export def empty [
  pen_id?: int # The id of the pen to update (choose interactively if left blank)
] {
  let pen_id = (get-pen $pen_id)

  if ($pen_id | is-empty) {
    return
  }

  update-currently-inked-file $pen_id
}

export def list [] {
  help list
}

# List empty pens
export def "list empty" [] {
  let currently_inked = (open-csv currently-inked)
  let currently_empty = ($currently_inked | where {$in."ink id" | is-empty})

  list pens
  | where {
      |pen|

      if $pen.index not-in $currently_inked."pen id" {
        return true
      }

      if ($currently_empty | is-empty) {
        return false
      }

      $pen.index == (
        $currently_empty
        | first
        | get "pen id"
      )
    }
}

# Show the inks currently recorded as being in each pen
export def "list inked" [] {
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
        pen: $"($pen.manufacturer) ($pen.'model name') \(($pen.style)\)"
        ink: $current_ink
      }
    }
  | flatten
  | sort-by ink
}

# Show ink collection
export def "list inks" [
  --interactive
] {
  open-csv inks $interactive
}

# List unused inks
export def "list inks unused" [] {
  let current_inks = (open-csv currently-inked)."ink id"

  ist inks
  | where {$in.index not-in $current_inks}
}


# Show pen collection
export def "list pens" [
  --interactive
] {
  open-csv pens $interactive
}

def display-pen []: record -> string {
  $"($in.index) ($in.manufacturer) ($in.'model name') ($in.'nib size') ($in.style)"
}

def display-ink []: record -> string {
  $"($in.index) ($in.manufacturer) ($in.'model name') ($in.'color family')"
}

def select-item [data: list<string>] {
  let item = (
    $data
    | to text
    | fzf
    | split words
  )

  if ($item | is-not-empty) {
    $item
    | first
    | into int
  }
}

def get-pen [pen_id?: int] {
  if ($pen_id | is-empty) {
    select-item (list pens | each {display-pen})
  } else {
    $pen_id
  }
}

def get-ink [ink_id?: int] {
  if ($ink_id | is-empty) {
    select-item (list inks | each {display-ink})
  } else {
    $ink_id
  }
}

def update-currently-inked-file [pen_id: int ink_id?: int] {
  let currently_inked_file = (get-path currently-inked)

  open $currently_inked_file
  | where 'pen id' != $pen_id
  | append {"pen id": $pen_id "ink id": $ink_id }
  | collect
  | save --force $currently_inked_file
}

# Update the current ink record for a pen
export def update [
  pen_id?: int # The id of the pen to update (choose interactively if left blank)
  ink_id?: int # The id of the ink to update to (choose interactively if left blank)
] {
  let pen_id = (get-pen $pen_id)

  if ($pen_id | is-empty) {
    return
  }

  let ink_id = (get-ink $ink_id)

  if ($ink_id | is-empty) {
    return
  }

  update-currently-inked-file $pen_id $ink_id
}

alias inked = list inked
alias inks = list inks
alias ls = list
alias pens = list pens
