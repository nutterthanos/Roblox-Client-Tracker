--[[
	Reducer that combines the Settings and Status reducers.
]]

local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Rodux)

local EditAsset = require(Plugin.Src.Reducers.EditAsset)
local GameMetadata = require(Plugin.Src.Reducers.GameMetadata)
local PageLoadState = require(Plugin.Src.Reducers.PageLoadState)
local PageSaveState = require(Plugin.Src.Reducers.PageSaveState)
local Settings = require(Plugin.Src.Reducers.Settings)
local Status = require(Plugin.Src.Reducers.Status)
local Thumbnails
if not game:GetFastFlag("GameSettingsNetworkRefactor") then
	Thumbnails = require(Plugin.Src.Reducers.DEPRECATED_Thumbnails)
end
local CollaboratorSearch = require(Plugin.Src.Reducers.CollaboratorSearch)
local DevSubModeration = require(Plugin.Src.Reducers.DevSubModeration)
local AutoTranslationMetaData = require(Plugin.Src.Reducers.AutoTranslationMetaData)

local MorpherEditorRoot = require(Plugin.Src.Reducers.MorpherEditorRoot)

local FFlagStudioLocalizationInGameSettingsEnabled = game:GetFastFlag("StudioLocalizationInGameSettingsEnabled")

return Rodux.combineReducers({
	Settings = Settings,
	Status = Status,
	MorpherEditorRoot = MorpherEditorRoot,
	Thumbnails = Thumbnails,
	CollaboratorSearch = CollaboratorSearch,
	DevSubModeration = settings():GetFFlag("DeveloperSubscriptionsEnabled") and DevSubModeration or nil,
	AutoTranslationMetaData = FFlagStudioLocalizationInGameSettingsEnabled and AutoTranslationMetaData or nil,
	PageLoadState = game:GetFastFlag("GameSettingsNetworkRefactor") and PageLoadState or nil,
	PageSaveState = game:GetFastFlag("GameSettingsNetworkRefactor") and PageSaveState or nil,
	Metadata = game:GetFastFlag("GameSettingsNetworkRefactor") and GameMetadata or nil,
	EditAsset = (game:GetFastFlag("GameSettingsPlaceSettings") or game:GetFastFlag("StudioAddMonetizationToGameSettings")) and EditAsset or nil,
})