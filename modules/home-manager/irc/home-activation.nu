def main [] {
  let nickname = (nickname)
  let password = (password)

  if ([$nickname $password] | any {is-empty}) {
    return
  }

  $"address \"ircs+insecure://mazma\"
nickname \"(nickname)\"
password \"(password)\"
"
  | save --force (senpai-config-path)
}
