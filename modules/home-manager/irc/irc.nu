# Connect to IRC
def irc [] {
  senpai
}

# Copy the logs to the local machine and clear them from the server
def "irc archive" [] {
  # TODO: ask for sudo password only once at beginning
  # TODO: exit if logs don't exist
  # TODO: allow copying to remote (Dropbox)
  # TODO: allow option not to clear the server? requires merging logs later
  # TODO: allow archiving older than a certain date
  # TODO: set this up as a service on the server, that periodically uploads old logs to a remote?

  let logs = $"/var/lib/soju/logs/(nickname)"
  let ip_address = (ip-address)
  let archive_base = $"($env.HOME)/irc"
  let archive_directory = $"($archive_base)/(date now | format date %Y-%m-%d--%I-%M-%S)"

  ^ssh -t $ip_address $"
    sudo rm --force --recursive ($archive_base);
    sudo mkdir --parents ($archive_directory)
    sudo cp --recursive ($logs) ($archive_directory);
    sudo chmod --recursive +rwx ($archive_directory);
  "
  scp -r $"($ip_address):($archive_directory)/(nickname)" $archive_directory
  ^ssh $ip_address $"sudo rm --recursive ($archive_base); sudo rm --recursive ($logs)"
}
