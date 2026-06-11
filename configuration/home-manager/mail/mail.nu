def --wrapped mail [...args: string] {
  neomutt ...$args
}

def "mail config edit" [] {
  ^$env.EDITOR ($env.XDG_CONFIG_HOME | path join neomutt/neomuttrc)
}
