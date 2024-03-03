#!/usr/bin/env just --justfile

plugins_dir := if os_family() == "unix" {
	"$HOME/Documents/Roblox/Plugins"
} else {
	"$LOCALAPPDATA/Roblox/Plugins"
}

source_dir := "src"
build_dir := "build"
testez_defs_path := "testez.d.lua"
plugin_filename := "flipbook.rbxm"
plugin_output := plugins_dir / plugin_filename

default_project := "default.project.json"
tests_project := "tests.project.json"
build_project := "build.project.json"

tmpdir := `mktemp -d`

global_defs_path := tmpdir / "globalTypes.d.lua"
sourcemap_path := tmpdir / "sourcemap.json"

default:
  @just --list

clean:
	rm -rf {{ build_dir }}
	rm -rf {{ plugin_output }}
	rm -rf {{ plugin_filename }}

lint:
	selene {{ source_dir }}
	stylua --check {{ source_dir }}

_prune:
	rm -rf {{ build_dir / "**/*.spec.lua" }}
	rm -rf {{ build_dir / "**/*.story.lua" }}
	rm -rf {{ build_dir / "**/*.storybook.lua" }}

_build target output:
	just clean

	mkdir -p {{ build_dir }}

	rojo sourcemap {{ default_project }} -o sourcemap.json
	darklua process {{ source_dir }} {{ build_dir }}

	{{ if target == "prod" { `just _prune` } else { `` } }}

	rojo build {{ build_project }} -o {{ output }}

init:
	foreman install
	just wally-install

wally-install:
	wally install
	rojo sourcemap {{ default_project }} -o {{ sourcemap_path }}
	wally-package-types --sourcemap {{ sourcemap_path }} Packages/

build target="dev":
	just _build {{ target }} {{ plugin_output }}

build-watch target="dev":
	npx -y chokidar-cli "{{ source_dir }}/**/*" --initial \
		-c "just _build {{ target }} {{ build_dir }}" \

build-here target="dev" filename=plugin_filename:
	just _build {{ target }} {{ filename }}

test: clean
	rojo build tests.project.json -o {{ tmpdir / "tests.rbxl" }}
	run-in-roblox --place {{ tmpdir / "tests.rbxl" }} --script tests/init.server.lua

analyze:
	curl -s -o {{ global_defs_path }} \
		-O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

	rojo sourcemap {{ tests_project }} -o {{ sourcemap_path }}

	luau-lsp analyze --sourcemap={{ sourcemap_path }} \
		--defs={{ global_defs_path }} \
		--defs={{ testez_defs_path }} \
		--settings="./.vscode/settings.json" \
		--ignore=**/_Index/** \
		{{ source_dir }}
