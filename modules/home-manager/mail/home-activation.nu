def main [] {
  gmail-accounts
  | each {
      |account|

      try {
        let password = open ($account.password-path)
        let password_escaped = ($password | str replace --all " " %20)
        let address = $"($account.username)@gmail.com"
        let address_escaped = $"($account.username)%40gmail.com"

          $"[($address)]
address-book-cmd = carddav-query -S ($account.username) %s
cache-headers = true
carddav-source-cred-cmd = echo ($password)
carddav-source = https://($address_escaped)@www.googleapis.com/carddav/v1/principals/($address)/lists/default
copy-to = Sent
folders = Inbox,Drafts,Sent,Trash,Spam,Archive
folder-map = (folder-map-path)
folders-sort = Inbox,Starred,Drafts,Sent,Trash,Spam
from = ($account.real-name) <($address)>
outgoing = smtps+plain://($address_escaped):($password_escaped)@smtp.gmail.com:465
source = imaps://($address_escaped):($password_escaped)@imap.gmail.com:993"
        | to text
      }
  }
  | to text --no-newline
  | save --force ($env.HOME | path join .config/aerc/accounts.conf)
}
 
