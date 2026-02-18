def --wrapped zk [...args: string] {
  SHELL=$"(^which bash)" ^zk ...$args
}
