--[[

]]

local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

local Constants = require(Plugin.Src.Util.Constants)

local SubtractTool = Rodux.createReducer({
	brushShape = "Sphere",
	baseSize = 6,
	height = 6,
	pivot = Constants.PivotType.Center,
	snapToGrid = false,
	ignoreWater = true,
},
{
	ChooseBrushShape = function(state, action)
		local brushShape = action.brushShape

		return Cryo.Dictionary.join(state, {
			brushShape = brushShape,
		})
	end,
	ChangeBaseSize = function(state, action)
		local baseSize = action.baseSize

		return Cryo.Dictionary.join(state, {
			baseSize = baseSize,
		})
	end,
	ChangeHeight = function(state, action)
		local height = action.height

		return Cryo.Dictionary.join(state, {
			height = height,
		})
	end,
	ChangePivot = function(state, action)
		local pivot = action.pivot

		return Cryo.Dictionary.join(state, {
			pivot = pivot,
		})
	end,
	SetSnapToGrid = function(state, action)
		local snapToGrid = action.snapToGrid

		return Cryo.Dictionary.join(state, {
			snapToGrid = snapToGrid,
		})
	end,
	SetIgnoreWater = function(state, action)
		local ignoreWater = action.ignoreWater

		return Cryo.Dictionary.join(state, {
			ignoreWater = ignoreWater,
		})
	end,
})

return SubtractTool