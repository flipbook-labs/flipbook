#!/bin/sh

set -e

FOLDER=$1

find $FOLDER -name '__tests__' -type d -exec rm -r {} +
find $FOLDER -name '__tests__' -type d -exec rm -r {} +
find $FOLDER -name '__fixtures__' -type d -exec rm -r {} +
find $FOLDER -name '__testUtils__' -type d -exec rm -r {} +
find $FOLDER -name 'TestMatchers' -type d -exec rm -r {} +
find $FOLDER -name '.robloxrc' -type f -exec rm -r {} +
find $FOLDER -name '*.spec.lua' -type f -exec rm -r {} +
find $FOLDER -name 'jest.config.lua' -type f -exec rm -r {} +
