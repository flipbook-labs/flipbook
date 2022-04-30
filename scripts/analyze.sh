#!/usr/bin/env bash

echo "Downloading Roblox type definitions"
curl https://raw.githubusercontent.com/JohnnyMorganz/luau-analyze-rojo/master/globalTypes.d.lua > globalTypes.d.lua

echo "Analyzing"
luau-analyze --defs=globalTypes.d.lua --defs=testez.d.lua --sourcemap=dev.project.json src/

echo "Cleaning up Roblox type definitions"
rm globalTypes.d.lua