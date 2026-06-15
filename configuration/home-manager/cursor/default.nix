{lib, ...}: {
  options.cursor.size = lib.mkOption {
    default = 16;
    type = lib.types.int;
  };
}
