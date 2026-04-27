#!/usr/bin/env nu

export def colorize [text: string style: string] {
  $"(ansi $style)($text)(ansi reset)"
}

export def get-colorized-configuration-name [
  configuration_name: string
  colors: record<home-manager: string, nixos: string>
] {
  let color = if $configuration_name == "shared" {
    "light_gray_dimmed"
  } else {
    $colors
    | get (
        $configuration_name
        | split row "\("
        | first
        | str trim
      )
  }

  colorize $configuration_name $color
}

export def get-colors [] {
  {
    home-manager: red_reverse
    nixos: blue_reverse
  }
}
