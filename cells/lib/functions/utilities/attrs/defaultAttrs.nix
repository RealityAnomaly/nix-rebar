{ root, inputs, cell, }:
attrs: default: f:
if attrs != null then f attrs else default
