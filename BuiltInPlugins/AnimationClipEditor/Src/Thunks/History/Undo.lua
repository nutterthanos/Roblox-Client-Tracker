--[[
	Pops the nearest waypoint off the Past stack so
	that the user can return to a previous AnimationData state.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)

local Cryo = require(Plugin.Packages.Cryo)
local SetPast = require(Plugin.Src.Actions.SetPast)
local SetFuture = require(Plugin.Src.Actions.SetFuture)
local SetSelectedKeyframes = require(Plugin.Src.Actions.SetSelectedKeyframes)
local UpdateAnimationData = require(Plugin.Src.Thunks.UpdateAnimationData)
local SortAndSetTracks = require(Plugin.Src.Thunks.SortAndSetTracks)

return function(signals)
	return function(store)
		local state = store:getState()
		local animationData = state.AnimationData
		local tracks = state.Status.Tracks
		local history = state.History
		local past = history.Past
		local future = history.Future

		if #past > 0 then
			future = Cryo.List.join({
				{
					AnimationData = Cryo.Dictionary.join(animationData),
					Tracks = Cryo.List.join(tracks),
				},
			}, future)
			future = Cryo.List.filter(future, function(value, index)
				return (index <= history.MaxWaypointSize)
			end)
			store:dispatch(SetFuture(future))

			local newState = past[1]
			store:dispatch(UpdateAnimationData(newState.AnimationData))
			store:dispatch(SortAndSetTracks(newState.Tracks))
			store:dispatch(SetSelectedKeyframes({}))

			store:dispatch(SetPast(Cryo.List.removeIndex(past, 1)))
			if signals then 
				local selectionSignal = signals:get(Constants.SIGNAL_KEYS.SelectionChanged)
				selectionSignal:Fire()
			end
		end
	end
end