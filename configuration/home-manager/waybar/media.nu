#!/usr/bin/env nu

def main [] {
  loop {
    let data = (
      playerctl metadata
        --format '{
          "album": "{{ album }}",
          "artist": "{{ artist }}",
          "length": "{{ duration(mpris:length) }}",
          "position": "{{ duration(position) }}",
          "status": "{{ status }}"
          "title": "{{ title }}",
        }'
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
      $"($data.title) -- ($data.artist)    \(($data.position)/($data.length)\)    ($icon)"
    }

    let tooltip = if $data.status == Playing {
      $data.album
    } else {
      ""
    }

    print (
      {
        text: $text
        tooltip: $tooltip
      }
      | to json
      | jq --compact-output --unbuffered
    )

    sleep 1sec;
  }
}
