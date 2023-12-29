# https://just.systems/man/en/

default:
  @just --list --unsorted --color=always | rg -v "\s*default"

# feedback
icon-ok := '✔'
msg-ok := icon-ok + " OK"
msg-done := icon-ok + " Done"

# legal/reuse
copyright := 'Alex XZ Cypher Zero <legal@alex0.net>'
default-license := 'ARR'
public-license := 'MIT'
public-domain-license := 'CC0-1.0'

# binary cache
cachix-cache-name := 'cobalt'
cachix-exec := "cachix watch-exec --jobs 2 " + cachix-cache-name

# environment
sys-gen-path := env_var('REBAR_SYS_DRV')
hm-gen-path := env_var('REBAR_HOME_DRV')
hm-fragment := quote( env_var('USER') + '@' + `hostname` )

# project dirs
prj-root := env_var('PRJ_ROOT')

# different rebuild command based on what platform we're running on
sys-cmd := if os() == "linux" {
  "nixos-rebuild-override"
} else if os() == "macos" {
  "darwin-rebuild-override"
} else { "nix build" }

# section::utilities

# <- Convert a JSON file to a Nix expression
json2nix file:
  nix eval --expr 'builtins.fromJSON (builtins.readFile {{file}})' --impure

# <- Convert a TOML file to a Nix expression
toml2nix file:
  nix eval --expr 'builtins.fromTOML (builtins.readFile {{file}})' --impure

# section::linting

# <- Lint files
lint *FILES=prj-root: (deadnix "check" FILES) (statix "check" FILES)

# <- Lint and format files
fmt *FILES=prj-root: (lint FILES)
  treefmt --no-cache

# <- Write automatic linter fixes to files
fix *FILES=prj-root: (deadnix "fix" FILES) (statix "fix" FILES)

# <- Run `statix`
[private]
statix action +FILES=prj-root:
  @ # Note that stderr is silenced due to an upstream bug
  @ # https://github.com/nerdypepper/statix/issues/59
  @ for f in {{FILES}}; do \
    statix {{action}} -- "$f" 2>/dev/null; \
  done

# <- Run `deadnix` with sane options
[private]
deadnix action +FILES=prj-root:
  @deadnix \
    {{ if action == "fix" { "--edit" } else { "--fail" } }} \
    --no-underscore \
    --no-lambda-pattern-names \
    {{FILES}}

# section:tests
test:
  nixt -v
  namaka check

# section::licensing

# <- Validate the project's licensing and copyright info
license-check:
  reuse lint

# <- Add a ARR license header to the specified files
license-arr +FILES:
  reuse annotate -l {{default-license}} -c '{{copyright}}' {{FILES}}

# <- Add a MIT license header to the specified files
license-public +FILES:
  reuse annotate -l {{public-license}} -c '{{copyright}}' {{FILES}}

# <- Add a public domain CC0-1.0 license header to the specified files
license-public-domain +FILES:
  reuse annotate -l {{public-domain-license}} -c '{{copyright}}' {{FILES}}
