# Connect to IRC
def irc [] {
  senpai
}

# Copy the logs to the local machine and clear them from the server
def "irc archive" [] {
  # TODO: allow copying to remote (Dropbox)
  # TODO: allow option not to clear the server? requires merging logs later
  # TODO: allow archiving older than a certain date
  # TODO: set this up as a service on the server, that periodically uploads old logs to a remote?

  let logs = $"/var/lib/soju/logs/(nickname)"
  let temporary_directory = "/tmp/irc"

  ssh -t mazma $"
    sudo rm --force --recursive ($temporary_directory);
    mkdir --parents ($temporary_directory);
    sudo cp --recursive ($logs) ($temporary_directory);
    sudo chmod --recursive +rwx ($temporary_directory);
  " out+err> /dev/null

  let archive_directory = $"($env.HOME)/irc/(date now | format date %Y-%m-%d--%I-%M-%S)"

  mkdir $archive_directory
  scp -r $"mazma:($temporary_directory)/(nickname)" $archive_directory
  ssh mazma $"sudo rm --recursive ($temporary_directory); sudo rm --recursive ($logs)"
}
