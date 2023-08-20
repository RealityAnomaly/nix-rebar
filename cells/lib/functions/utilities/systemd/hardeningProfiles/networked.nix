{ root, inputs, cell, }:
let inherit (root.utilities.systemd) hardeningProfiles;
in hardeningProfiles.isolate // {
  IPAddressDeny = [ "" ];
  PrivateNetwork = false;
  RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
}
