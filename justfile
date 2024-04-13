#!/usr/bin/env just --justfile

project_name := "flipbook"
plugins_dir := if os_family() == "unix" {
	"$HOME/Documents/Roblox/Plugins"
} else {
	"$LOCALAPPDATA/Roblox/Plugins"
}
plugin_path := plugins_dir / project_name + ".rbxm"

project_dir := absolute_path("src")
packages_dir := absolute_path("Packages")
tests_project := "tests.project.json"

tmpdir := `mktemp -d`
global_defs_path := tmpdir / "globalTypes.d.lua"
sourcemap_path := tmpdir / "sourcemap.json"

_lint-file-extensions:
	#!/usr/bin/env bash
	files=$(find src example -iname "*.lua")
	if [[ -n "$files" ]]; then
		echo "Error: one or more files are using the '.lua' extension. Please update these to '.luau' and try again"
		echo "$files"
		exit 1
	fi

default:
  @just --list

wally-install:
	wally install
	rojo sourcemap {{ tests_project }} -o {{ sourcemap_path }}
	wally-package-types --sourcemap {{ sourcemap_path }} {{ packages_dir }}

init:
	foreman install
	just wally-install

lint:
	selene {{ project_dir }}
	stylua --check {{ project_dir }}
	just _lint-file-extensions

build:
	rojo build -o {{ plugins_dir }} / "flipbook.rbxm"

test:
    rojo build {{ tests_project }} -o test-place.rbxl
    run-in-roblox --place test-place.rbxl --script tests/init.server.lua

analyze:
	curl -s -o {{ global_defs_path }} \
		-O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

	rojo sourcemap {{ tests_project }} -o {{ sourcemap_path }}

	luau-lsp analyze --sourcemap={{ sourcemap_path }} \
		--defs={{ global_defs_path }} \
		--settings="./.vscode/settings.json" \
		--ignore=**/_Index/** \
		{{ project_dir }}

