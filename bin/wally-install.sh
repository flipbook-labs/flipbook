#!/usr/bin/env bash

set -e

wally install

git clone https://github.com/flipbook-labs/csf-lua Packages/CSF

rojo sourcemap tests.project.json --output sourcemap.json

wally-package-types --sourcemap sourcemap.json Packages/
