def pid [] {
  let pid =  (ps | where name == mpd | get pid)

  if ($pid | is-not-empty) {
    $pid
    | first
  }
}

def running [] {
  $"(pid)"
  | is-not-empty
}

def is-darwin [] {
  (uname).kernel-name == Darwin
}

def is-nixos [] {
  try {
    (
      cat /etc/os-release
      | parse "{key}={value}"
      | where key == "ID"
      | first
      | get value 
    ) == nixos
  } catch {
    false
  }
}

# Open music player
def music [] {
  let is_nixos = (is-nixos)

  if not (running) {
    if $is_nixos {
      systemctl --user restart mpd
    } else {
      mpd
    }
  }

  if $is_nixos {
    rmpc
  } else {
    ncmpcpp
  }
}

# Show the track currently playing
def "music current" [
  --all # Show all track information
] {
  if not (running) {
    return
  }

  if (is-nixos) {
    let data = (rmpc song | from json)

    if ($data | is-empty) {
      return
    }

    if $all {
      $data
    } else {
      $"($data.metadata.albumartist) - ($data.metadata.title)"
    }
  } else {
    ncmpcpp --current-song
  }
}

def get-playlist-directory [] {
  let playlist_directory = if (is-darwin) {
    ".mpd/playlists"
  } else {
    ".local/share/mpd/playlists"
  }

  $env.HOME
  | path join $playlist_directory
}

def "music playlist" [] {
  help music
}

def get-playlist [playlist?: string] {
  let playlist = if ($playlist | is-empty) {
    let playlists = (music playlists | lines)

    if ($playlists | length) > 1 {
      $playlists
      | to text
      | fzf
    } else if ($playlists | is-empty) {
      return
    } else {
      $playlists
      | first
    }
  } else {
    $playlist
  }

  let playlist = (
    ls (get-playlist-directory)
    | where {($in.name | path parse | get stem) == $playlist}
    | get name
  )

  if ($playlist | is-empty) {
    return
  }

  $playlist
  | first
}

# Add current song to playlists
def "music playlist add" [
  playlist?: string
] {
  if (rmpc status | from json).state not-in [Pause Play] {
    return
  }

  let current_song_file = (
    rmpc song
    | from json
    | get file?
  )

  if ($current_song_file | is-empty) {
    return
  }

  let playlist = if ($playlist | is-empty) {
    "Saved"
  } else {
    $playlist
  }

  let playlist_file = (music playlist create $playlist)

  let paths = (
    open $playlist_file
    | append $current_song_file
    | to text
  )

  $paths
  | save --force $playlist_file
}

# Create playlist
def "music playlist create" [playlist?: string] {
  let playlist_path = (get-playlist $playlist)

  touch $playlist_path

  $playlist_path
}

alias "music playlist new" = music playlist create

# Edit playlist
def "music playlist edit" [playlist?: string] {
  let playlist = (get-playlist $playlist)

  if ($playlist | is-empty) {
    return
  }

  ^$env.EDITOR $playlist
}

# List playlists
def "music playlist list" [] {
  ls (get-playlist-directory)
  | get name
  | path parse
  | get stem
  | to text --no-newline
}

alias "music playlists" = music playlist list

# View playlist
def "music playlist open" [playlist?: string] {
  let playlist = (get-playlist $playlist)

  if ($playlist | is-empty) {
    return
  }

  open $playlist
}

alias "music playlist show" = music playlist open
alias "music playlist view" = music playlist open

# Show the status of the music player server
def "music status" [] {
  if (running) {
    "running"
  } else {
    "stopped"
  }
}

# Stop music server
def "music stop" [] {
  if (is-darwin) {
    pkill mpd
  } else {
    error make --unspanned {msg: "only implemented on Darwin systems"}
  }
}
