{ root, inputs, cell, ... }:
{ config, lib, pkgs, ... }: {
  # More strict hardening profile for machines that don't need to run any exotic applications (i.e. servers)
  imports = [ root.security.hardening.default ];

  environment = {
    # breaks some applications, spotify being one of them
    memoryAllocator.provider = "scudo";
    variables.SCUDO_OPTIONS = "ZeroContents=1";
  };

  boot = {
    # Warning: some applications can completely crash the system
    kernelPackages = pkgs.linuxPackages_hardened;

    kernelParams = [
      # Slab/slub sanity checks, redzoning, and poisoning
      "slub_debug=FZP"

      # Overwrite free'd memory
      "page_poison=1"

      # Enable page allocator randomization
      "page_alloc.shuffle=1"
    ];
  };

  security = {
    # causes a serious performance hit
    # allowSimultaneousMultithreading = false;

    # we want to be able to load modules on demand
    # lockKernelModules = true;
  };
}
