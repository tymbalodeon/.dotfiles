# TODO: use modified values to check if local is up to date with remote?

const ARCHIVE = ".task.dump.gz"

def database-file [] {
  $"($env.HOME)/.local/share/task/taskchampion.sqlite3"
}

def "task dump" [] {
  let temporary_file = (mktemp --tmpdir XXX.sqlite3)

  sqlite3 (database-file) .dump
  | gzip --stdout
  | save --force $temporary_file

  storage upload --remote dropbox $temporary_file $ARCHIVE
  rm $temporary_file
}

def "task load" [] {
  let temporary_directory = (mktemp --directory)

  storage download --quiet --to $temporary_directory dropbox $ARCHIVE

  let database_file = (database-file)

  rm $database_file

  zcat ($temporary_directory | path join $ARCHIVE)
  | sqlite3 $database_file

  rm --force --recursive $temporary_directory
}
