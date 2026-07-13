def main [] {
  let nickname = (nickname)
  let password = (password)

  if ([$nickname $password] | any {is-empty}) {
    return
  }

  mkdir (senpai-config-path | path dirname)

  $"address \"ircs+insecure://mazma\"
nickname \"(nickname)\"
password \"(password)\"
"
  | save --force (senpai-config-path)
}
