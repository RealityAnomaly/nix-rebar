{ root, inputs, cell, ... }:
{ self, config, lib, pkgs, ... }: {
  imports = [
    root.classes.server.hardening
    root.classes.server.systemd
    root.classes.server.trim

    # enable SSH by default for servers
    root.security.sshd.default
  ];

  security = {
    # Disable password requirements for sudo, please, doas
    sudo.wheelNeedsPassword = lib.mkDefault false;
    please.wheelNeedsPassword = lib.mkDefault false;
    doas.wheelNeedsPassword = lib.mkDefault false;
  };

  programs.vim.defaultEditor = lib.mkDefault true;

  # Delegate the hostname setting to dhcp/cloud-init by default
  networking.hostName = lib.mkDefault "";

  # UTC everywhere!
  time.timeZone = lib.mkDefault "UTC";

  # use TCP BBR has significantly increased throughput and reduced latency for connections
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
