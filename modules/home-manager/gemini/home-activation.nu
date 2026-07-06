def main [] {
  let bookmarks_path = (bookmarks-path)
  let remote_bookmarks = (remote-bookmarks)

  let bookmarks = if ($bookmarks_path | path type) != file {
    rm --force --recursive $bookmarks_path
    mkdir ($bookmarks_path | path dirname)

    $remote_bookmarks
  } else {
    let local_bookmarks = (open --raw $bookmarks_path | from xml --allow-dtd)

    if ($local_bookmarks == $remote_bookmarks) {
      return
    }

    let bookmarks = (
      $local_bookmarks
      | merge deep $remote_bookmarks
    )

    $bookmarks
    | update content (
      $bookmarks.content
      | update attributes.href {$in | str replace --regex "^gemini://" ""}
      | uniq
    )
  }

  $bookmarks
  | to xml --indent 4
  | save --force $bookmarks_path
}
