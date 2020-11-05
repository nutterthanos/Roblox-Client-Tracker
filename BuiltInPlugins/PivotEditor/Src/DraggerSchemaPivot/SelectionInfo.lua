local Plugin = script.Parent.Parent.Parent
local PivotImplementation = require(Plugin.Packages.DraggerFramework.Utility.PivotImplementation)

local function computeInfo(draggerContext, selectedObjects)
	assert(#selectedObjects <= 1, "DraggerSchemaPivot should never be invoked with more than one object")
	local primaryObject = selectedObjects[1]

	if primaryObject and (primaryObject:IsA("Model") or primaryObject:IsA("BasePart")) then
		return {
			_primaryObject = primaryObject,
			_isEmpty = false,
			_basisCFrame = PivotImplementation.getPivot(primaryObject),
		}
	else
		return {
			_primaryObject = nil,
			_isEmpty = true,
			_basisCFrame = CFrame.new(),
		}
	end
end

local SelectionInfo = {}
SelectionInfo.__index = SelectionInfo

function SelectionInfo.new(draggerContext, selection)
	return setmetatable(computeInfo(draggerContext, selection), SelectionInfo)
end

function SelectionInfo:isEmpty()
	return self._isEmpty
end

function SelectionInfo:getBoundingBox()
	return self._basisCFrame, Vector3.new(), Vector3.new()
end

function SelectionInfo:doesContainItem(item)
	local primaryObject = self._primaryObject
	return not self._isEmpty and (item == primaryObject or item:IsDescendantOf(self._primaryObject))
end

function SelectionInfo:getPrimaryObject()
	return self._primaryObject
end

function SelectionInfo:isDynamic()
	return false
end

return SelectionInfo