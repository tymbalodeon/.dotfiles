def --wrapped task [...args: string] {
  ^task sync
  ^task ...$args
  ^task sync
}
