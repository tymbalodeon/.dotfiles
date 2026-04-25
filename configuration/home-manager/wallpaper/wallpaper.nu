def wallpaper-directory [] {
  $"($env.HOME)/wallpaper"
}

def default-wallpaper-filename [] {
  "default-wallpaper.jpeg"
}

def select-local-wallpaper [] {
  let wallpaper_directory = (wallpaper-directory)

  let selection = (
    ls --short-names $wallpaper_directory
    | get name
    | to text
    | fzf --preview $"
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
    | lines
  )

  if ($selection | is-not-empty) {
    $selection
    | prepend $wallpaper_directory
    | path join
  }
}

# Set wallpaper to a specific file
def wallpaper [wallpaper?: string] {
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

  bash -c $"swaybg --image '($wallpaper)' --mode fit &" out+err> /dev/null
  pkill -RTMIN+2 waybar
  systemctl --user stop wpaperd
}

alias wp = wallpaper

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
def "wallpaper clear" [] {
  let wallpaper_directory = (wallpaper-directory)
  rm --force --recursive $wallpaper_directory
  mkdir $wallpaper_directory

  cp (default-wallpaper) (
    $wallpaper_directory
    | path join (default-wallpaper-filename)
  )

  restart-wallpaper
}

def --wrapped wpaperctl-wrapper [...args: string] {
  if (systemctl --user list-units | find wpaperd | is-empty) {
    systemctl --user start wpaperd
    sleep 500ms

    if toggle-pause in $args {
      wpaperctl toggle-pause
    }
  }

  wpaperctl ...$args
  pkill -RTMIN+2 waybar
  try { pkill swaybg }
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
  storage list remote wallpaper
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

# Load wallpapers
def "wallpaper load" [
  path?: string # Local image file or directory to load
  --clear # Clear existing wallpapers before loading new ones
  --force # Re-download even if already present locally
  --keep-default # Don't remove the default wallpaper when loading others
] {
  if $clear {
    wallpaper clear
  }

  let files = if ($path | is-empty) {
    let paths = (select-remote-path --allow-directories dropbox wallpaper)

    let paths = if ($paths | is-empty) {
      return
    } else {
      $paths
      | lines
    }

    let temporary_directory = (mktemp --directory)
    let wallpaper_directory = (wallpaper-directory)

    for path in $paths {
      try {
        if $force {
          storage download --force --to $temporary_directory $path
        } else {
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
        }
      } catch {
        |error|

        print $error.msg
      }
    }

    let files = (
      ls $temporary_directory
      | get name
      | where {is-image}
    )

    for file in $files {
      print $"Padding ($file)..."

      try {
        wallpaper pad $file $wallpaper_directory
      } catch {
        |error|

        print $error.msg
      }
    }

    rm --force --recursive $temporary_directory
  } else {
    let path = ($path | path expand)

    let files = if ($path | path type) == file {
      $path
    } else {
      ls $path
      | get name
    }

    for file in $files {
      if not ($file | is-image) {
        continue
      }

      let basename = ($file | path basename)

      storage upload $file $"wallpaper/($basename)"

      let to = $"(wallpaper-directory)/($basename)"

      cp $file $to
      wallpaper pad $to
    }
  }

  rm --force (wallpaper-directory | path join (default-wallpaper-filename))
  restart-wallpaper
}

def "wallpaper load all" [] {
  storage download --force --to (wallpaper-directory) --quiet wallpaper
}

# Change to next (random) wallpaper
def "wallpaper next" [] {
  wpaperctl-wrapper next
}

alias "wallpaper start" = wallpaper next

# Add padding to image to account for status bar
def "wallpaper pad" [image?: string output_path?: string] {
  let image = if ($image | is-empty) {
    select-local-wallpaper
  } else {
    $image
  }

  if ($image | is-empty) {
    return
  }

  let resolution = (xrandr | rg '\*' | split words | first)
  let resolution_parts = ($resolution | split row x)
  let padded_width = ($resolution_parts | first)
  let padded_height = (($resolution_parts | last | into int) + (waybar-height))
  let padded_resolution = ([$padded_width $padded_height] | str join x)
  let image = ($image | path expand)

  let output_path = if ($output_path | is-empty) {
    $image
  } else if ($output_path | path type) == dir {
    $output_path
    | path join ($image | path basename)
  } else {
    $output_path
  }

  (
    magick
      $image
      -background (stylix-background)
      -gravity north
      -resize $resolution
      -extent $padded_resolution
      $output_path
  )
}

# Add padding to all images in the wallpaper folder
def "wallpaper pad all" [] {
  for image in (ls (wallpaper-directory) | get name) {
    wallpaper pad $image
  }
}

# Change to previous wallpaper
def "wallpaper previous" [] {
  wpaperctl-wrapper previous
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

# Toggle pausing/resuming automatic cycling of wallpaper
def "wallpaper toggle-pause" [] {
  wpaperctl-wrapper toggle-pause
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
