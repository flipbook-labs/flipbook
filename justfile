#!/usr/bin/env just --justfile

project_name := "flipbook"
plugins_dir := if os_family() == "unix" {
	"$HOME/Documents/Roblox/Plugins"
} else {
	"$LOCALAPPDATA/Roblox/Plugins"
}
plugin_path := plugins_dir / project_name + ".rbxm"
plugin_filename := file_name(plugin_path)

project_dir := "src"
example_dir := "example"
build_dir := "build"
packages_dir := "Packages"

build_project := "build.project.json"
dev_project := "dev.project.json"
tests_project := "tests.project.json"

tmpdir := `mktemp -d`
global_defs_path := tmpdir / "globalTypes.d.lua"
testez_defs_path := "testez.d.luau"
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

_build target output:
	#!/usr/bin/env sh
	set -euxo pipefail

	just clean

	mkdir -p {{ build_dir }}

	rojo sourcemap {{ build_project }} -o sourcemap-darklua.json
	darklua process {{ project_dir }} {{ build_dir }}

	if [[ "{{ target }}" = "prod" ]]; then
		rm -rf {{ build_dir / "**/*.spec.lua" }}
		rm -rf {{ build_dir / "**/*.story.lua" }}
		rm -rf {{ build_dir / "**/*.storybook.lua" }}

		rojo build -o {{ output }}
	else
		rojo build {{ dev_project }} -o {{ output }}
	fi

default:
	@just --list

wally-install:
	wally install
	rojo sourcemap {{ build_project }} -o {{ sourcemap_path }}
	wally-package-types --sourcemap {{ sourcemap_path }} {{ absolute_path(packages_dir) }}

clean:
	rm -rf {{ build_dir }}
	rm -rf {{ plugin_path }}
	rm -rf {{ plugin_filename }}

init:
	foreman install
	just wally-install

lint:
	selene {{ project_dir }}
	stylua --check {{ project_dir }}
	just _lint-file-extensions

build target="dev":
	just _build {{ target }} {{ plugin_path }}

build-watch:
	npx -y chokidar-cli "{{ project_dir }}/**/*" --initial \
		-c "just build" \

build-here target="dev" filename=plugin_filename:
	just _build {{ target }} {{ filename }}

test:
	rojo build {{ tests_project }} -o test-place.rbxl
	run-in-roblox --place test-place.rbxl --script tests/init.server.lua

analyze:
	curl -s -o {{ global_defs_path }} \
		-O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

	rojo sourcemap {{ tests_project }} -o {{ sourcemap_path }}

	luau-lsp analyze --sourcemap={{ sourcemap_path }} \
		--defs={{ global_defs_path }} \
		--defs={{ testez_defs_path }} \
		--settings="./.vscode/settings.json" \
		--ignore=**/_Index/** \
		{{ project_dir }}
