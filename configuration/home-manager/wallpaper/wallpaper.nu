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
    | fzf
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
    rm $file
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
def "wallpaper list" [
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

alias "wallpaper ls" = wallpaper list

# Load wallpapers
def "wallpaper load" [path: string] {
  let path = ($path | path expand)

  let files = if ($path | path type) == file {
    $path
  } else {
    ls $path
    | get name
  }


  for file in $files {
    let temporary_file = (mktemp --tmpdir wallpaper-XXX)

    wallpaper pad $file $temporary_file
    storage upload $temporary_file $"wallpaper/($file | path basename)"
    cp $temporary_file $"(wallpaper-directory)/($file | path basename)"
    rm $temporary_file
  }

  systemctl --user restart wpaperd
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
