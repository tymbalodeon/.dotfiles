# List and preview fonts
def font [] {}

alias fonts = font

# List fonts
def "font list" [] {
  fc-list --format "%{family[0]}\n" :lang=en
  | lines
  | uniq
  | sort
  | to text --no-newline
}

# Preview fonts
def "font preview" [
  text?: string # The preview text to use
  --bg-color: string # The background color to use
  --fg-color: string # The foreground color to use
  --size: int # Font size to use
] {
  let colors = if ([$bg_color $fg_color] | any {|color| $color | is-empty}) {
    theme colors
  }

  let bg_color = if ($bg_color | is-empty) {
    $colors
    | get base00
  }

  let fg_color = if ($fg_color | is-empty) {
    $colors
    | get base05
  }

  let args = [
    --bg-color $bg_color
    --fg-color $fg_color
  ]

  let args = if ($text | is-not-empty) {
    $args
    | append [--preview-text $text]
  } else {
    $args
  }

  let args = if ($size | is-not-empty) {
    $args
    | append [--font-size $size]
  } else {
    $args
  }

  fontpreview ...$args err> /dev/null
}

# Update the font cache
def "font update" [] {
  fc-cache --really-force
}
