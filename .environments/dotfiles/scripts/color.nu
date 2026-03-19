#!/usr/bin/env nu

export def colorize [text: string style: string] {
  $"(ansi $style)($text)(ansi reset)"
}

export def colorize-file [file: string file_path: string style: string] {
  $file
  | str replace $file_path ""
  | append (colorize $file_path $style)
  | str join
}

export def get-colorized-configuration-name [
  configuration_name: string
  colors: record<darwin: string, home-manager: string, nixos: string>
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
    darwin: green_reverse
    home-manager: red_reverse
    nixos: blue_reverse
  }
}
