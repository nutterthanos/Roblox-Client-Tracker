--[[
	Input Fields:
		Theme Name: New theme to switch towards

	Required Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		table ViewData: table of data to display child nodes
		function focusLost: A function that passes an identifier and new usr input to the parent
	Optional Props:
		
	Style Values:
]]
local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local ContextServices = require(Plugin.Packages.Framework.ContextServices)

local Components = Plugin.Src.Components
local TextInput = require(Components.TextInput)

local UI = require(Plugin.Packages.Framework.UI)
local RadioButtonList = UI.RadioButtonList

local Constants = require(Plugin.Src.Util.Constants)
local INPUT_PANE_LAYOUT = Constants.INPUT_PANE_LAYOUT

local ThemeView = Roact.PureComponent:extend("ThemeView")

local VIEW_DATA = {
	Routes = {

	},
	SelectedKey = "",
	ThemeName = "",
	FocusLost = function ()
	end,
}

function ThemeView:init()
	self.state = {
		SelectedKey = nil,
	}

	self.OnClick = function (key)
		self:setState({
			SelectedKey = key
		})
	end

	self.createRoutes = function ()
		local buttons = {}

		for text, key in pairs(VIEW_DATA.Routes) do
			table.insert(buttons, {
				Key = key,
				Text = "Use " .. text,
			})
		end

		return buttons
	end

end

function ThemeView:render()
	local state = self.state
	local selectedKey = state.SelectedKey

	local theme = self.props.Theme
	local layout = theme:get("Layout")

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = INPUT_PANE_LAYOUT.View,
		BackgroundTransparency = 1,
		ZIndex = -5,
	}, {
		Layout = Roact.createElement("UIListLayout", layout.Vertical),
		TextInput = Roact.createElement(TextInput, {
			Label = "Theme Name",
			Text = VIEW_DATA.ThemeName,
			OnChange = VIEW_DATA.FocusLost,
			LayoutOrder = 1,
		}),
		Switch = Roact.createElement(RadioButtonList, {
			Buttons = self.createRoutes(),
			OnClick = self.OnClick,
			SelectedKey = selectedKey,
			LayoutOrder = 2,
		}),
	})
end

ContextServices.mapToProps(ThemeView, {
	Theme = ContextServices.Theme,
})

return ThemeView