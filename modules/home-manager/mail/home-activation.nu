def escape [address: string] {
  $address  
  | str replace "@" "%40"
  | str replace --all " " "%20"
}

def main [] {
  let common_settings = "cache-headers = true
check-mail = 1m
copy-to = Sent
folders = INBOX,Drafts,Sent,Trash,Spam,Archive,All Mail
folders-sort = INBOX,Drafts,Sent,Trash,Spam,Archive,All Mail"

  let gmail_accounts = (
    gmail-accounts
    | each {
        |account|

        try {
          let password = open ($account.password-path)
          let password_escaped = (escape $password)
          let address_escaped = (escape $account.address)

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
    protonmail-addresses
    | each {
        |address|

        try {
          let address_escaped = (escape $address)
          let cred_cmd = $"(nushell-path) (cred-cmd) (hostname)"

          let configuration_lines = (
            $common_settings
            | append [
              $"aliases = (real-name) <*@gmail.com>,(real-name) <*@pm.me>,(real-name) <*@proton.me>"
              $"from = (real-name) <($address)>"
              $"outgoing = smtp+insecure://($address_escaped)@127.0.0.1:1025"
              $"outgoing-cred-cmd = ($cred_cmd)"
              $"source = imap+insecure://($address_escaped)@127.0.0.1:1143"
              $"source-cred-cmd = ($cred_cmd)"
            ]
            | sort
          )

          $"[($address)]"
          | append $configuration_lines
          | to text
        }
    }
  )

  $gmail_accounts
  | append $proton_accounts
  | to text --no-newline
  | save --force ($env.HOME | path join .config/aerc/accounts.conf)
}
 
