#!/usr/bin/env nu

export def colorize [text: string style: string] {
  $"(ansi $style)($text)(ansi reset)"
}

export def get-colorized-configuration-name [
  configuration_name: string
  colors: table<configuration: string, name: string>
] {
  let color = (
    $colors
    | filter {
        |color|

        $color.configuration == $configuration_name
      }
    | first
    | get name
  )

  colorize $configuration_name $color
}

export def get-colors [] {
  let all_configurations = (get-all-configurations)

  let colors = (
    ansi --list
    | get name
    | filter {
        |color|

        $color not-in [reset title identity escape size] and not (
          [_bold _underline _italic _dimmed _reverse bg_]
          | each {|name| $name in $color}
          | any {|color| $color}
        # TODO is it possible to programmatically detect which colors will work?
        # `delta` seems able to do this--use that as an example!
        ) and not ("black" in $color) and not ("purple" in $color) or (
          "xterm" in $color
        )
      }
    | sort-by {|a, b| "light" in $a}
    | take ($all_configurations | length)
  )

  $all_configurations
  | wrap configuration
  | merge ($colors | wrap name)
}

