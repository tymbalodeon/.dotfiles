def main [] {
  let nickname = (nickname)
  let password = (password)

  if ([$nickname $password] | any {is-empty}) {
    return
  }

  mkdir (config-path | path dirname)

$"address \"ircs+insecure://(ip-address)\"
nickname \"(nickname)\"
password \"(password)\"
"
  | save --force (config-path)
}
