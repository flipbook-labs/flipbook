#!/usr/bin/env bash

curl -s -O https://raw.githubusercontent.com/JohnnyMorganz/luau-analyze-rojo/master/globalTypes.d.lua

luau-analyze --project=dev.project.json --defs=globalTypes.d.lua --defs=testez.d.lua src/

rm Packages/.luaurc
rm globalTypes.d.lua
