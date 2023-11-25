#!/usr/bin/env bash

curl -s -O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

rojo sourcemap tests.project.json -o sourcemap.json

luau-lsp analyze --sourcemap=sourcemap.json --defs=globalTypes.d.lua --defs=testez.d.lua --ignore=**/_Index/** src/

rm globalTypes.d.lua
