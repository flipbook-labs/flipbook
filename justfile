#!/usr/bin/env just --justfile

project_name := "flipbook"
plugins_dir := if os_family() == "unix" {
	"$HOME/Documents/Roblox/Plugins"
} else {
	"$LOCALAPPDATA/Roblox/Plugins"
}
plugin_path := plugins_dir / project_name + ".rbxm"

project_dir := absolute_path("src")
example_dir := absolute_path("src")
packages_dir := absolute_path("Packages")
tests_project := "tests.project.json"

tmpdir := `mktemp -d`
global_defs_path := tmpdir / "globalTypes.d.lua"
sourcemap_path := tmpdir / "sourcemap.json"

_lint-file-extensions:
	#!/usr/bin/env bash
	set -euo pipefail
	files=$(find {{ project_dir }} {{ example_dir }} -iname "*.lua")
	if [[ -n "$files" ]]; then
		echo "Error: one or more files are using the '.lua' extension. Please update these to '.luau' and try again"
		echo "$files"
		exit 1
	fi

_get-client-settings:
	#!/usr/bin/env bash
	if [[ {{ os_family() }} -eq "macos" ]]; then
		echo "/Applications/RobloxStudio.app/Contents/MacOS/ClientSettings"
	elif [[ {{ os_family() }} -eq "windows" ]]; then
		robloxStudioPath=$(find "$LOCALAPPDATA/Roblox/Versions/" -regex "RobloxStudio*.exe")
		dir=$(dirname $robloxStudioPath)
		echo "$dir/ClientSettings"
	fi

default:
	@just --list

wally-install:
	wally install
	rojo sourcemap {{ tests_project }} -o {{ sourcemap_path }}
	wally-package-types --sourcemap {{ sourcemap_path }} {{ absolute_path(packages_dir) }}

init:
	foreman install
	just wally-install

lint:
	selene {{ project_dir }}
	stylua --check {{ project_dir }}
	just _lint-file-extensions

build:
	rojo build -o {{ plugin_path }}

build-watch:
	npx -y chokidar-cli "{{ project_dir }}/**/*" --initial \
		-c "just build" \

set-flags:
	#!/usr/bin/env bash
	set -euo pipefail
	clientSettings=$(just _get-client-settings)
	mkdir -p "$clientSettings"
	cp -R tests/ClientAppSettings.json "$clientSettings"

test:
	just set-flags
	rojo build {{ tests_project }} -o test-place.rbxl
	run-in-roblox --place test-place.rbxl --script tests/run-tests.luau

analyze:
	curl -s -o {{ global_defs_path }} \
		-O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

	rojo sourcemap {{ tests_project }} -o {{ sourcemap_path }}

	luau-lsp analyze --sourcemap={{ sourcemap_path }} \
		--defs={{ global_defs_path }} \
		--settings="./.vscode/settings.json" \
		--ignore=**/_Index/** \
		{{ project_dir }}

