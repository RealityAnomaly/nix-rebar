{ root, inputs, cell, ... }: # scope::cell
{ config, lib, pkgs, ... }: # scope::eval-config
{
  security.pam.enableSudoTouchIdAuth = true;

  # security hardening related preferences
  system.defaults = {
    # enable Gatekeeper
    LaunchServices.LSQuarantine = true;

    # automatically install updates
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    # Application Layer Firewall
    alf = {
      allowdownloadsignedenabled = 0;
      allowsignedenabled = 1;
      globalstate = 1;
      loggingenabled = 0;
      stealthenabled = 1;
    };
  };
}
