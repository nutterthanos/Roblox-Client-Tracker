local Plugin = script.Parent.Parent.Parent
local StudioService = game:GetService("StudioService")
local UpdatePlugin = require(Plugin.Src.Thunks.UpdatePlugin)

return function(analytics)
	return function(store)
		local plugins = store:getState().Management.plugins
		for _, plugin in pairs(plugins) do
			if not StudioService:IsPluginUpToDate(plugin.assetId, plugin.latestVersion) then
				store:dispatch(UpdatePlugin(plugin, analytics))
			end
		end
	end
end