def wallpaper-directory [] {
  let wallpaper_directory = $"($env.HOME)/wallpaper"

  mkdir $wallpaper_directory

  $wallpaper_directory
}

def default-wallpaper-filename [] {
  "Hildegard von Bingen -- Scivias I-6 - Humanity and Life (1150).jpg"
}

def default-wallpaper-path [] {
  wallpaper-directory
  | path join (default-wallpaper-filename)
}

def select-local-wallpaper [--multi] {
  let wallpaper_directory = (wallpaper-directory)

  let args = [
    --preview $"
      file={}
      file=\"($wallpaper_directory)/$file\"

      if [[ $\(file --brief --mime-type \"$file\"\) == image/* ]]; then
        kitten icat \\
          --clear \\
          --place ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 \\
          --stdin no \\
          --transfer-mode memory \\
          \"$file\"
      fi
    "
    --with-shell "bash -c"
  ]

  let args = if $multi {
    $args
    | append "--multi"
  } else {
    $args
  }

  let selection = (
    ls --short-names $wallpaper_directory
    | get name
    | to text
    | fzf ...$args
    | lines
  )

  let selection = if ($selection | is-not-empty) {
    $selection
    | each {|wallpaper| $"($wallpaper_directory)/($wallpaper)"}
  }

  if $multi {
    $selection
  } else {
    try {
      $selection
      | first
    }
  }
}

def create-blank-wallpaper [color: string] {
  let image_file = $"(wallpaper-directory)/($color).jpg"

  if ($image_file | path exists) {
    return
  }

  magick -size (resolution) $"xc:($color)" $image_file

  $image_file
}

def set-wallpaper [image: string --timer-on] {
  wpaperctl set $image

  if $timer_on {
    wpaperctl resume
  }

  pkill -RTMIN+2 waybar
}

# Set wallpaper to a specific file
def wallpaper [
  wallpaper?: string # Path to an image file to use as the wallpaper
  --timer-on # Keep the timer to switch wallpapers running
] {
  let wallpaper = if ($wallpaper | is-empty) {
    let wallpaper = (select-local-wallpaper)

    if ($wallpaper | is-empty) {
      return
    }

    $wallpaper
  } else {
    $wallpaper
  }
  | str replace ~ $env.HOME

  if ($wallpaper | is-empty) or not ($wallpaper | path exists) {
    return
  }

  if $timer_on {
    set-wallpaper $wallpaper --timer-on
  } else {
    set-wallpaper $wallpaper
  }
}

alias wp = wallpaper

# Set wallpaper to a blank color
def "wallpaper blank" [
  color?: string # The hex color value (or "black"/"white") or base16-colors name to use as the background color (default: "base01")
  --rotate-theme-colors # Cycle through theme colors on a timer
] {
  if $rotate_theme_colors {
    for file in (
      ls (wallpaper-directory)
      | get name
      | where {not ($in | path basename | str starts-with "#")}
    ) {
      rm $file
    }

    let colors = (theme colors)

    $colors
    | columns
    | each {|column| create-blank-wallpaper ($colors | get $column)}

    wallpaper next
  } else {
    set-wallpaper (
      create-blank-wallpaper (get-background-color $color)
    )
  }
}

# Browse local wallpapers
def "wallpaper browse local" [] {
  yazi (wallpaper-directory)
}

alias "wallpaper br local" = wallpaper browse local
alias "wallpaper br l" = wallpaper browse local
alias "wallpaper browse l" = wallpaper browse local
alias "wallpaper browse" = wallpaper browse local
alias "wallpaper br" = wallpaper browse local

# Browse remote wallpapers
def "wallpaper browse remote" [
  --web # Browse remote in the browser, using remote website
] {
  if $web {
    start-process xdg-open $"https://dropbox.com/home/wallpaper"
  } else {
    rclone ncdu $"dropbox:wallpaper"
  }
}

alias "wallpaper br remote" = wallpaper browse remote
alias "wallpaper br r" = wallpaper browse remote
alias "wallpaper browse r" = wallpaper browse remote

# `cd` to the wallpaper directory
def --env "wallpaper cd" [] {
  cd (wallpaper-directory)
}

# Clear the wallpaper folder
def "wallpaper clear" [
  --no-default # Don't load the default wallpaper ater clearing
] {
  let wallpaper_directory = (wallpaper-directory)

  rm --force --recursive $wallpaper_directory
  mkdir $wallpaper_directory

  if not $no_default {
    wallpaper load default
  }
}

def --wrapped wpaperctl-wrapper [...args: string] {
  if (systemctl --user list-units | find wpaperd | is-empty) {
    systemctl --user start wpaperd
    sleep 500ms
  }

  if ($args | is-not-empty) {
    wpaperctl ...$args
  }

  pkill -RTMIN+2 waybar
}

# List loaded wallpapers
def "wallpaper list local" [
  --absolute-path # Show the absolute path of the files
] {
  if $absolute_path {
    ls (wallpaper-directory)
  } else {
    ls --short-names (wallpaper-directory)
  }
  | get name
  | to text --no-newline
}

alias "wallpaper list l" = wallpaper list local
alias "wallpaper list" = wallpaper list local
alias "wallpaper ls local" = wallpaper list local
alias "wallpaper ls l" = wallpaper list local
alias "wallpaper ls" = wallpaper list local

# List remote wallpapers
def "wallpaper list remote" [] {
  storage list remote --recursive  wallpaper
}

alias "wallpaper list r" = wallpaper list remote
alias "wallpaper ls remote" = wallpaper list remote
alias "wallpaper ls r" = wallpaper list remote

def is-image []: string -> bool {
  try {
    (
      file --brief --mime-type $in
      | split row /
      | first
    ) == image
  } catch {
    return false
  }
}

def restart-wallpaper [] {
  systemctl --user restart wpaperd
}

def get-background-color [color?: string] {
  let color = if ($color | is-empty) {
    "base01"
  } else {
    $color
  }

  let theme_colors = (theme colors)

  if $color in ($theme_colors | columns) {
    $theme_colors
    | get $color
  } else if ($color == black) {
    "#000000"
  } else if ($color == white) {
    "#ffffff"
  } else {
    if ($color | str starts-with "#") {
      $color
    } else {
      $"#($color)"
    }
  }
}

# Load wallpapers
def "wallpaper load" [
  path?: string # Image file or directory to load
  --background-color: string # The hex color value (or "black"/"white") or base16-colors name to use as the background color (default: "base01")
  --clear # Clear existing wallpapers before loading new ones
  --keep-default # Don't remove the default wallpaper when loading others
  --no-pad # Don't pad the wallpaper after loading
  --remote # Treat $path as a remote path
  --store # Add local wallpaper to remote storage
] {
  mut temporary_directory = ""
  let wallpaper_directory = (wallpaper-directory)

  let files = if $remote or ($path | is-empty) {
    let paths = if ($path | is-empty) {
      let paths = (select-remote-path --allow-directories dropbox wallpaper)

      if ($paths | is-empty) {
        return
      } else {
        $paths
        | lines
      }
    } else {
      [$path]
    }

    $temporary_directory = (mktemp --directory)

    for path in $paths {
      try {
        let parent_directory = ($path | path split | drop | path join)

        let is_directory = (
          rclone lsjson $"dropbox:($parent_directory)"
          | from json
          | where Path == ($path | path basename)
          | first
          | get IsDir
        )

        let files = (
          rclone lsjson $"dropbox:($path)"
          | from json
        )

        for file in $files {
          if not (
            $wallpaper_directory
            | path join $file.Path
            | path exists
          ) {
            let file_path = if $is_directory {
              if $file.IsDir {
                $path
              } else {
                $path
                | path join $file.Path
              }
            } else {
              $path
            }

            storage download --to $temporary_directory $file_path
          }
        }
      } catch {
        |error|

        print $error.msg
      }
    }

    ls $temporary_directory
    | get name
    | where {is-image}
  } else {
    let path = ($path | path expand)

    if ($path | path type) == file {
      $path
    } else {
      ls $path
      | get name
    }
  }

  if $clear {
    if $keep_default {
      wallpaper clear
    } else {
      wallpaper clear --no-default
    }
  }

  if $remote or ($path | is-empty) {
    $files
    | par-each {
      |file|

      if not $no_pad {
        print $"Padding ($file | path basename)..."
      }

      try {
        if $no_pad {
          cp $file $wallpaper_directory
        } else {
          if ($background_color | is-empty) {
            wallpaper pad --no-download --output-path $wallpaper_directory $file
          } else {
            (
              wallpaper pad
                --background-color $background_color
                --no-download
                --output-path $wallpaper_directory
                $file
            )
          }
        }
      } catch {
        |error|

        print $error.msg
      }
    }
  } else {
    $files
    | par-each {
      |file|

      if not ($file | is-image) {
        return
      }

      let basename = ($file | path basename)

      if $store {
        storage upload $file $"wallpaper/($basename)"
      }

      let to = $"(wallpaper-directory)/($basename)"

      cp $file $to

      if not $no_pad {
        print $"Padding ($to)..."

        wallpaper pad --no-download $to
      }
    }
  }

  if ($temporary_directory | is-not-empty) {
    rm --force --recursive $temporary_directory
  }

  restart-wallpaper
}

# Load all wallpapers in the remote wallpaper directory
def "wallpaper load all" [] {
  wallpaper load --remote wallpaper
}

# Load the default wallpaper
def "wallpaper load default" [
  --background-color: string # The hex color value (or "black"/"white") or base16-colors name to use as the background color (default: "base01")
  --clear # Clear existing wallpapers before loading new ones
  --no-pad # Don't pad the wallpaper after loading
] {
  let temporary_file = (mktemp)

  cp (default-wallpaper) $temporary_file

  let new_filename = (
    $temporary_file
    | path dirname
    | path join (
      $temporary_file
      | path split
      | drop
      | append (default-wallpaper-filename)
      | path join
    )
  )

  mv $temporary_file $new_filename

  if $clear {
    wallpaper clear
  }

  if $no_pad {
    wallpaper load --keep-default --no-pad $new_filename
  } else if ($background_color | is-not-empty) {
    wallpaper load --keep-default --background-color $background_color $new_filename
  } else {
    wallpaper load --keep-default $new_filename
  }

  rm $new_filename
}

# Change to next (random) wallpaper
def "wallpaper next" [] {
  wpaperctl-wrapper next-wallpaper
}

# Start cycling wallpapers
def "wallpaper start" [] {
  wpaperctl-wrapper
}

def resolution [] {
  xrandr err> /dev/null
  | rg '\*'
  | split words
  | first
}

# Add padding to image to account for status bar
def "wallpaper pad" [
  ...images: string # The image to pad
  --background-color: string # The base16-colors name to use as the background color (default: "base01")
  --no-download # Don't attempt to re-download the image
  --output-path: string # Where to save the padded image (default: $image)
] {
  let images = if ($images | is-empty) {
    select-local-wallpaper --multi
  } else {
    $images
  }

  if ($images | is-empty) {
    return
  }

  let remote_wallpapers = (rclone lsf --recursive dropbox:wallpaper)

  for image in $images {
    if not $no_download and ($image | path dirname | path expand) == (
      "~/wallpaper"
      | path expand
    ) {
      let remote_image = (
        $remote_wallpapers
        | rg (
            $image
            | path basename
            | str replace --all '(' '\('
            | str replace --all ')' '\)'
          )
        | lines
        | first
      )

      (
        wallpaper load
          --no-pad
          --remote
          $"wallpaper/($remote_image)"
      )
    }

    let output_path = if ($output_path | is-empty) {
      $image
    } else if ($output_path | path type) == dir {
      $output_path
      | path join ($image | path basename)
    } else {
      $output_path
    }

    let resolution = (resolution)
    let resolution_parts = ($resolution | split row x)
    let padded_width = ($resolution_parts | first | into int)

    let padded_height = (
      ($resolution_parts | last | into int) + (waybar-height)
      | into int
    )

    let padded_resolution = ([$padded_width $padded_height] | str join x)
    let image = ($image | path expand)
    let image_data = (magick identify -format "%wx%h" $image)
    let image_data_parts = ($image_data | split row x)
    let image_width = ($image_data_parts | first | into int)
    let image_height = ($image_data_parts | last | into int)

    let is_wide_image = (
      (
        $image_width / $image_height
      ) > (
        $padded_width / $padded_height
      )
    )

    let gravity = if $is_wide_image {
      "center"
    } else {
      "north"
    }

    let padded_resolution = if $is_wide_image {
      $"($padded_resolution)+0+((waybar-height) / 2)"
    } else {
      $padded_resolution
    }

    (
      magick
        $image
        -background (get-background-color $background_color)
        -gravity $gravity
        -resize $resolution
        -extent $padded_resolution
        $output_path
    )
  }
}

# Add padding to all images in the wallpaper folder
def "wallpaper pad all" [
  --background-color: string # The base16-colors name to use as the background color (default: "base01")
] {
  let images = (ls (wallpaper-directory)).name

  if ($background_color | is-empty) {
    wallpaper pad ...$images
  } else {
    wallpaper pad --background-color $background_color ...$images
  }
}

# Pause automatic cycling of wallpaper
def "wallpaper pause" [] {
  wpaperctl-wrapper pause-wallpaper
}

# Change to previous wallpaper
def "wallpaper previous" [] {
  wpaperctl-wrapper previous-wallpaper
}

# Remove wallpaper from the wallpaper directory
def "wallpaper remove" [] {
  let files = (
    fd "" (wallpaper-directory)
    | fzf --multi
    | lines
  )

  for file in $files {
    rm $file
  }
}

alias "wallpaper rm" = wallpaper remove

# Resum automatic cycling of wallpaper
def "wallpaper resume" [] {
  wpaperctl-wrapper resume-wallpaper
}

# Toggle pausing/resuming automatic cycling of wallpaper
def "wallpaper toggle-pause" [] {
  wpaperctl-wrapper toggle-pause-wallpaper
}

# Manage wallpaper
export def main [arg?: string] {
  match $arg {
    "next" => (wallpaper next)
    "previous" => (wallpaper previous)
    "toggle-pause" => (wallpaper toggle-pause)
    _ => (wallpaper $arg)
  }
}
