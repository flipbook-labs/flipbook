rojo build tests.project.json -o tests.rbxl
run-in-roblox --place tests.rbxl --script tests/init.server.luau
rm tests.rbxl
