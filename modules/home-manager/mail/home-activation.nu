def main [] {
  let common_settings = "cache-headers = true
copy-to = Sent
folders = INBOX,Drafts,Sent,Trash,Spam,Archive
folders-sort = INBOX,Drafts,Sent,Trash,Spam,Archive"

  let gmail_accounts = (
    gmail-accounts
    | each {
        |account|

        try {
          let password = open ($account.password-path)
          let password_escaped = ($password | str replace --all " " %20)
          let address_escaped = $"($account.username)%40gmail.com"

          let configuration_lines = (
            $common_settings
            | append [
                # TODO: test me
                # $"address-book-cmd = carddav-query -S ($account.username) %s"
                # $"carddav-source-cred-cmd = echo ($password)"
                # $"carddav-source = https://($address_escaped)@www.googleapis.com/carddav/v1/principals/($address)/lists/default"
                $"folder-map = (folder-map-path)"
                $"from = (real-name) <($account.address)>"
                $"outgoing = smtps+plain://($address_escaped):($password_escaped)@smtp.gmail.com:465"
                $"source = imaps://($address_escaped):($password_escaped)@imap.gmail.com:993"
            ]
            | sort
          )

          $"[($account.address)]"
          | append $configuration_lines
          | to text
        }
    }
  )

  let proton_accounts = (
    protonmail-accounts
    | each {
        |account|

        try {
          let password = open ($account.password-path)
          let address_escaped = $"($account.username)%40pm.me"

          let configuration_lines = (
            $common_settings
            | append [
              $"aliases = (real-name) <*@gmail.com>,(real-name) <*@pm.me>,(real-name) <*@proton.me>"
              $"from = (real-name) <($account.address)>"
              $"outgoing = smtp+insecure://($address_escaped):($password)@127.0.0.1:1025"
              $"source = imap+insecure://($address_escaped):($password)@127.0.0.1:1143"
            ]
            | sort
          )

          $"[($account.address)]"
          | append $configuration_lines
          | to text
        }
    }
  )

  if ($proton_accounts | is-not-empty) {
    let config_base = ($env.HOME | path join .config/protonmail/bridge-v3)

    if ($config_base | path type) != dir {
      rm --force $config_base
      mkdir $config_base
    }

    try {
      open (protonmail-bridge-vault-file)
      | save --force ($config_base | path join vault.enc)
    }
  }

  $gmail_accounts
  | append $proton_accounts
  | to text --no-newline
  | save --force ($env.HOME | path join .config/aerc/accounts.conf)
}
 
