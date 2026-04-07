export def main [...args: string] {
  job spawn { run-external nohup ...$args } out+err> /dev/null
}
