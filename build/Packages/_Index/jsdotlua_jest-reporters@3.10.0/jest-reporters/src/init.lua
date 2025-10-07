-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-reporters/src/index.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local exports = {}

local getResultHeader = require(script:WaitForChild('getResultHeader')).default
local getSnapshotStatus = require(script:WaitForChild('getSnapshotStatus')).default
local getSnapshotSummary = require(script:WaitForChild('getSnapshotSummary')).default

local utilsModule = require(script:WaitForChild('utils'))
local formatTestPath = utilsModule.formatTestPath
local getSummary = utilsModule.getSummary
local printDisplayName = utilsModule.printDisplayName
local relativePath = utilsModule.relativePath
local trimAndFormatPath = utilsModule.trimAndFormatPath

local BaseReporterModule = require(script:WaitForChild('BaseReporter'))
exports.BaseReporter = BaseReporterModule.default
export type BaseReporter = BaseReporterModule.BaseReporter

local DefaultReporterModule = require(script:WaitForChild('DefaultReporter'))
exports.DefaultReporter = DefaultReporterModule.default
export type DefaultReporter = DefaultReporterModule.DefaultReporter

local SummaryReporterModule = require(script:WaitForChild('SummaryReporter'))
exports.SummaryReporter = SummaryReporterModule.default
export type SummaryReporter = SummaryReporterModule.SummaryReporter

local VerboseReporterModule = require(script:WaitForChild('VerboseReporter'))
exports.VerboseReporter = VerboseReporterModule.default
export type VerboseReporter = VerboseReporterModule.VerboseReporter

local typesModule = require(script:WaitForChild('types'))
export type Context = typesModule.Context
export type Reporter = typesModule.Reporter
export type ReporterOnStartOptions = typesModule.ReporterOnStartOptions
export type ReporterContext = typesModule.ReporterContext
export type SummaryOptions = typesModule.SummaryOptions
export type Test = typesModule.Test

local utils = {
	formatTestPath = formatTestPath,
	getResultHeader = getResultHeader,
	getSnapshotStatus = getSnapshotStatus,
	getSnapshotSummary = getSnapshotSummary,
	getSummary = getSummary,
	printDisplayName = printDisplayName,
	relativePath = relativePath,
	trimAndFormatPath = trimAndFormatPath,
}

exports.utils = utils

return exports
