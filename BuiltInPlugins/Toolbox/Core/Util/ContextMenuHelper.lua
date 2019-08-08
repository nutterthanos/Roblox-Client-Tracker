local Plugin = script.Parent.Parent.Parent

local Util = Plugin.Core.Util
local Urls = require(Util.Urls)
local DebugFlags = require(Util.DebugFlags)

local AssetConfigConstants = require(Util.AssetConfigConstants)
local EnumConvert = require(Util.EnumConvert)

local FFlagEnableCopyToClipboard = settings():GetFFlag("EnableCopyToClipboard")
local FFlagStudioEnableLuaAssetConfigurationPage = settings():GetFFlag("StudioEnableLuaAssetConfigurationPage")

local StudioService = game:GetService("StudioService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

local ContextMenuHelper = {}

local function getImageIdFromDecalId(decalId)
	local tbl = nil
	local success, errorMessage = pcall(function()
		local url = Urls.constructAssetIdString(decalId)
		if DebugFlags.shouldDebugUrls() then
			print(("Inserting decal %s"):format(url))
		end
		tbl = game:GetObjects(url)
	end)

	if success and tbl and tbl[1] then
		local decal = tbl[1]
		return decal.Texture:match("%d+")
	else
		return 0
	end
end

-- typeof(assetTypeId) == number
function ContextMenuHelper.tryCreateContextMenu(plugin, assetId, assetTypeId, showEditOption, localizedContent, editAssetFunc)
	local menu = plugin:CreatePluginMenu("ToolboxAssetMenu")

	local localize = localizedContent

	-- only add this action if we have access to copying to clipboard
	if FFlagEnableCopyToClipboard then
		local trueAssetId = assetId
		if assetTypeId == Enum.AssetType.Decal.Value then
			trueAssetId = getImageIdFromDecalId(assetId)
		end

		menu:AddNewAction("CopyIdToClipboard", localize.RightClickMenu.CopyAssetID).Triggered:connect(function()
			StudioService:CopyToClipboard(trueAssetId)
		end)

		menu:AddNewAction("CopyURIToClipboard", localize.RightClickMenu.CopyAssetURI).Triggered:connect(function()
			StudioService:CopyToClipboard("rbxassetid://"..trueAssetId)
		end)
	end

	-- add an action to view an asset in browser
	menu:AddNewAction("OpenInBrowser", localize.RightClickMenu.ViewInBrowser).Triggered:connect(function()
		local baseUrl = ContentProvider.BaseUrl
		local targetUrl = string.format("%s/library/%s/asset", baseUrl, HttpService:urlEncode(assetId))
		GuiService:OpenBrowserWindow(targetUrl)
	end)

	if FFlagStudioEnableLuaAssetConfigurationPage and showEditOption and editAssetFunc then
		menu:AddNewAction("EditAsset", localize.RightClickMenu.EditAsset).Triggered:connect(function()
			editAssetFunc(assetId, AssetConfigConstants.FLOW_TYPE.EDIT_FLOW, nil, EnumConvert.convertAssetTypeValueToEnum(assetTypeId))
		end)
	end

	menu:ShowAsync()
	menu:Destroy()

	return menu
end

return ContextMenuHelper