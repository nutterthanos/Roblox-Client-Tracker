--[[
	Plugin Main Switch section

	Props:
		int LayoutOrder
			layout order of UIListLayout in Mainview

		boolean mainSwitchEnabled
			if plugin is enabled
		function onPlayerEmulationEnabledChanged
			on toggle plugin enabled
]]
local FFlagPlayerEmulatorSerializeIntoDM2 = game:GetFastFlag("PlayerEmulatorSerializeIntoDM2")

local PlayerEmulatorService = game:GetService("PlayerEmulatorService")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local UILibrary = require(Plugin.Packages.UILibrary)
local ToggleButton = UILibrary.Component.ToggleButton

local Constants = require(Plugin.Src.Util.Constants)
local OnPlayerEmulationEnabledChanged = require(Plugin.Src.Actions.OnPlayerEmulationEnabledChanged)

local THEME_REFACTOR = Framework.Util.RefactorFlags.THEME_REFACTOR

local function GetMainSwitchEnabled()
	return PlayerEmulatorService.PlayerEmulationEnabled
end

local function SetMainSwitchEnabled(isEnabled)
	PlayerEmulatorService.PlayerEmulationEnabled = isEnabled
end

local MainSwitchSection = Roact.PureComponent:extend("MainSwitchSection")

function MainSwitchSection:initEnabledStatus()
	local plugin = self.props.Plugin:get()
	local cachedSetting = plugin:GetSetting(Constants.MAIN_SWITCH_KEY)
	if cachedSetting == true then
		SetMainSwitchEnabled(true)
	end
end

function MainSwitchSection:updatePlayerEmulationEnabled(enabled)
	local plugin = self.props.Plugin:get()
	plugin:SetSetting(Constants.MAIN_SWITCH_KEY, enabled)

	local onPlayerEmulationEnabledChanged = self.props.onPlayerEmulationEnabledChanged
	onPlayerEmulationEnabledChanged(enabled)
end

function MainSwitchSection:init()
	self.signalTokens = {}
end

function MainSwitchSection:didMount()
	local enabledChangedSignal
	if FFlagPlayerEmulatorSerializeIntoDM2 then
		enabledChangedSignal = PlayerEmulatorService:GetPropertyChangedSignal(
			"PlayerEmulationEnabled"):Connect(function()
				self:updatePlayerEmulationEnabled(GetMainSwitchEnabled())
			end)
	else
		enabledChangedSignal = PlayerEmulatorService:GetPropertyChangedSignal(
			"PlayerEmulationEnabled_deprecated"):Connect(function()
				self:updatePlayerEmulationEnabled(GetMainSwitchEnabled())
			end)
	end
	table.insert(self.signalTokens, enabledChangedSignal)

	self:initEnabledStatus()
end

function MainSwitchSection:willUnmount()
	for _, signal in pairs(self.signalTokens) do
		signal:Disconnect()
	end
	self.signalTokens = nil
end

function MainSwitchSection:render()
	local props = self.props
	local theme
	if THEME_REFACTOR then
	    theme = props.Stylizer
	else
	    theme = props.Theme:get("Plugin")
	end
	local localization = props.Localization
	local layoutOrder = props.LayoutOrder
	local isOn = props.mainSwitchEnabled

	return Roact.createElement("Frame", {
		Size = theme.TOGGLE_ITEM_FRAME_SIZE,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
	}, {
		Label = Roact.createElement("TextLabel", {
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextColor3 = theme.TextColor,
			Size = theme.TOGGLE_ITEM_LABEL_SIZE,
			Text = localization:getText("MainSwitchSection", "LabelText"),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}),

		Toggle = Roact.createElement(ToggleButton, {
			Size = UDim2.new(0, theme.TOGGLE_BUTTON_WIDTH, 0, theme.TOGGLE_BUTTON_HEIGHT),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, theme.TOGGLE_BUTTON_OFFSET, 0.5, -theme.TOGGLE_BUTTON_HEIGHT/2),
			Enabled = true,
			IsOn = isOn,
			onToggle = SetMainSwitchEnabled,
			LayoutOrder = 2,
		})
	})
end

ContextServices.mapToProps(MainSwitchSection, {
	Plugin = ContextServices.Plugin,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
	Localization = ContextServices.Localization,
})

local function mapStateToProps(state, _)
	return {
		mainSwitchEnabled = state.MainSwitch.mainSwitchEnabled
	}
end

local function mapDispatchToProps(dispatch)
	return {
		onPlayerEmulationEnabledChanged = function(enabled)
			dispatch(OnPlayerEmulationEnabledChanged(enabled))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(MainSwitchSection)
