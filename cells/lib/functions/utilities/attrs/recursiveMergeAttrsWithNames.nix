{ root, inputs, cell, }:
let inherit (inputs.nixpkgs.lib) zipAttrsWithNames foldl';
in names: f: zipAttrsWithNames names (_name: foldl' f { })
