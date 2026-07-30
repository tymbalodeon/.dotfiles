{
  environment.sessionVariables.PROTON_PASS_LINUX_KEYRING = "dbus";
  security.pam.services.login.enableGnomeKeyring = true;
}
