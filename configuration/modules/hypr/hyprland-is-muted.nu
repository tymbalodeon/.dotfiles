#!/usr/bin/env nu

def main [] {
  if (
    wpctl get-volume @DEFAULT_AUDIO_SINK@
    | split row " "
    | last
  ) == "[MUTED]" {
    exit 1
  } else {
    exit 0
  }
}
