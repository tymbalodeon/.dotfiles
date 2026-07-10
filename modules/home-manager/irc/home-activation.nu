def main [] {
  let ip_address = (ip-address)
  let nickname = (nickname)
  let password = (password)

  if ([$ip_address $nickname $password] | any {is-empty}) {
    return
  }

  $"address \"ircs+insecure://(ip-address)\"
nickname \"(nickname)\"
password \"(password)\"
"
  | save --force (senpai-config-path)
}
