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

analysis_project := "analysis.project.json"
build_project := "build.project.json"
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
	set -euxo pipefail

	os={{ os() }}

	if [[ "$os" == "macos" ]]; then
		echo "/Applications/RobloxStudio.app/Contents/MacOS/ClientSettings"
	elif [[ "$os" == "windows" ]]; then
		robloxStudioPath=$(find "$LOCALAPPDATA/Roblox/Versions" -name "RobloxStudioBeta.exe")
		dir=$(dirname $robloxStudioPath)
		echo "$dir/ClientSettings"
	fi

_compile target:
	#!/usr/bin/env bash
	set -euxo pipefail

	just clean

	mkdir -p {{ build_dir }}

	rojo sourcemap {{ build_project }} -o sourcemap-darklua.json
	darklua process {{ project_dir }} {{ build_dir }}

	if [[ "{{ target }}" = "dev" ]]; then
		darklua process example {{ build_dir / "Example" }}
	fi

_build target output:
	#!/usr/bin/env bash
	set -euxo pipefail

	just _compile {{ target }}

	if [[ "{{ target }}" = "prod" ]]; then
		rm -rf {{ build_dir / "**/*.spec.lua" }}
		rm -rf {{ build_dir / "**/*.story.lua" }}
		rm -rf {{ build_dir / "**/*.storybook.lua" }}
	fi

	rojo build -o {{ output }}

default:
	@just --list

clean:
	rm -rf {{ build_dir }}
	rm -rf {{ plugin_path }}
	rm -rf {{ plugin_filename }}

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

build target="dev":
	just _build {{ target }} {{ plugin_path }}

build-watch:
	npx -y chokidar-cli "{{ project_dir }}/**/*" --initial \
		-c "just build" \

build-here target="dev" filename=plugin_filename:
	just _build {{ target }} {{ filename }}

set-flags:
	#!/usr/bin/env bash
	set -euxo pipefail

	clientSettings=$(just _get-client-settings)
	mkdir -p "$clientSettings"
	cp -R tests/ClientAppSettings.json "$clientSettings"

test: clean
	just set-flags
	just _compile dev
	rojo build {{ tests_project }} -o test-place.rbxl
	run-in-roblox --place test-place.rbxl --script tests/run-tests.luau

analyze:
	curl -s -o {{ global_defs_path }} \
		-O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/master/scripts/globalTypes.d.lua

	rojo sourcemap {{ analysis_project }} -o {{ sourcemap_path }}

	luau-lsp analyze --sourcemap={{ sourcemap_path }} \
		--defs={{ global_defs_path }} \
		--settings="./.vscode/settings.json" \
		--ignore=**/_Index/** \
		{{ project_dir }}
