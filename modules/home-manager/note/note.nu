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

def pull-notes [--force --no-new] {
  cd (get-current-notebook-path)

  let switch_exit_status = (git switch trunk | complete)

  if $switch_exit_status.exit_code != 0 {
    print $switch_exit_status.stderr

    return
  }

  if $force or (git status --short | complete | get stdout | is-not-empty) {
    try {
      jj git fetch --bookmark trunk --remote origin

      if not $no_new {
        jj new trunk
      }
    } catch {
      git fetch origin trunk
    }
  }
}

def push-notes [] {
  cd (get-current-notebook-path)

  job spawn {
    try { git switch trunk out+err> /dev/null }

    if (git status --short | is-empty) {
      return
    }

    try {
      if (jj log --no-graph --revisions @ --template "description" | is-empty) {
        jj describe --message "chore: sync"
      }

      jj new @ trunk@origin
      jj describe --message "chore: sync"
      jj bookmark set trunk
      jj new
      jj git push
    } catch {
      git add .
      git commit --message "chore: sync"
      git push origin trunk
    }
  } out> /dev/null
}

# Write and manage notes
def note [...args: string] {
  if ($args | any {$in in [--help -h]}) {
    return (help note)
  }

  if ($args | is-empty) {
    note edit
  } else {
    try {
      note edit ($args | str join " ")
    } catch {
      zk ...$args
    }
  }
}

alias n = note

def get-note-title [title: list<string>] {
  $title
  | str join " "
}

def get-note [title: list<string>] {
  (
    zk list
      --format "{{path}}"
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
  pull-notes

  if ($search_terms | is-empty) {
    zk edit --interactive
  } else {
    let note = (get-note $search_terms)

    if ($note | is-empty) {
      let queries = (
        $search_terms
        | each {[--match $in]}
        | flatten
      )

      if ((zk list ...$queries err> /dev/null) | is-not-empty) {
        (
          zk edit
            --interactive
            --match ...(zk list ...$queries err> /dev/null) 
        )
      }
    } else {
      zk edit $note
    }
  }

  push-notes
}

# View a graph of notes
def "note graph" [] {
  let zk_graph_directory = (
    get-current-notebook-path
    | path join .zk-graph
  )

  mkdir $zk_graph_directory

  for file in [
    d3.v7.min.js
    favicon.ico
    index.html
  ] {
    cp $"(zk-graph-source)/($file)" $zk_graph_directory
  }

  zk graph --format json --quiet
  | save --force $"($zk_graph_directory)/data.json"

  cd $zk_graph_directory
  job spawn { python -m http.server }
  start-process xdg-open http://localhost:8000
}

# Create or edit the current day's journal entry
def "note journal" [] {
  pull-notes

  let working_dir = (get-current-notebook-path)
  let journal = ($working_dir | path join journal)

  mkdir $journal
  zk new $journal --no-input --working-dir $working_dir
  push-notes
}

# Interactively select a journal entry to edit
def "note journal edit" [] {
  zk edit --interactive --sort created --tag journal
}

alias "note journal browse" = note journal edit

# List journal entries
def "note journal list" [] {
  zk list --tag journal
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
  pull-notes

  let title = (get-note-title $title)

  let existing_note = (
    zk list
      --format "{{path}}"
      --limit 1
      --match $"title:($title)"
      err> /dev/null
  )

  if ($existing_note | is-not-empty) {
    note edit $existing_note
  } else {
    if ($title | is-not-empty) {
      zk new --title $title
    } else {
      zk new
    }
  }

  push-notes
}

# Remove notes
def "note remove" [note?: string] {
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

  push-notes
}

alias "note rm" = note remove

# Sync notes
def "note sync" [--push] {
  if $push {
    pull-notes --force --no-new
    push-notes
  } else {
    pull-notes --force
  }
}
