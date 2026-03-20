# View and manage RSS feeds
export def main [] {
  newsboat
}

# Edit the urls files
export def "main urls edit" [] {
  ^$env.EDITOR ($env.XDG_CONFIG_HOME | path join newsboat/urls)
}
