rojo build tests.project.json -o tests.rbxl
run-in-roblox --place tests.rbxl --script tests/init.server.lua
rm tests.rbxl
