def running [] {
  $"(pid)"
  | is-not-empty
}

def "music status" [] {
  if (running) {
    "running"
  } else {
    "stopped"
  }
}

def is-nixos [ ] {
  (
    cat /etc/os-release
    | parse "{key}={value}"
    | where key == "ID"
    | first
    | get value 
  ) == nixos
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

# Get pid of music server, if running
def pid [] {
  let pid =  (ps | where name == mpd | get pid)

  if ($pid | is-not-empty) {
    $pid
    | first
  }
}

# Stop music server
def "music stop" [] {
  if (is-nixos) {
    systemctl --user stop mpd.service
  } else {
    pkill mpd
  }
}

# Open music player
def "music" [] {
  let is_nixos = (is-nixos)

  if not (running) {
    if $is_nixos {
      systemctl --user restart mpd.service
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
