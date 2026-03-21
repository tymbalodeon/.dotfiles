# View and manage RSS feeds
def rss [] {
  newsboat
}

# Edit the urls files
def "rss urls edit" [] {
  ^$env.EDITOR ($env.XDG_CONFIG_HOME | path join newsboat/urls)
}
