#!/usr/bin/env nu

export def main [signal: number] {
  pkill $"-RTMIN+($signal)" waybar
}
