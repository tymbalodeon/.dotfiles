def is-inside-notebook [] {
  let zk_directory = ".zk"
  mut current_directory = (pwd)

  while $current_directory != $env.HOME {
    if (
      $current_directory
      | path join $zk_directory
      | path type
    ) == dir {
      return true
    }

    cd ..

    $current_directory = (pwd)
  }

  return false
}

def --wrapped zk [...args: string] {
  if not (is-inside-notebook) {
    note cd
  }

  SHELL=$"(^which bash)" ^zk ...$args
}

def get-current-notebook-path [] {
  let nb_home = ($env.HOME | path join .nb)
  let current_notebook_file = ($nb_home | path join .current)

  if ($current_notebook_file | path exists) {
    $nb_home
    | path join (open $current_notebook_file | str trim)
  } else {
    let home_notebook = ($nb_home | path join home)

    if not ($home_notebook | path exists) {
      mkdir $home_notebook
    }

    $home_notebook
  }
}

def sync-zk-directory [] {
  if (
    git -C (get-current-notebook-path) status --short
    | is-not-empty
  ) {
    job spawn { nb sync } out+err> /dev/null
  }
}

def --wrapped note [...args: string] {
  if ($args | is-empty) {
    note edit
  } else {
    zk ...$args
  }
}

def get-note-title [title: list<string>] {
  $title
  | str join " "
}

def get-note [title: list<string>] {
  (
    note list
      --format "{{path}}"
      --limit 1
      --match $"title: (get-note-title $title)"
      --no-pager
      err> /dev/null
    | str trim
  )
}

# Cd to the notes directory
def --env "note cd" [] {
  cd (get-current-notebook-path)
}

# Edit notes
def "note edit" [...search_terms: string] {
  if ($search_terms | is-empty) {
    zk edit --interactive
  } else {
    let note = (get-note $search_terms)

    if ($note | is-empty) {
      zk edit --match ...$search_terms --interactive
    } else {
      zk edit $note
    }
  }

  sync-zk-directory
}

# Create or edit the current day's journal entry
def "note journal" [] {
  let working_dir = (get-current-notebook-path)
  let journal = ($working_dir | path join journal)

  mkdir $journal
  zk new $journal --no-input --working-dir $working_dir
  sync-zk-directory
}

# Interactively select a journal entry to edit
def "note journal edit" [] {
  ^zk edit --interactive --tag journal
}

# List journal entries
def "note journal list" [] {
  note list --tag journal
}

alias "note journal ls" = note journal list

# Show links for notes
def "note links" [...title: string] {
  let note = (get-note $title)

  let note = if ($note | is-empty) {
    $title
    | first
  } else {
    $note
  }

  ^zk edit --interactive --link-to $note err> /dev/null
}

# Add new note
def "note new" [...title: string] {
  let title = (get-note-title $title)

  let existing_note = (
    note list --formmat "{{path}}" --limit 1 --match $"title:($title)"
  )

  if ($existing_note | is-not-empty) {
    note edit $existing_note
  } else {
    if ($title | is-not-empty) {
      zk new --title (get-note-title $title)
    } else {
      zk new
    }
  }

  sync-zk-directory
}

# Remove notes
def "note remove" [note?: string] {
  let notes = if ($note | is-not-empty) {
    note list --format "{{abs-path}}" --no-pager --match $note --quiet
    | lines
  } else {
    try {
      note list --format "{{abs-path}}" --interactive --quiet
    } catch {
      return
    }
  }

  if ($notes | is-empty) {
    return
  }

  for note in $notes {
    if (input $"Are you sure you want to remove ($note)? [y/N]: ") in [Y y] {
      rm $note
    }
  }

  sync-zk-directory
}

alias "note rm" = note remove
