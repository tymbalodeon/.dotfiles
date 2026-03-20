# View and manage RSS feeds
export def --wrapped main [...args: string] {
  newsboat ...$args
}

# Edit the urls files
export def "urls edit" [] {
  ^$env.EDITOR ($env.XDG_CONFIG_HOME | path join newsboat/urls)
}
