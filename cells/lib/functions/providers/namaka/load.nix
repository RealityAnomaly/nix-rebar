{ root, inputs, cell, }:

let
  inherit (builtins)
    attrNames concatStringsSep filter pathExists readFile storeDir tail
    toJSON trace tryEval;
  inherit (inputs.nixpkgs.lib)
    filterAttrs flip hasPrefix id pipe removePrefix splitString attrValues foldl' mapAttrs mapAttrs' nameValuePair;
  inherit (inputs) namaka;
  inherit (root) stripPaths;

in args:

let
  inherit (args) state;
  merged = foldl' (a: b: a // b) { } (attrValues (
    mapAttrs (prefix: mapAttrs' (n: nameValuePair "${prefix}__${n}")) args.tests
  ));

  results = flip mapAttrs merged (name: test:
    assert hasPrefix "." name
      -> throw "invalid snapshot '${name}', names should not start with '.'";

    let
      inherit (test) expr;
      format = test.format or "json";

      snapPath = "${state}/_snapshots/${name}";
      old = pathExists snapPath;
      snap = readFile snapPath;
      prefix = ''
        #${format}
      '';
      f = root.providers.namaka.formats.${format};
      value = (f.serialize or id) (stripPaths expr);
      expected = (f.parse or id) (removePrefix prefix snap);

    in if old && hasPrefix prefix snap && tryEval expected == {
      inherit value;
      success = true;
    } then
      true
    else {
      inherit format value old;
    });

  msg = {
    dir = pipe state [
      (removePrefix storeDir)
      (splitString "/")
      (filter (x: x != ""))
      tail
      (concatStringsSep "/")
    ];
    inherit results;
  };

  failures = attrNames (filterAttrs (_: res: res ? value) results);

in assert trace "namaka=${toJSON msg}" true;

if failures == [ ] then
  { }
else
  throw "the following tests failed: ${concatStringsSep "," failures}"
