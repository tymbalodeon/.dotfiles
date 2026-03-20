epxort def --wrapped main [...args: string] {
  SHELL=$"(^which bash)" ^zk ...$args
}
