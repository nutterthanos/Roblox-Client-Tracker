--[[
	Mostly the same as UILibrary CheckBox component, but modified to use dev framework context
	And updated font/text size handling
]]

local Plugin = script.Parent.Parent.Parent

local Framework = require(Plugin.Packages.Framework)
local Roact = require(Plugin.Packages.Roact)

local ContextServices = Framework.ContextServices
local ContextItems = require(Plugin.Src.ContextItems)

local TextService = game:GetService("TextService")

local CheckBox = Roact.PureComponent:extend("CheckBox")

function CheckBox:init()
	self.onActivated = function()
		if self.props.Enabled then
			self.props.OnActivated()
		end
	end
end

function CheckBox:render()
	local props = self.props
	local theme = props.Theme:get()

	local title = props.Title
	local height = props.Height
	local enabled = props.Enabled
	local layoutOrder = props.LayoutOrder
	local selected = props.Selected
	local textSize = theme.checkBox.textSize
	local textFont = theme.checkBox.font
	local titlePadding = props.TitlePadding or 5

	local titleSize = TextService:GetTextSize(
		title,
		textSize,
		textFont,
		Vector2.new()
	)
	local titleWidth = titleSize.X

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder or 1,
	}, {
		Background = Roact.createElement("ImageButton", {
			Size = UDim2.new(0, height, 0, height),
			BackgroundTransparency = 1,
			ImageTransparency = enabled and 0 or 0.4,
			Image = theme.checkBox.backgroundImage,
			ImageColor3 = theme.checkBox.backgroundColor,

			[Roact.Event.Activated] = self.onActivated,
		}, {
			Selection = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Visible = enabled and selected,
				Image = theme.checkBox.selectedImage,
			}),

			TitleLabel = Roact.createElement("TextButton", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, titleWidth, 1, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(1, titlePadding, 0.5, 0),

				TextColor3 = theme.checkBox.titleColor,
				Font = textFont,
				TextSize = textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextTransparency = enabled and 0 or 0.5,
				Text = title,

				[Roact.Event.Activated] = self.onActivated,
			}),
		}),
	})
end

ContextServices.mapToProps(CheckBox, {
	Theme = ContextItems.UILibraryTheme,
})

return CheckBox
