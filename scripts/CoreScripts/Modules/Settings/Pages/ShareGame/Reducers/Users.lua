local Modules = game:GetService("CoreGui").RobloxGui.Modules

local ShareGame = Modules.Settings.Pages.ShareGame
local Immutable = require(ShareGame.Immutable)
local AddUser = require(ShareGame.Actions.AddUser)
local SetUserIsFriend = require(ShareGame.Actions.SetUserIsFriend)
local SetUserPresence = require(ShareGame.Actions.SetUserPresence)
local SetUserThumbnail = require(ShareGame.Actions.SetUserThumbnail)

return function(state, action)
	state = state or {}

	if action.type == AddUser.name then
		local user = action.user
		state = Immutable.Set(state, user.id, user)
	elseif action.type == SetUserIsFriend.name then
		local user = state[action.userId]
		if user then
			local newUser = Immutable.Set(user, "isFriend", action.isFriend)
			state = Immutable.Set(state, user.id, newUser)
		else
			warn("Setting isFriend on user", action.userId, "who doesn't exist yet")
		end
	elseif action.type == SetUserPresence.name then
		local user = state[action.userId]
		if user then
			local newUser = Immutable.JoinDictionaries(user, {
				presence = action.presence,
				lastLocation = action.lastLocation,
			})
			state = Immutable.Set(state, user.id, newUser)
		else
			warn("Setting presence on user", action.userId, "who doesn't exist yet")
		end
	elseif action.type == SetUserThumbnail.name then
		local user = state[action.userId]
		if user then
			state = Immutable.JoinDictionaries(state, {
				[action.userId] = Immutable.JoinDictionaries(user, {
					thumbnails = Immutable.JoinDictionaries(user.thumbnails, {
						[action.thumbnailType] = Immutable.JoinDictionaries(user.thumbnails[action.thumbnailType] or {}, {
							[action.thumbnailSize] = action.image,
						}),
					}),
				}),
			})
		end
	end

	return state
end