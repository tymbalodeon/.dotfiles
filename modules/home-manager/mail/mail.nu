def config-file [] {
  get-config-file mail
}

def default-accounts [] {
  try {
    open (config-file)
    | get accounts
  }
}

def get-accounts [accounts: list<string>] {
  let accounts = if ($accounts | is-empty) {
    (default-accounts)
  } else {
    $accounts
  }

}

def get-accounts-with-flag [accounts: list<string>] {
  get-accounts $accounts
  | each {prepend "--account"}
  | flatten
}

# View and manage email
def mail [...accounts: string] {
  aerc ...(get-accounts-with-flag $accounts)
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
def "mail sync" [...accounts: string] {
  let accounts = (get-accounts $accounts)

  for account in $accounts {
    try {
      mbsync $account
    }

    notmuch new --no-hooks $account
  }
}

# Sync all email accounts
def "mail sync all" [] {
  try { mbsync --all }
  notmuch new --no-hooks
}
