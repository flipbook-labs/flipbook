local HttpService = game:GetService("HttpService")

local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local AppMode = require("@root/Enums/AppMode")
local CommonTypes = require("@root/Common/types")
local getBuildInfo = require("@root/Common/getBuildInfo")
local logger = require("@root/logger")
local requestAsync = require("@root/Http/requestAsync")

type AppMode = AppMode.AppMode
type ConsentState = Telemetry.ConsentState
type Pluginlike = CommonTypes.Pluginlike
type TelemetryClient = Telemetry.TelemetryClient
type TelemetryEnvelope = Telemetry.TelemetryEnvelope

local STORAGE_KEY = "FlipbookTelemetry"
local LEGACY_SETTINGS_KEY = "FlipbookUserSettings"

local function getLegacyConsent(plugin: Pluginlike): ConsentState?
	local success, value = pcall(function()
		return plugin:GetSetting(LEGACY_SETTINGS_KEY)
	end)
	if not success or typeof(value) ~= "string" then
		return nil
	end

	local decodedSuccess, decoded = pcall(function(): unknown
		return HttpService:JSONDecode(value)
	end)
	if not decodedSuccess or typeof(decoded) ~= "table" then
		return nil
	end

	local settings = decoded :: { [string]: unknown }
	if settings.collectAnonymousUsageData == false then
		return Telemetry.ConsentState.Denied
	end

	return nil
end

local function createTelemetry(mode: AppMode, plugin: Pluginlike): TelemetryClient
	local isEmbedded = mode == AppMode.EmbeddedClient
	local buildInfo = getBuildInfo()

	return Telemetry.create({
		context = {
			buildChannel = buildInfo.channel,
			buildHash = buildInfo.hash,
			buildVersion = buildInfo.version,
		},
		disabled = isEmbedded,
		legacyConsent = if isEmbedded then nil else getLegacyConsent(plugin),
		storage = if isEmbedded
			then nil
			else {
				read = function()
					return plugin:GetSetting(STORAGE_KEY)
				end,
				write = function(value: string)
					plugin:SetSetting(STORAGE_KEY, value)
				end,
			},
		transport = function(envelope: TelemetryEnvelope)
			logger:Info(`firing event {envelope.eventName}`)
			requestAsync(`{_G.BASE_URL}/telemetry`, {
				method = "POST",
				body = envelope,
			})
		end,
	})
end

return createTelemetry
