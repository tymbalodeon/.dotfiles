def wallpaper-directory [] {
  $"($env.HOME)/wallpaper"
}

# Set wallpaper to a specific file
def wallpaper [wallpaper?: string] {
  let wallpaper_directory = (wallpaper-directory)

  let wallpaper = if ($wallpaper | is-empty) {
    ls --short-names $wallpaper_directory
    | get name
    | to text
    | fzf --preview $"
        file='($wallpaper_directory)/{}'

        if [[ $\(file --mime-type -b $file\) == image/* ]]; then
          kitten icat \\
            --clear \\
            --place ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 \\
            --stdin no \\
            --transfer-mode memory \\
            $file
        fi
      "
  } else {
    $wallpaper
  }
  | path expand

  let wallpaper = if ($wallpaper | path dirname) not-in [
    $"($env.HOME)/wallpaper"
    $wallpaper_directory
  ] {
    [
      $env.HOME
      wallpaper
      $wallpaper
    ]
    | path join
  } else {
    $wallpaper
  }

  if not ($wallpaper | path exists) {
    return
  }

  bash -c $"swaybg --image '($wallpaper)' &" out+err> /dev/null
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
  let user_wallpapers = (
    ls (wallpaper-directory)
    | get name
    | to text
    | rg --pcre2 "^(?!.*(wallpaper.jpeg))"
    | lines
  )

  for file in ($user_wallpapers) {
    rm --recursive $file
  }
}

def --wrapped wpaperctl-wrapper [...args: string] {
  if (systemctl --user list-units | rg wpaperd | is-empty) {
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

# Load wallpapers
def "wallpaper load" [path?: string] {
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
      storage download --force --pipe --to $temporary_directory $path
    }

    let files = (
      ls $temporary_directory
      | get name
      | each {|path| $wallpaper_directory | path join ($path | path basename)}
    )

    mv ($"($temporary_directory)/*" | into glob) $wallpaper_directory
    rm --force $temporary_directory

    $files
  } else {
    let path = ($path | path expand)

    let files = if ($path | path type) == file {
      $path
    } else {
      ls $path
      | get name
    }

    for file in $files {
      let basename = ($file | path basename)

      storage upload $file $"wallpaper/($basename)"
      cp $file $"(wallpaper-directory)/($basename)"
    }

    $files
  }

  for file in $files {
    wallpaper pad $file $file
  }

  systemctl --user restart wpaperd
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
def "wallpaper pad" [image: string output_file?: string] {
  const WAYBAR_HEIGHT = 55

  let resolution = (xrandr | rg '\*' | split words | first)
  let resolution_parts = ($resolution | split row x)
  let padded_width = ($resolution_parts | first)
  let padded_height = (($resolution_parts | last | into int) + $WAYBAR_HEIGHT)
  let padded_resolution = ([$padded_width $padded_height] | str join x)
  let image = ($image | path expand)

  let output_file = if ($output_file | is-empty) {
    $image
  } else {
    $output_file
  }

  (
    magick
      $image
      -background black
      -gravity north
      -resize $resolution
      -extent $padded_resolution
      $output_file
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
  # TODO: add the ability to remove from remote as well
  
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
