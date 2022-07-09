#!/usr/bin/env bash

curl -s -O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

cp .github/workflows/.luaurc Packages
rojo sourcemap dev.project.json -o sourcemap.json

luau-lsp analyze --sourcemap=sourcemap.json --defs=globalTypes.d.lua --defs=testez.d.lua src/

rm Packages/.luaurc
rm globalTypes.d.lua
