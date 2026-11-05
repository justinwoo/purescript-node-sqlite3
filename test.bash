#! /usr/bin/env nix-shell
#! nix-shell shell.nix -i bash

set -e

npx --yes yarn@1.22.22

npx --yes spago@1.0.5 build

node ./test/index.mjs
