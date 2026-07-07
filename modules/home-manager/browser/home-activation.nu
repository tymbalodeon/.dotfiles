def main [json: string] {
  $json
  | from json
  | insert brave_sync_v2.seed (brave-sync-v2-seed)
  | insert sync.encryption_bootstrap_token_per_account {
    sync-encryption_bootstrap_token_per_account-key: sync-encryption_bootstrap_token_per_account-value
  }
  | to json
}
