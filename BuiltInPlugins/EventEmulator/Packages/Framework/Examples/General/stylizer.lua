local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Plugin = ContextServices.Plugin
local Application = require(script.Application)

local Dialog = require(Framework.StudioUI).Dialog

local Cryo = require(Framework.Util.Cryo)

local FrameworkStyle = require(Framework.Style)
local Colors = FrameworkStyle.Colors
local ui = FrameworkStyle.ComponentSymbols
local StyleKey = FrameworkStyle.StyleKey

local StudioTheme = require(Framework.Style.Themes.StudioTheme)

Colors = Cryo.Dictionary.join(Colors, {
	Yellow = Color3.new(230, 230, 0),
	Red = Color3.fromRGB(255, 0, 0),
	Green = Color3.new(0, 255, 0),
})


return function(plugin)
	local pluginItem = Plugin.new(plugin)

	local styleRoot = StudioTheme.new()
	styleRoot:extend({
		TextColor3 = StyleKey.MainText,

		[ui.Button] = {
			BackgroundColor = StyleKey.DialogMainButton,
			TextColor3 = StyleKey.Button,
		},

		[ui.Box] = {
			BackgroundColor = StyleKey.Mid,
		},

		[ui.Dialog] = {
			BackgroundColor = StyleKey.MainBackground,

			["&Sub"] = {
				BackgroundColor = Colors.lighter(Colors.Blue, 0.5),
				TextColor3 = Colors.Black;
			},
		},

		Important = {
			BackgroundColor = Colors.lighter(Colors.Red, 0.5),
			TextColor3 = Colors.Red;
		},
	})

	local DemoApp = Roact.Component:extend("DemoApp")

	function DemoApp:init()
		self.state = {
			enabled = true,
		}

		self.close = function()
			self:setState({
				enabled = false,
			})
		end
	end

	function DemoApp:render()
		local enabled = self.state.enabled
		if not enabled then
			return
		end
		return ContextServices.provide({pluginItem, styleRoot}, {
			Main = Roact.createElement(Dialog, {
				Enabled = enabled,
				Title = "Stylizer (Theme) Example",
				Size = Vector2.new(400, 600),
				Resizable = false,
				OnClose = self.close,
			}, {
				App = Roact.createElement(Application)
			})
		})
	end

	local element = Roact.createElement(DemoApp)
	local handle = Roact.mount(element)

	local function stop()
		Roact.unmount(handle)
	end

	return stop
end
