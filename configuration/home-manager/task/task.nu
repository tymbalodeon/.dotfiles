def --wrapped task [...args: string] {
  ^task sync out> /dev/null
  ^task ...$args
  ^task sync out> /dev/null
}
