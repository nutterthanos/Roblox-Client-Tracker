--[[
	This component is responsible for configging the asset's access field.

	Props:
	onDropDownSelect, function, will return current selected item if selected.
]]

local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)

local Util = Plugin.Core.Util
local ContextHelper = require(Util.ContextHelper)
local ContextGetter =require (Util.ContextGetter)
local Constants = require(Util.Constants)
local AssetConfigConstants = require(Util.AssetConfigConstants)
local getUserId = require(Util.getUserId)

local DropdownMenu = require(Plugin.Core.Components.DropdownMenu)

local Requests = Plugin.Core.Networking.Requests
local GetAssetConfigGroupDataRequest = require(Requests.GetAssetConfigGroupDataRequest)
local GetMyGroupsRequest = require(Requests.GetMyGroupsRequest)

local ConfigTypes = require(Plugin.Core.Types.ConfigTypes)

local withTheme = ContextHelper.withTheme
local withLocalization = ContextHelper.withLocalization

local getNetwork = ContextGetter.getNetwork

local ConfigAccess = Roact.PureComponent:extend("ConfigAccess")

local TITLE_HEIGHT = 40

local DROP_DOWN_WIDTH = 220
local DORP_DOWN_HEIGHT = 38

function ConfigAccess:init(props)
	self.allowOwnerEdit = props.screenFlowType == AssetConfigConstants.FLOW_TYPE.UPLOAD_FLOW
end

function ConfigAccess:didMount()
	local userId = getUserId()
	-- Initial request
	self.props.getMyGroups(getNetwork(self), userId)
end

function ConfigAccess:render()
	return withTheme(function(theme)
		return withLocalization(function(_, localizedContent)
			local props = self.props
			local state = self.state

			local Title = props.Title
			local LayoutOrder = props.LayoutOrder
			local TotalHeight = props.TotalHeight
			local owner = props.owner or {}

			-- We have a bug, on here: https://developer.roblox.com/api-reference/enum/CreatorType
			-- User is 0, howerver in source code, User is 1.
			-- TODO: Notice UX to change the website.
			local ownerIndex = (owner.typeId or 1)

			self.dropdownContent = AssetConfigConstants.getOwnerDropDownContent(props.groupsArray, localizedContent)

			local onDropDownSelect = props.onDropDownSelect

			local publishAssetTheme = theme.publishAsset

			local ownerName = ""
			if (not self.allowOwnerEdit) and owner.typeId then
				if owner.typeId == ConfigTypes.OWNER_TYPES.User then
					ownerName = localizedContent.AssetConfig.PublishAsset.Me
				else -- If not owned by Me, then it's owned by a group.
					-- Load the groupName
					if props.assetGroupData then
						ownerName = props.assetGroupData.name
					else
						self.props.getGroupsData(getNetwork(self), owner.typeId)
					end
				end
			end

			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, TotalHeight),

				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(227, 227, 227),
				BorderSizePixel = 0,

				LayoutOrder = LayoutOrder
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 0),
				}),

				Title = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, AssetConfigConstants.TITLE_GUTTER_WIDTH, 1, 0),

					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = Title,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextSize = Constants.FONT_SIZE_TITLE,
					TextColor3 = publishAssetTheme.titleTextColor,
					Font = Constants.FONT,


					LayoutOrder = 1,
				}),

				DropDown = self.allowOwnerEdit and Roact.createElement(DropdownMenu, {
					Size = UDim2.new(0, DROP_DOWN_WIDTH, 0, DORP_DOWN_HEIGHT),
					visibleDropDownCount = 5,
					selectedDropDownIndex = ownerIndex,

					fontSize = Constants.FONT_SIZE_MEDIUM,
					items = self.dropdownContent,
					onItemClicked = onDropDownSelect,

					LayoutOrder = 2,
				}),

				OwnerType = (not self.allowOwnerEdit) and Roact.createElement("TextLabel", {
					Size = UDim2.new(1, -AssetConfigConstants.TITLE_GUTTER_WIDTH, 0, 0),

					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = ownerName,
					Font = Constants.FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextSize = Constants.FONT_SIZE_SMALL,
					TextColor3 = publishAssetTheme.titleTextColor,

					LayoutOrder = 2,
				}),
			})
		end)
	end)
end

local function mapStateToProps(state, props)
	state = state or {}

	return {
		screenFlowType = state.screenFlowType,
		groupsArray = state.groupsArray or {}
	}
end

local function mapDispatchToProps(dispatch)
	return {
		getGroupsData = function(networkInterface, groupId)
			dispatch(GetAssetConfigGroupDataRequest(networkInterface, groupId))
		end,

		getMyGroups = function(networkInterface, userId)
			dispatch(GetMyGroupsRequest(networkInterface, userId))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(ConfigAccess)