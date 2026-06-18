{
  config,
  secrets,
  sops-nix,
  ...
}: {
  imports = [sops-nix.nixosModules.sops];

  sops = {
    age.keyFile = "${config.users.users.${config.nixos.username}.home}/.config/sops/age/keys.txt";
    defaultSopsFile = "${secrets}/secrets.yaml";
    validateSopsFiles = false;
  };
}
