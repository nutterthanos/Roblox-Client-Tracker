local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Cryo = require(Libs.Cryo)

local createSignal = require(Plugin.Core.Util.createSignal)
local DebugFlags = require(Plugin.Core.Util.DebugFlags)
local wrapStrictTable = require(Plugin.Core.Util.wrapStrictTable)

local FFlagStudioLuaWidgetToolboxV2 = settings():GetFFlag("StudioLuaWidgetToolboxV2")
local FFlagEnableLocalizationForToolbox = settings():GetFFlag("EnableLocalizationForToolbox")

local Localization = {}
Localization.__index = Localization

--[[
	options:
		getLocaleId : function void -> LocaleId
		getTranslator : function LocaleId -> Translator
		localeIdChanged : RbxScriptSignal
]]
function Localization.new(options)
	local self = {
		_externalLocaleIdGetter = options.getLocaleId or nil,
		_externalTranslatorGetter = options.getTranslator or nil,
		_externalLocaleIdChangedSignal = options.localeIdChanged,

		_externalLocaleIdChangedConnection = nil,

		_content = {},

		_signal = createSignal(),
	}

	self._content = wrapStrictTable(self._content, "content")

	setmetatable(self, Localization)

	if self._externalLocaleIdChangedSignal then
		self._externalLocaleIdChangedConnection = self._externalLocaleIdChangedSignal:Connect(function()
			self:_recalculateContent()
		end)
	end
	self:_recalculateContent()

	return self
end

function Localization.createDummyLocalization()
	return Localization.new({
		getLocaleId = function()
			return "en-us"
		end,
		getTranslator = function(localeId)
			return {
				FormatByKey = function(self, key, args)
					local ret = "TEST_" .. key
					if args and type(args) == "table" then
						for k, v in pairs(args) do
							ret = ret .. "_" .. k .. "=" .. v
						end
					end
					return ret
				end,
			}
		end,
		localeIdChanged = nil,
	})
end

-- Creates a Localization that just echos back whatever's in the debug value
-- Useful for testing UI reacts to strings of all lengths
function Localization.createTestCustomLocaleLocalization(value)
	return Localization.new({
		getLocaleId = function()
			return value.Value
		end,
		getTranslator = function(localeId)
			return {
				FormatByKey = function()
					return localeId
				end
			}
		end,
		localeIdChanged = value:GetPropertyChangedSignal("Value")
	})
end

-- Creates a Localization that uses the LocaleId in a debug flag but reads from the real table
function Localization.createTestRealLocaleLocalization(localizationTable, value)
	return Localization.new({
		getLocaleId = function()
			return value.Value
		end,
		getTranslator = function(localeId)
			return localizationTable:GetTranslator(localeId)
		end,
		localeIdChanged = value:GetPropertyChangedSignal("Value")
	})
end

function Localization:subscribe(...)
	return self._signal:subscribe(...)
end

function Localization:getLocalizedContent()
	return self.content
end

function Localization:getLocalizedCreatorIntroText(userName)
	return self:_safeLocalize("AssetCreatorIntroText", {
		name = userName
	})
end

function Localization:getLocalizedVoteText(voteCounts)
	local localizedContent = self.content
	local voteText = voteCounts ~= 1 and localizedContent.Voting.VotesText
		or localizedContent.Voting.VoteText

	-- TODO: CLIDEVSRVS-1769 : Improve localization for toolbox's vote counts and vote text
	return string.format("%d %s", voteCounts, voteText)
end

function Localization:getLocalizedCategores(categories)
	return self:_localizeTable(categories, "Category", "name", "name")
end

function Localization:getLocalizedSorts(sorts)
	return self:_localizeTable(sorts, "Sort", "name", "sort")
end

function Localization:getLocalizedSuggestions(suggestions)
	if FFlagStudioLuaWidgetToolboxV2 then
		return self:_localizeTable(suggestions, "Suggestions", "name", "search")
	else
		return suggestions
	end
end

function Localization:getLocalizedFooter(footerBackgroundNames)
	return self:_localizeTable(footerBackgroundNames, "Footer", "name", "color")
end

function Localization:destroy()
	if self._externalLocaleIdChangedConnection then
		self._externalLocaleIdChangedConnection:Disconnect()
	end
end

-- Private impl below

function Localization:_getDefaultLocaleId()
	return "en-us"
end

function Localization:_getLocaleId()
	if FFlagEnableLocalizationForToolbox then
		if self._externalLocaleIdGetter then
			return self._externalLocaleIdGetter()
		end
	end
	return self:_getDefaultLocaleId()
end

function Localization:_getTranslator(localeId)
	localeId = localeId or self:_getLocaleId() or self:_getDefaultLocaleId()
	if self._externalTranslatorGetter then
		return self._externalTranslatorGetter(localeId)
	end
	return nil
end

function Localization:_getDefaultTranslator()
	return self:_getTranslator(self:_getDefaultLocaleId())
end

function Localization:_update(changedContent)
	self._content = Cryo.Dictionary.join(self._content, changedContent)
	self.content = wrapStrictTable(self._content, "content")
	self._signal:fire(self.content)
end

