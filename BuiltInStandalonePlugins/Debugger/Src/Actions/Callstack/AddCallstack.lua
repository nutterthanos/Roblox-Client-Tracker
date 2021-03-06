local Plugin = script.Parent.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Util = Framework.Util
local Action = Util.Action
local CallstackRow = require(Plugin.Src.Models.CallstackRow)

local Types = require(Plugin.Src.Types)

export type Props = {
	threadId : number,
	frameList : Array<CallstackRow.CallstackRow>,
}
return Action(script.Name, function(threadId : number, frameList : Types.Array<CallstackRow.CallstackRow>) : Props
	return {
		threadId = threadId,
		frameList = frameList,
	}
end)
