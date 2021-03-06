--[[
	PluginPermissionInfo is a table separated by assetId.
	Example data:
	{
		[123] = {
			allowedHttpCount = 0,
			deniedHttpCount = 0,
			allowedScriptInjection = nil,
			httpPermissions = {
				PermissionInfo.new(),
				PermissionInfo.new(),
			},
			scriptInjectionPermissions = {
				PermissionInfo.new(),
			}
		},
	}
]]
local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)
local Rodux = require(Plugin.Packages.Rodux)

local PermissionInfo = require(Plugin.Src.Models.PermissionInfo)
local Constants = require(Plugin.Src.Util.Constants)

local function reverse (arr, excludeFinalEntry)
	local result = {}
	if #arr > 1 then
		for i=#arr, 1, -1 do
			if not excludeFinalEntry or (excludeFinalEntry and (i ~= #arr)) then
				result[#result+1] = arr[i]
			end
		end
	else
		result = arr
	end
	return result
end

return Rodux.createReducer({}, {
	--[[ Sets a table of permission data. Will override the entire permissions table. ]]
	SetAllPluginPermissions = function(state, action)
		local updatedPluginsList = {}

		for id, entry in pairs(action.permissions) do
			local assetId = tonumber(id)
			local httpPermissionsList = {}
			local scriptInjectionPermissionsList = {}
			local allowedHttpCount = 0
			local deniedHttpCount = 0
			local allowedScriptInjection = nil
			for permissionIndex, permission in ipairs(entry) do
				if permission.Type == Constants.PERMISSION_TYPES.HttpService then
					local permissionInfo = PermissionInfo.fromUserData(permission, permissionIndex)
					if permissionInfo.allowed then
						allowedHttpCount = allowedHttpCount + 1
					else
						deniedHttpCount = deniedHttpCount + 1
					end
					table.insert(httpPermissionsList, permissionInfo)
				elseif permission.Type == Constants.PERMISSION_TYPES.ScriptInjection then
					local permissionInfo = PermissionInfo.fromUserData(permission, permissionIndex)
					if allowedScriptInjection == nil then
						allowedScriptInjection = permissionInfo.allowed
						table.insert(scriptInjectionPermissionsList, permissionInfo)
					else
						-- Only the first script injection permission is allowed. This state should only
						-- be possible by manually tweaking the endpoint.
						assert(false, "Only one script injection permission is allowed. " ..
							"Uninstall and reinstall plugin " .. tostring(assetId) .. " to reset permissions.")
					end
				end
			end

			table.sort(httpPermissionsList, function(first, second)
				if not first.data.domain or not second.data.domain then
					return false
				end
				-- Sort by domain
				local firstReversedDomain = table.concat(reverse(string.split(first.data.domain, "."), true), ".")
				local secondReversedDomain = table.concat(reverse(string.split(second.data.domain, "."), true), ".")
				return firstReversedDomain < secondReversedDomain
			end)

			updatedPluginsList[assetId] = {
				allowedHttpCount = allowedHttpCount,
				deniedHttpCount = deniedHttpCount,
				allowedScriptInjection = allowedScriptInjection,
				httpPermissions = httpPermissionsList,
				scriptInjectionPermissions = scriptInjectionPermissionsList,
			}
		end

        return Cryo.Dictionary.join(state, updatedPluginsList)
	end,
})