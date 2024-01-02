#!/usr/bin/env bash

set -e

wally install

rojo sourcemap tests.project.json --output sourcemap.json

wally-package-types --sourcemap sourcemap.json Packages/
