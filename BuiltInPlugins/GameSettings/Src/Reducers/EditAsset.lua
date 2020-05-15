--[[
	Reducer for metadata of a game that can't be directly changed by the user (otherwise put in Settings)
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local Rodux = require(Plugin.Rodux)

return Rodux.createReducer({
	editPlaceId = 0,
}, {
    SetEditPlaceId = function(state, action)
        return Cryo.Dictionary.join(state, {
			editPlaceId = action.editPlaceId,
		})
    end,
})