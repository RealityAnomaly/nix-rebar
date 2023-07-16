{ root, ... }:
{ ... }: {
  # imports the common set of modules available by default
  imports = [ root.services.make-secure ];
}
