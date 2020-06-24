local Plugin = script.Parent.Parent.Parent

local Constants = require(Plugin.Src.Resources.Constants)

local Action = require(script.Parent.Action)

local FFlagStudioLuaPublishFlowLocalizeUntitledGameText = game:GetFastFlag("StudioLuaPublishFlowLocalizeUntitledGameText")
local FFlagStudioPublishFlowDefaultScreen = game:GetFastFlag("StudioPublishFlowDefaultScreen")

return Action(script.Name, function(localizedDefaultname)
	return {
		placeInfo = { places = {}, parentGame = {}, },
        gameInfo = { games = {}, },
        groupInfo = { groups = {} },
        current = {},
        changed = {
            name = FFlagStudioLuaPublishFlowLocalizeUntitledGameText and localizedDefaultname or "Untitled Game",
            description = "",
            genre = Constants.GENRE_IDS[1],
            playableDevices = {Computer = true, Phone = true, Tablet = true,},
        },
        errors = {},
        publishInfo = { id = 0, name = "", parentGameName = "", parentGameId = 0, settings = {}, },
        isPublishing = false,
        screen = FFlagStudioPublishFlowDefaultScreen and game.GameId == 0 and Constants.SCREENS.CHOOSE_GAME
            or Constants.SCREENS.CREATE_NEW_GAME,
	}
end)
