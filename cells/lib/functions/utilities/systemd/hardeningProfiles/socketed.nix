{ root, inputs, cell, }:
let inherit (root.utilities.systemd) hardeningProfiles;
in hardeningProfiles.isolate // { RestrictAddressFamilies = [ "AF_UNIX" ]; }
