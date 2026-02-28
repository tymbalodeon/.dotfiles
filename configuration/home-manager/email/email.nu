def --wrapped email [...args: string] {
  neomutt ...$args
}

def "email config edit" [] {
  ^$env.EDITOR ($env.XDG_CONFIG_HOME | path join neomutt/neomuttrc)
}
