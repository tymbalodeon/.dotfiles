def config-file [] {
  get-config-file mail
}

def default-accounts [] {
  try {
    open (config-file)
    | get accounts
  }
}

# View and manage email
def mail [...accounts: string] {
  let accounts = if ($accounts | is-empty) {
    (default-accounts)
  } else {
    $accounts
  }

  let accounts = (
    $accounts
    | each {prepend "--account"}
    | flatten
  )

  aerc ...$accounts
}

alias email = mail

# View mail for all accounts
def "mail all" [] {
  aerc
}

# Show default accounts
def "mail default-accounts" [] {
  try {
    default-accounts
    | sort
    | to text --no-newline
  }
}

# TODO: add a command to add/edit default accounts, etc.

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
    notmuch new --no-hooks
  } else {
    notmuch new --no-hooks $account
  }
}
