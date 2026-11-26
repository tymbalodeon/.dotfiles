#!/usr/bin/env nu

# TODO: use a shared function
def print-module [text: string = "" tooltip: string = ""] {
  print (
    {
      text: $text
      tooltip: $tooltip
    }
    | to json
    | jq --compact-output --unbuffered
  )
}

def main [] {
  loop {
    try {
      let data = (
        playerctl metadata
          --format '{
            "album": "{{ album }}",
            "artist": "{{ artist }}",
            "length": "{{ duration(mpris:length) }}",
            "position": "{{ duration(position) }}",
            "status": "{{ status }}"
            "title": "{{ title }}",
          }' err> /dev/null
        | from json
      )

      let icon = if $data.status == Playing {
        ""
      } else if $data.status == Paused {
        ""
      } else {
        ""
      }

      let text = if $data.status in [Paused Playing] {
        $" ($icon)  \"($data.title)\" by ($data.artist)  \(($data.position)/($data.length)\)"
      }

      let tooltip = if $data.status == Playing {
        $"Album: "($data.album)\""
      } else {
        ""
      }

      print-module $text $tooltip
    } catch {
      print-module
    }

    sleep 1sec;
  }
}
