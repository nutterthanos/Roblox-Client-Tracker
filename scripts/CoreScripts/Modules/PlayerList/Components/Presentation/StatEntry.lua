local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")

local Roact = require(CorePackages.Roact)

local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local GameTranslator = require(RobloxGui.Modules.GameTranslator)

local Components = script.Parent.Parent
local Connection = Components.Connection
local LayoutValues = require(Connection.LayoutValues)
local WithLayoutValues = LayoutValues.WithLayoutValues

local PlayerList = Components.Parent
local FormatStatString = require(PlayerList.FormatStatString)

local StatEntry = Roact.PureComponent:extend("StatEntry")

function StatEntry:render()
	return WithLayoutValues(function(layoutValues)
		local backgroundTransparency = layoutValues.BackgroundTransparency
		local backgroundColor3 = layoutValues.BackgroundColor
		local font = layoutValues.StatFont
		local statName = GameTranslator:TranslateGameText(CoreGui, self.props.statName)
		if self.props.isTitleEntry then
			backgroundTransparency = layoutValues.TitleBackgroundTransparency
			backgroundColor3 = layoutValues.TitleBackgroundColor
			font = layoutValues.TitleStatFont
		elseif self.props.teamColor ~= nil then
			backgroundColor3 = self.props.teamColor
			font = layoutValues.TeamStatFont
		end

		local statChildren = {}

		if layoutValues.IsTenFoot then
			statChildren["Shadow"] = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = layoutValues.ShadowImage,
				Position = UDim2.new(0, -layoutValues.ShadowSize, 0, 0),
				Size = UDim2.new(1, layoutValues.ShadowSize * 2, 1, layoutValues.ShadowSize),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = layoutValues.ShadowSliceRect,
			})
		end

		statChildren["StatText"] = Roact.createElement("TextLabel", {
			Size = self.props.isTitleEntry and UDim2.new(1, 0, 0.5, 0) or UDim2.new(1, 0, 1, 0),
			Position = self.props.isTitleEntry and UDim2.new(0, 0, 0.5, 0) or UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Font = font,
			TextSize = layoutValues.StatTextSize,
			TextColor3 = layoutValues.TextColor,
			TextStrokeColor3 = layoutValues.TextStrokeColor,
			TextStrokeTransparency = layoutValues.TextStrokeTransparency,
			Text = FormatStatString(self.props.statValue),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Active = true,
		})

		if self.props.isTitleEntry then
			statChildren["StatName"] = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0.5, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				Font = layoutValues.StatNameFont,
				TextSize = layoutValues.StatTextSize,
				TextColor3 = layoutValues.TextColor,
				TextStrokeColor3 = layoutValues.TextStrokeColor,
				TextStrokeTransparency = layoutValues.TextStrokeTransparency,
				Text = statName,
				Active = true,
				ClipsDescendants = true,
			})
		end

		return Roact.createElement("Frame", {
			LayoutOrder = self.props.layoutOrder,
			Size = UDim2.new(0, layoutValues.StatEntrySizeX, 1, 0),
			BackgroundTransparency = backgroundTransparency,
			BackgroundColor3 = backgroundColor3,
			BorderSizePixel = 0,
			AutoLocalize = false,
		}, statChildren)
	end)
end

return StatEntry