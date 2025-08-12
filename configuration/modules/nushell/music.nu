def running [] {
  $"(music pid)"
  | is-not-empty
}

# Show the track currently playing
def "music current" [] {
  if not (running) {
    return
  }

  ncmpcpp --current-song
}

# Get pid of music server, if running
def "music pid" [] {
  let pid =  (ps | where name == mpd | get pid)

  if ($pid | is-not-empty) {
    $pid
    | first
  }
}

# Stop music server
def "music stop" [] {
  pkill mpd
}

# Open music player
def "music" [] {
  if not (running) {
    mpd
  }

  ncmpcpp
}
