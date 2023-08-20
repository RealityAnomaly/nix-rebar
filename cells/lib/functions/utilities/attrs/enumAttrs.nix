/* Convert a list of strings to an attrset where the keys match the values.

   Example:
     enumAttrs ["foo" "bar"]
     => {foo = "foo"; bar = "bar";}
*/
{ root, inputs, cell, }:
let inherit (inputs.nixpkgs.lib) genAttrs id;
in enum: genAttrs enum id
