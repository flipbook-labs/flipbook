#!/usr/bin/env just --justfile

project_name := "flipbook"
plugins_dir := if os_family() == "unix" {
	"$HOME/Documents/Roblox/Plugins"
} else {
	"$LOCALAPPDATA/Roblox/Plugins"
}
plugin_path := plugins_dir / project_name + ".rbxm"
tmpdir := `mktemp -d`

default:
  @just --list

clean:
	rm -rf {{plugin_path}}

lint:
	selene src/
	stylua --check src/

_build target watch:

build target watch:
	echo {{_get_project_file target}}
	rojo build -o {{plugins_dir}} / "flipbook.rbxm"

test: clean
    rojo build tests.project.json -o {{tmpdir / "tests.rbxl"}}
    run-in-roblox --place {{tmpdir / "tests.rbxl"}} --script tests/init.server.lua

analyze:
  curl -s -o "{{tmpdir}}/globalTypes.d.lua" -O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

  rojo sourcemap tests.project.json -o "{{tmpdir}}/sourcemap.json"

  luau-lsp analyze --sourcemap="{{tmpdir}}/sourcemap.json" --defs="{{tmpdir}}/globalTypes.d.lua" --defs=testez.d.lua --ignore=**/_Index/** src/
