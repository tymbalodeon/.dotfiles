def config-file [] {
  get-config-file mail
}

def default-accounts [] {
  try {
    open (config-file)
    | get accounts
  } catch {
    []
  }
}

def get-accounts [accounts: list<string>] {
  if ($accounts | is-empty) {
    default-accounts
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
  let accounts = (get-accounts-with-flag $accounts)

  if ($accounts | is-empty) {
    aerc
  } else {
    aerc ...$accounts
  }
}

alias email = mail

# View mail for all accounts
def "mail all" [] {
  aerc
}

# Show default accounts
def "mail default-accounts" [] {
  default-accounts
  | sort
  | to text --no-newline
}

# Clear default accounts
def "mail default-accounts clear" [] {
  rm --force --recursive (config-file)
}

# Add default accounts
def "mail default-accounts add" [
  ...accounts: string # Accounts to add to the default accounts
  --clear # Clear any existing default accounts
] {
  let accounts = if $clear {
    $accounts
  } else {
    default-accounts
    | append $accounts
    | uniq
    | sort
  }

  create-config-directory

  {accounts: $accounts}
  | save --force (config-file)
}

# Remove default accounts
def "mail default-accounts remove" [...accounts: string] {
  let default_accounts = (default-accounts)

  if ($default_accounts | is-empty) {
    return
  }

  create-config-directory

  $default_accounts
  | where {$in not-in $accounts}
  | save --force (config-file)
}

# Sync email
def "mail sync" [
  ...accounts: string # Accounts to sync
  --verbose # Display what is happening
] {
  let accounts = (get-accounts $accounts)

  if ($accounts | is-empty) {
    try {
      if $verbose {
        mbsync --verbose
      } else {
        mbsync
      }
    }

    notmuch new --no-hooks
  } else {
    for account in $accounts {
      try {
        if $verbose {
          mbsync --verbose $account
        } else {
          mbsync $account
        }
      }

      notmuch new --no-hooks $account
    }
  }
}

# Sync all email accounts
def "mail sync all" [] {
  try { mbsync --all }
  notmuch new --no-hooks
}
