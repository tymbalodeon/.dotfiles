#!/usr/bin/env nu

export def main [] {}

export def "main toggle-mute" [] {
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
}

export def "main toggle-mute mic" [] {
  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
}

def current-volume [] {
  wpctl get-volume @DEFAULT_AUDIO_SINK@
  | split row " "
  | last
}

def set-volume [direction: string] {
  if (current-volume) == "[MUTED]" {
    main toggle-mute
  }

  wpctl set-volume @DEFAULT_AUDIO_SINK@ $"1%($direction)"
}

export def "main lower" [] {
  set-volume "-"
}

def is-over-maximum [] {
  try {
    (current-volume | into float ) >= 1.0
  } catch {
    false
  }
}

export def "main raise" [] {
  if (is-over-maximum) {
    return
  }

  set-volume "+"

  if (is-over-maximum) {
    wpctl set-volume @DEFAULT_AUDIO_SINK@ $"1.0"
  }
}

export def "main zero" [] {
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%
}
