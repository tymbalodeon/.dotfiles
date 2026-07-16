def main [] {
  gmail-accounts
  | each {
      |account|

      let address = $"($account.username)@gmail.com"
      let address_escaped = $"($account.username)%40gmail.com"

      try {
        let password = open ($account.password-path)
        let password_escaped = ($password | str replace --all " " %20)

        $"[($address)]
address-book-cmd = carddav-query -S ($account.username) %s
cache-headers = true
carddav-source-cred-cmd = echo ($password)
carddav-source = https://($address_escaped)@www.googleapis.com/carddav/v1/principals/($address)/lists/default
copy-to = Sent
default = INBOX
folders-sort = INBOX
from = ($account.real-name) <($address)>
outgoing = smtps+plain://($address_escaped):($password_escaped)@smtp.gmail.com:465
postpone = [Gmail]/Drafts
source = imaps://($address_escaped):($password_escaped)@imap.gmail.com:993"
        | to text
        | save --force ($env.HOME | path join .config/aerc/accounts.conf)
      } 
  }
}
 
