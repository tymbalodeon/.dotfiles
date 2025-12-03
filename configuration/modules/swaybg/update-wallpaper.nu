#!/usr/bin/env nu

# TODO: record current backgorund and ensure that the new random background
# is different
const STATE_FILE = "/tmp/swaybg-background.tmp"

def main [wallpaper?: string] {
  let old_swaybg_instance = try { pidof swaybg } catch { null }

  let new_wallpaper = if ($wallpaper | is-not-empty) {
    $wallpaper
  } else {
    let local_wallpaper_directory = ($env.HOME | path join wallpaper)

    if not ($local_wallpaper_directory | path exists) {
      return
    }

    let images = (
      fd
        --extension jpg
        --extension jpeg
        --extension webp
        ""
        $local_wallpaper_directory
      | lines
    )

    if ($images | is-empty) {
      return
    }

    ($images | get (random int ..(($images | length) - 1)))
  }

  (
    bash
      -c $"swaybg --image ($new_wallpaper) & sleep 1 && kill ($old_swaybg_instance)"
      out+err> /dev/null
  )
}
