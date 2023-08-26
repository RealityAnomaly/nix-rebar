{ root, inputs, cell, }:

let
  inherit (builtins)
    attrNames concatStringsSep filter mapAttrs pathExists readFile storeDir tail
    toJSON trace tryEval;
  inherit (inputs.nixpkgs.lib)
    filterAttrs flip hasPrefix id pipe removePrefix splitString warn;
  inherit (inputs) haumea namaka;
  inherit (root) flattenAttrs stripPaths;

in args:

let
  src = toString (args.src or (warn
    "namaka.load: `flake` and `dir` have been deprecated, use `src` directly instead"
    (args.flake + "/${args.dir or "tests"}")));

  tests = haumea.lib.load (removeAttrs args [ "flake" "dir" ] // {
    inherit src;
    loader = haumea.lib.loaders.path;
  });

  results = flip mapAttrs (flattenAttrs "__" tests) (name: path:
    assert hasPrefix "." name
      -> throw "invalid snapshot '${name}', names should not start with '.'";

    let
      test = import path args.inputs;
      inherit (test) expr;
      format = test.format or "json";

      snapPath = "${src}/_snapshots/${name}";
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
    dir = pipe src [
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
