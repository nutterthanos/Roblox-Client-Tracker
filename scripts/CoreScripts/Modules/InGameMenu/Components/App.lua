--[[
    The topbar button that opens the in-game menu.
]]

local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact

local ViewportOverlay = require(script.Parent.ViewportOverlay)
local SideNavigation = require(script.Parent.SideNavigation)
local MainPage = require(script.Parent.MainPage)
local LeaveGameDialog = require(script.Parent.LeaveGameDialog)
local PageContainerSinglePane = require(script.Parent.PageContainerSinglePane)
local PageContainer = require(script.Parent.PageContainer)
local RespawnDialog = require(script.Parent.RespawnDialog)
local ReportDialog = require(script.Parent.ReportPage.ReportDialog)
local ReportSentDialog = require(script.Parent.ReportPage.ReportSentDialog)
local ControlLayoutSetter = require(script.Parent.ControlsPage.ControlLayoutSetter)
local Connection = require(script.Parent.Connection)

local getFFlagInGameMenuSinglePaneDesign = require(script.Parent.Parent.Flags.GetFFlagInGameMenuSinglePaneDesign)
local fflagInGameMenuSinglePaneDesign = getFFlagInGameMenuSinglePaneDesign()

local function App(props)
	return Roact.createFragment({
		Overlay = Roact.createElement(ViewportOverlay),
		SideNavigation = Roact.createElement(SideNavigation),
		MainPage = not fflagInGameMenuSinglePaneDesign and Roact.createElement(MainPage),
		LeaveGameDialog = Roact.createElement(LeaveGameDialog),
		PageContainer = fflagInGameMenuSinglePaneDesign and Roact.createElement(PageContainerSinglePane)
			or Roact.createElement(PageContainer),
		RespawnDialog = Roact.createElement(RespawnDialog),
		ReportDialog = Roact.createElement(ReportDialog),
		ReportSentDialog = Roact.createElement(ReportSentDialog),
		ControlLayoutSetter = Roact.createElement(ControlLayoutSetter),
		Connection = Roact.createElement(Connection),
	})
end

return App
