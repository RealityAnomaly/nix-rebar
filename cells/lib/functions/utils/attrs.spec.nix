{ inputs, cell, lib, ... }:
let sub = cell.functions.utils.attrs;
in {
  snapshot = {
    countAttrs.expr = {
      empty = sub.countAttrs { };
      one = sub.countAttrs { foo = "bar"; };
    };

    defaultAttrs.expr = {
      present = sub.defaultAttrs { fob = "bar"; } { bar = "123"; } (attrs:
        attrs // {
          foo = "baz";
          bb = "foo";
        });
      missing = sub.defaultAttrs null { bar = "123"; } (attrs:
        attrs // {
          foo = "baz";
          bb = "foo";
        });
    };

    enumAttrs.expr = { present = sub.enumAttrs [ "foo" "baz" "123" ]; };

    extractPair.expr = {
      present = sub.extractPair (k: _v: k == "wbdawdbb") {
        "wbdawdbb" = "ababbaba";
        "dawdwbd" = "2812817";
      };
      missing =
        sub.extractPair (k: _v: k == "wbdawdbb") { "dawdwbd" = "2812817"; };
    };

    extractFilterAttrs.expr = {
      present = sub.extractFilterAttrs [ "foo1" "bar3" ] [
        {
          foo1 = "babrb";
          testtt = "123";
        }
        { test3 = "dijwdjw"; }
        { blah = "blagjshabh"; }
      ];
    };

    mapFlattenAttrs.expr = {
      present = sub.mapFlattenAttrs
        (cursor: lib.nameValuePair (lib.concatStringsSep "." cursor)) {
          foo = { baz = "123"; };
          bar = "foo";
        };
    };

    flattenAttrs.expr = {
      present = sub.flattenAttrs "__" {
        foo3.fcc = "1212";
        fbfbb = "sblah";
      };
    };

    genAttrs'.expr = sub.genAttrs' [ "foo3" "bar1" ] (value: {
      name = value;
      inherit value;
    });

    imapAttrsToList.expr =
      sub.imapAttrsToList (i: key: value: { inherit i key value; }) {
        foo1 = "barrwarbb";
        bbabbbd = "bbhbhbh";
        bhahbh = "121212";
        babj = "127127";
      };
  };
}
