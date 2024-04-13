#!/usr/bin/env bash

set -euo pipefail

echo "Lint file extensions"
files=$(find src example -iname "*.lua")
if [[ -n "$files" ]]; then
	echo "Error: one or more files are using the '.lua' extension. Please update these to '.luau' and try again"
	echo "$files"
	exit 1
fi
