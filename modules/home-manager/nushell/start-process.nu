def start-process [...args: string] {
  job spawn { run-external nohup ...$args } out+err> /dev/null
}
