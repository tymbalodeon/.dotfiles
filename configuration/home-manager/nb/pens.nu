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

# Show the inks currently recorded as being in each pen
def "fountain pens list inked" [] {
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
def "fountain pens list inks" [
  --interactive
] {
  open-csv inks $interactive
}

# Show pen collection
def "fountain pens list pens" [
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
    select-item (pens | each {display-pen})
  } else {
    $pen_id
  }
}

def get-ink [ink_id?: int] {
  if ($ink_id | is-empty) {
    select-item (inks | each {display-ink})
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
def "fountain pens update" [
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

# Clear the current ink record for a pen
def "fountain pens empty" [
  pen_id?: int # The id of the pen to update (choose interactively if left blank)
] {
  let pen_id = (get-pen $pen_id)

  if ($pen_id | is-empty) {
    return
  }

  update-currently-inked-file $pen_id
}

alias "fp empty" = fountain pens empty
alias "fp update" = fountain pens update
alias "inked" = fountain pens list inked
alias "inks" = fountain pens list inks
alias "pens" = fountain pens list pens
