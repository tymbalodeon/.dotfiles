# View and manage email
def --wrapped mail [...args: string] {
  if ($args | where {$in in [-h --help]} | is-not-empty) {
    return (help mail)
  }

  aerc ...$args
}

alias email = mail

# Sync email
def "mail sync" [account?: string] {
  try {
    if ($account | is-empty) {
      mbsync --all
    } else {
      mbsync $account
    }
  }

  if ($account | is-empty) {
    notmuch new
  } else {
    notmuch new $account
  }
}
