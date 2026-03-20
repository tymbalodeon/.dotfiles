export def --wrapped main [...args: string] {
  neomutt ...$args
}

export def "config edit" [] {
  ^$env.EDITOR ($env.XDG_CONFIG_HOME | path join neomutt/neomuttrc)
}
