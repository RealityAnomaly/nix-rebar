{ root, inputs, cell, }:
let inherit (root.nixos.systemd) hardeningProfiles;
in hardeningProfiles.isolate // { RestrictAddressFamilies = [ "AF_UNIX" ]; }
