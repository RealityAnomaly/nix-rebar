{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }:
let inherit (inputs) hardware;
in {
  imports = [
    hardware.common-pc-laptop
    hardware.common-pc-laptop-ssd
    hardware.common-cpu-intel-kaby-lake

    root.hardware.capabilities.fingerprint.default
  ];

  # thunderbolt support
  services.hardware.bolt.enable = true;

  # hardware video offload
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
