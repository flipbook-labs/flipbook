#!/bin/bash -e

selene src
stylua -c src
roblox-cli analyze test-model.project.json
roblox-cli run --load.model test-model.project.json --run bin/spec.lua