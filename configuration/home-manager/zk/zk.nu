def get-main-notebook-directory [] {
  ($env.HOME | path join .nb/home)
}

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

def --wrapped run-zk [...args: string] {
  if not (is-inside-notebook) {
    cd (get-main-notebook-directory)
  }

  SHELL=$"(^which bash)" ^zk ...$args
}

def sync-zk-directory [] {
  if (
    git -C (get-main-notebook-directory) status --short
    | is-not-empty
  ) {
    # TODO: use `start-process`, but make it fully detach?
    nb sync --all
  }
}

def --wrapped zk [...args: string] {
  if ($args | is-empty) {
    zk edit
  } else {
    run-zk ...$args
  }
}

def note-title [title: list<string>] {
  $title
  | str join " "
}

def note [title: list<string>] {
  (
    zk list
      --format "{{path}}"
      --limit 1
      --match $"title: (note-title $title)"
      --no-pager
      err> /dev/null
    | str trim
  )
}

# Cd to the `zk` home  directory
def --env "zk cd" [] {
  cd (get-main-notebook-directory)
}

# Edit notes
def "zk edit" [...search_terms: string] {
  if ($search_terms | is-empty) {
    run-zk edit --interactive
  } else {
    let note = (note $search_terms)

    if ($note | is-empty) {
      run-zk edit --match ...$search_terms --interactive
    } else {
      run-zk edit $note
    }
  }

  sync-zk-directory
}

# Create or edit the current day's journal entry
def "zk journal" [] {
  let working_dir = (get-main-notebook-directory)
  let journal = ($working_dir | path join "${journalDirectory}")

  mkdir $journal
  run-zk new $journal --no-input --working-dir $working_dir
  sync-zk-directory
}

# Interactively select a journal entry to edit
def "zk journal edit" [] {
  ^zk edit --interactive --tag journal
}

# List journal entries
def "zk journal list" [] {
  zk list --tag journal
}

alias "zk journal ls" = zk journal list

# Show links for notes
def "zk links" [...title: string] {
  let note = (note $title)

  let note = if ($note | is-empty) {
    $title
    | first
  } else {
    $note
  }

  ^zk edit --interactive --link-to $note err> /dev/null
}

# Add new note
def "zk new" [...title: string] {
  let title = (note-title $title)

  let existing_note = (
    zk list --formmat "{{path}}" --limit 1 --match $"title:($title)"
  )

  if ($existing_note | is-not-empty) {
    zk edit $existing_note
  } else {
    if ($title | is-not-empty) {
      run-zk new --title (note-title $title)
    } else {
      run-zk new
    }
  }

  sync-zk-directory
}

# Remove notes
def "zk remove" [note?: string] {
  let notes = if ($note | is-not-empty) {
    zk list --format "{{abs-path}}" --no-pager --match $note --quiet
    | lines
  } else {
    try {
      zk list --format "{{abs-path}}" --interactive --quiet
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

alias "zk rm" = zk remove
