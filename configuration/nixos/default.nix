{inputs, ...}: {
  imports =
    map
    (name: ./${name})
    (builtins.attrNames (
      inputs.nixpkgs.lib.attrsets.filterAttrs
      (attr: value: value == "directory")
      (builtins.readDir ./.)
    ));
}
