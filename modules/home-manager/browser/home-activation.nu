def open-secret [path: string] {
  try { open (brave-secrets-base | path join $path) }
}

def brave-sync-v2-seed [] {
  open-secret brave_sync_v2/seed
}

def sync-encryption_bootstrap_token_per_account-key [] {
  open-secret sync/encryption_bootstrap_token_per_account/key
}

def sync-encryption_bootstrap_token_per_account-value [] {
  open-secret sync/encryption_bootstrap_token_per_account/value
}

def preferences-file [] {
  $env.HOME
  | path join .config/BraveSoftware/Brave-Browser/Default/Preferences
}

def main [preferences: string] {
  let existing_preferences = if (preferences-file | path type) == file {
    open (preferences-file)
    | from json
  } else {
    {}
  }

  $preferences
  | from json
  | insert brave_sync_v2.seed (brave-sync-v2-seed)
  | insert sync.encryption_bootstrap_token_per_account {
      sync-encryption_bootstrap_token_per_account-key: (
        sync-encryption_bootstrap_token_per_account-value
      )
    }
  | merge deep $existing_preferences
  | to json
  | jq --compact-output .
  | save --force (preferences-file)
}