-- Attempts to localize key with args in the current translator
-- If it fails, it attempts again in the default locale
-- If it still fails, then it just falls back to using the key
-- Else, it returns the translated content
-- If show warnings is on, it will warn when it fails to translate
function Localization:_safeLocalize(key, args)
	local translator = self:_getTranslator()

	if not translator and DebugFlags.shouldDebugWarnings() then
		warn("Toolbox Localization:_safeLocalize() translator = nil")
		return key
	end

	local success, translated = self:_safeLocalizeInner(translator, key, args)

	if not success then
		if DebugFlags.shouldDebugWarnings() then
			warn(("Toolbox error in localizing key \"%s\" to locale \"%s\": %s"):format(
				key, translator.LocaleId, translated))
		end

		local defaultTranslator = self:_getDefaultTranslator()

		if not defaultTranslator and DebugFlags.shouldDebugWarnings() then
			warn("Toolbox Localization:_safeLocalize() defaultTranslator = nil")
			return key
		end

		success, translated = self:_safeLocalizeInner(defaultTranslator, key, args)

		if not success then
			if DebugFlags.shouldDebugWarnings() then
				warn(("\tToolbox error in localizing key \"%s\" to default locale \"%s\": %s"):format(
					key, defaultTranslator.LocaleId, translated))
			end
			-- If we can't translate to real locale or default locale, fallback to returning the key
			translated = key
		else
			if DebugFlags.shouldDebugWarnings() then
				warn(("\tToolbox falling back to default locale \"%s\" for key \"%s\""):format(
					defaultTranslator.LocaleId, key))
			end
		end
	end

	return translated
end

-- Wraps self:translator:FormatByKey(key, args) in pcall
function Localization:_safeLocalizeInner(translator, key, args)
	return pcall(function()
		return translator:FormatByKey(key, args)
	end)
end

function Localization:_recalculateContent()
	self:_update({
		ToolboxToolbarName = self:_safeLocalize("ToolboxToolbarName"),

		Category = {
			FreeModels = self:_safeLocalize("CategoryModels"),
			FreeDecals = self:_safeLocalize("CategoryDecals"),
			FreeMeshes = self:_safeLocalize("CategoryMeshes"),
			FreeAudio = self:_safeLocalize("CategoryAudio"),
			FreePlugins = self:_safeLocalize("CategoryPlugins"),
			MyModels = self:_safeLocalize("CategoryMyModels"),
			MyDecals = self:_safeLocalize("CategoryMyDecals"),
			MyMeshes = self:_safeLocalize("CategoryMyMeshes"),
			MyAudio = self:_safeLocalize("CategoryMyAudio"),
			MyPlugins = self:_safeLocalize("CategoryMyPlugins"),
			MyPackages = self:_safeLocalize("CategoryMyPackages"),
			RecentModels = self:_safeLocalize("CategoryRecentModels"),
			RecentDecals = self:_safeLocalize("CategoryRecentDecals"),
			RecentMeshes = self:_safeLocalize("CategoryRecentMeshes"),
			RecentAudio = self:_safeLocalize("CategoryRecentAudio"),
			GroupModels = self:_safeLocalize("CategoryGroupModels"),
			GroupDecals = self:_safeLocalize("CategoryGroupDecals"),
			GroupMeshes = self:_safeLocalize("CategoryGroupMeshes"),
			GroupAudio = self:_safeLocalize("CategoryGroupAudio"),
			GroupPackages = self:_safeLocalize("CategoryGroupPackages")
		},

		Suggestions = {
			IntroText = self:_safeLocalize("SuggestionsIntroText"),
			NPC = self:_safeLocalize("SuggestionsNPC"),
			Vehicle = self:_safeLocalize("SuggestionsVehicle"),
			Weapon = self:_safeLocalize("SuggestionsWeapon"),
			Building = self:_safeLocalize("SuggestionsBuilding"),
			Light = self:_safeLocalize("SuggestionsLight"),
		},

		Sort = {
			ByText = self:_safeLocalize("SortByText"),
			Relevance = self:_safeLocalize("SortByRelevance"),
			MostTaken = self:_safeLocalize("SortByMostTaken"),
			Favorites = self:_safeLocalize("SortByFavorites"),
			Updated = self:_safeLocalize("SortByUpdated"),
			Ratings = self:_safeLocalize("SortByRatings"),
		},

		Voting = {
			VoteText = self:_safeLocalize("VotingVoteText"),
			VotesText = self:_safeLocalize("VotingVotesText"), -- plural
		},

		Footer = {
			BGText = self:_safeLocalize("FooterBGText"),
			White = self:_safeLocalize("FooterButtonWhiteName"),
			Black = self:_safeLocalize("FooterButtonBlackName"),
			None = self:_safeLocalize("FooterButtonNoneName"),
		},

		SearchBarDefaultText = self:_safeLocalize("SearchBarDefaultText"),

		EndorseBadgeTooltipText = self:_safeLocalize("EndorseBadgeTooltipText"),

		InfoBannerText = self:_safeLocalize("InfoBannerText")
	})
end

function Localization:_localizeTable(tbl, localizedTableName, keyToReplace, keyToUse)
	local newTbl = {}
	local localizedContent = self.content
	local content = localizedContent[localizedTableName]

	for index, item in pairs(tbl) do
		local valueToUse = item[keyToUse]
		local newText = content[valueToUse]

		newTbl[index] = Cryo.Dictionary.join(item, {
			[keyToReplace] = newText,
		})
	end

	return newTbl
end

return Localization
