#!/usr/bin/env nu

export def "main mute" [] {
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
}

export def "main mute mic" [] {
  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
}

def set-volume [direction: string] {
  if (
    wpctl get-volume @DEFAULT_AUDIO_SINK@
    | split row " "
    | last
  ) == "[MUTED]" {
    main mute
  }

  wpctl set-volume @DEFAULT_AUDIO_SINK@ $"1%($direction)"
}

export def "main lower" [] {
  set-volume "-"
}

export def "main raise" [] {
  set-volume "+"
}

export def main [] {}
