--[[
	Scale tool implementation. Responsible for handle state and handle views.
]]

-- Libraries
local DraggerFramework = script.Parent.Parent
local Plugin = DraggerFramework.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

-- Dragger Framework
local Colors = require(DraggerFramework.Utility.Colors)
local Math = require(DraggerFramework.Utility.Math)
local StandaloneSelectionBox = require(DraggerFramework.Components.StandaloneSelectionBox)
local ScaleHandleView = require(DraggerFramework.Components.ScaleHandleView)
local DraggedPivot = require(DraggerFramework.Components.DraggedPivot)

local getEngineFeatureModelPivotVisual = require(DraggerFramework.Flags.getEngineFeatureModelPivotVisual)
local getFFlagFoldersOverFragments = require(DraggerFramework.Flags.getFFlagFoldersOverFragments)
local getFFlagSummonPivot = require(DraggerFramework.Flags.getFFlagSummonPivot)

local ExtrudeHandle = {}
ExtrudeHandle.__index = ExtrudeHandle

local NormalId = {
	X_AXIS = 1,
	Y_AXIS = 2,
	Z_AXIS = 3,
}

local ScaleHandleDefinitions = {
	MinusX = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1)),
		Color = Colors.X_AXIS,
		NormalId = NormalId.X_AXIS,
	},
	PlusX = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 1, 0), Vector3.new(0, 0, -1)),
		Color = Colors.X_AXIS,
		NormalId = NormalId.X_AXIS,
	},
	MinusY = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 0, 1), Vector3.new(1, 0, 0)),
		Color = Colors.Y_AXIS,
		NormalId = NormalId.Y_AXIS,
	},
	PlusY = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 0, 1), Vector3.new(-1, 0, 0)),
		Color = Colors.Y_AXIS,
		NormalId = NormalId.Y_AXIS,
	},
	MinusZ = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0)),
		Color = Colors.Z_AXIS,
		NormalId = NormalId.Z_AXIS,
	},
	PlusZ = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(1, 0, 0), Vector3.new(0, -1, 0)),
		Color = Colors.Z_AXIS,
		NormalId = NormalId.Z_AXIS,
	},
}

local BOX_CORNERS = {
	Vector3.new(0.5, 0.5, 0.5),
	Vector3.new(0.5, 0.5, -0.5),
	Vector3.new(0.5, -0.5, 0.5),
	Vector3.new(0.5, -0.5, -0.5),
	Vector3.new(-0.5, 0.5, 0.5),
	Vector3.new(-0.5, 0.5, -0.5),
	Vector3.new(-0.5, -0.5, 0.5),
	Vector3.new(-0.5, -0.5, -0.5),
}

local function nextNormalId(normalId)
	return normalId % 3 + 1
end

function ExtrudeHandle.new(draggerContext, props, implementation)
	local self = {}
	self._handles = {}
	self._props = props or {}
	self._draggerContext = draggerContext
	self._implementation = implementation
	return setmetatable(self, ExtrudeHandle)
end

-- Summon handles to the current mouse hover location
function ExtrudeHandle:_summonHandles()
	if not self._props.Summonable then
		return false
	end

	local mouseRay = self._draggerContext:getMouseRay()
	local _, hitItem, distance = self._schema.getMouseTarget(self._draggerContext, mouseRay, {})
	if hitItem and self._selectionInfo:doesContainItem(hitItem) then
		local hitPoint = mouseRay.Origin + mouseRay.Direction.Unit * distance
		local point = self._boundingBox.CFrame:PointToObjectSpace(hitPoint)
		local halfSize = self._boundingBox.Size / 2
		self._summonBasisOffset = CFrame.new(point:Max(-halfSize):Min(halfSize))
	else
		-- Try to pick a point on the selection closest to the cursor
		local cursorOnScreen = self._draggerContext:getMouseLocation()
		local closestWorldPoint
		local closestDistanceOnScreen = math.huge
		for _, cornerOffset in ipairs(BOX_CORNERS) do
			local cornerInWorld = self._boundingBox.CFrame * CFrame.new(self._boundingBox.Size * cornerOffset)
			local cornerOnScreen, inView = self._draggerContext:worldToViewportPoint(cornerInWorld.Position)
			local distance = (cursorOnScreen - Vector2.new(cornerOnScreen.X, cornerOnScreen.Y)).Magnitude
			if inView and distance < closestDistanceOnScreen then
				closestDistanceOnScreen = distance
				closestWorldPoint = cornerInWorld
			end
		end
		if closestWorldPoint then
			self._summonBasisOffset = self._boundingBox.CFrame:ToObjectSpace(closestWorldPoint)
		end
	end
end

function ExtrudeHandle:_endSummon()
	if self._summonBasisOffset then
		self._summonBasisOffset = nil
	end
end

function ExtrudeHandle:_getBasisOffset()
	return self._summonBasisOffset or self._basisOffset
end

function ExtrudeHandle:update(draggerToolModel, selectionInfo)
	if not self._draggingHandleId then
		-- Don't clobber these fields while we're dragging because we're
		-- updating the bounding box in a smart way given how we're moving the
		-- parts.

		self._selectionInfo = selectionInfo
		self._schema = draggerToolModel:getSchema()
		self._selectionWrapper = draggerToolModel:getSelectionWrapper()

		local cframe, offset, size = self._implementation:getBoundingBox(
			self._selectionWrapper:get(), self._selectionInfo)
		if getEngineFeatureModelPivotVisual() then
			self._basisOffset = CFrame.new(-offset) -- negative since relative to bounding box
		end
		self._boundingBox = {
			Size = size,
			CFrame = cframe * CFrame.new(offset),
		}
	end
	self:_updateHandles()
end

function ExtrudeHandle:shouldBiasTowardsObjects()
	return true
end

function ExtrudeHandle:_rememberCurrentBoundsAsOriginal()
	self._originalBoundingBoxSize = self._boundingBox.Size
	self._originalBoundingBoxCFrame = self._boundingBox.CFrame
	if getFFlagSummonPivot() then
		self._originalBasisOffset = self:_getBasisOffset().Position
	else
		self._originalBasisOffset = self._basisOffset.Position
	end
	local axis = self._handles[self._draggingHandleId].Axis
	local perpendicularMovement = self._originalBasisOffset
	perpendicularMovement = perpendicularMovement - axis * perpendicularMovement:Dot(axis)
	self._perpendicularMovement = perpendicularMovement
end

-- Called when the settings we're using to drag change (when we press/release
-- the key(s) for resize from center / maintain aspect ratio)
function ExtrudeHandle:_refreshDrag()
	self._committedDeltaSize = self._lastDeltaSize
	self._committedOffset = self._lastOffset

	if getEngineFeatureModelPivotVisual() then
		self:_rememberCurrentBoundsAsOriginal()
	else
		self._originalBoundingBoxSize = self._boundingBox.Size
		self._originalBoundingBoxCFrame = self._boundingBox.CFrame
	end

	-- The edge case where you rotate your camera exactly into alignment with
	-- the axis you started the drag on and then press Ctrl will act a bit weird
	-- here, but that it's almost impossible to hit that edge case (You have to
	-- key-bind a camera alignment command).
	local hasDistance, distance =
		self:_getDistanceAlongAxis(self._draggerContext:getMouseRay())
	self._startDistance = hasDistance and distance or 0
end

function ExtrudeHandle:_getExtrudeMode()
	local keepAspectRatio = self._implementation:shouldKeepAspectRatio(
		self._selectionWrapper:get(), self._selectionInfo, self._normalId)
	local resizeFromCenter = self._implementation:shouldScaleFromCenter(
		self._selectionWrapper:get(), self._selectionInfo, self._normalId)
	return keepAspectRatio, resizeFromCenter
end

-- Returns, whether we did need to refresh the drag
function ExtrudeHandle:_refreshDragIfNeeded()
	local keepAspectRatio, resizeFromCenter = self:_getExtrudeMode()
	if keepAspectRatio ~= self._lastKeepAspectRatio or
		resizeFromCenter ~= self._lastResizeFromCenter then
		if self._handles[self._draggingHandleId] then
			self:_refreshDrag()
		end
		self._lastKeepAspectRatio = keepAspectRatio
		self._lastResizeFromCenter = resizeFromCenter
		return true
	else
		return false
	end
end

function ExtrudeHandle:keyDown(keyCode)
	return self:_refreshDragIfNeeded()
end

function ExtrudeHandle:keyUp(keyCode)
	return self:_refreshDragIfNeeded()
end

function ExtrudeHandle:hitTest(mouseRay, ignoreExtraThreshold)
	local closestHandleId, closestHandleDistance = nil, math.huge
	for handleId, handleProps in pairs(self._handles) do
		local distance = ScaleHandleView.hitTest(handleProps, mouseRay)
		if distance and distance < closestHandleDistance then
			closestHandleDistance = distance
			closestHandleId = handleId
		end
	end
	if closestHandleId then
		return closestHandleId, 0
	elseif ignoreExtraThreshold then
		return nil, 0
	else
		-- Second attempt to find a handle, now using closest distance to the ray
		-- rather than closest hit distance to the camera.
		for handleId, handleProps in pairs(self._handles) do
			local distance = ScaleHandleView.distanceFromHandle(handleProps, mouseRay)
			if distance < closestHandleDistance then
				closestHandleDistance = distance
				closestHandleId = handleId
			end
		end

		-- Only hit a handle if we are actually inside the closest handle's
		-- extra hitTest radius.
		if closestHandleDistance < 0 then
			return closestHandleId, 0
		else
			return nil, 0
		end
	end
end

function ExtrudeHandle:render(hoveredHandleId)
	local children = {}
	if self._draggingHandleId and self._handles[self._draggingHandleId] then
		local handleProps = self._handles[self._draggingHandleId]
		children[self._draggingHandleId] = Roact.createElement(ScaleHandleView, {
			HandleCFrame = handleProps.HandleCFrame,
			Color = handleProps.Color,
			Scale = handleProps.Scale,
		})

		for otherHandleId, otherHandleProps in pairs(self._handles) do
			if otherHandleId ~= self._draggingHandleId then
				children[otherHandleId] = Roact.createElement(ScaleHandleView, {
					HandleCFrame = otherHandleProps.HandleCFrame,
					Color = Colors.makeDimmed(otherHandleProps.Color),
					Scale = otherHandleProps.Scale,
					Thin = true,
				})
			end
		end

		children.ImplementationRendered =
			self._implementation:render(self._lastDeltaSize, self._lastOffset)
	else
		for handleId, handleProps in pairs(self._handles) do
			local color = handleProps.Color
			local hovered = (handleId == hoveredHandleId)
			if not hovered then
				color = Colors.makeDimmed(handleProps.Color)
			end
			children[handleId] = Roact.createElement(ScaleHandleView, {
				HandleCFrame = handleProps.HandleCFrame,
				Color = color,
				Scale = handleProps.Scale,
				Hovered = hovered,
			})
		end
	end

	-- Show selection bounding box when scaling multiple items.
	if self._props.ShowBoundingBox and #self._selectionWrapper:get() > 1 then
		children.SelectionBoundingBox = Roact.createElement(StandaloneSelectionBox, {
			CFrame = self._boundingBox.CFrame,
			Size = self._boundingBox.Size,
			Color = self._draggerContext:getSelectionBoxColor(),
			LineThickness = self._draggerContext:getHoverLineThickness(),
			Container = self._draggerContext:getGuiParent(),
		})
	end

	if getFFlagSummonPivot() and self._props.Summonable then
		if self._summonBasisOffset then
			children.SummonedPivot = Roact.createElement(DraggedPivot, {
				DraggerContext = self._draggerContext,
				CFrame = self._boundingBox.CFrame * self:_getBasisOffset(),
				IsActive = self._draggerContext:shouldShowActiveInstanceHighlight() and (#self._selectionWrapper:get() == 1),
			})
		end
	end

	if getFFlagFoldersOverFragments() then
		return Roact.createElement("Folder", {}, children)
	else
		return Roact.createFragment(children)
	end
end

function ExtrudeHandle:mouseDown(mouseRay, handleId)
	self._draggingHandleId = handleId

	if self._handles[handleId] then
		self._normalId = self._handles[handleId].NormalId
		self._handleCFrame = self._handles[handleId].HandleCFrame
		if getEngineFeatureModelPivotVisual() then
			self:_rememberCurrentBoundsAsOriginal()
		else
			self._originalBoundingBoxCFrame = self._boundingBox.CFrame
			self._originalBoundingBoxSize = self._boundingBox.Size
		end

		self._lastKeepAspectRatio, self._lastResizeFromCenter = self:_getExtrudeMode()

		local hasDistance, distance = self:_getDistanceAlongAxis(mouseRay)
		assert(hasDistance)
		self._startDistance = distance

		-- When you change extrude modes mid drag, we need to separate the
		-- resize you've done so far from the part you will do in the new mode.
		-- The part you've done so far is the "committed" part.
		self._committedDeltaSize = Vector3.new()
		self._committedOffset = Vector3.new()

		self._lastDeltaSize = Vector3.new()
		self._lastOffset = Vector3.new()
		self._minimumSize = self._implementation:getMinimumSize(
			self._selectionWrapper:get(), self._selectionInfo, self._normalId)

		self._implementation:beginScale(
			self._selectionWrapper:get(),
			self._selectionInfo,
			self._normalId)
	end
end

local function computeDeltaSize(originalSize, delta, normalId, keepAspectRatio)
	local sizeComponents = {originalSize.X, originalSize.Y, originalSize.Z}
	local xyz = {0, 0, 0}
	xyz[normalId] = delta
	if keepAspectRatio then
		local ratio = delta / sizeComponents[normalId]
		xyz[nextNormalId(normalId)] = sizeComponents[nextNormalId(normalId)] * ratio
		xyz[nextNormalId(nextNormalId(normalId))] = sizeComponents[nextNormalId(nextNormalId(normalId))] * ratio
	end
	return Vector3.new(unpack(xyz))
end

local function maxComponent(vector: Vector3)
	return math.max(math.abs(vector.X), math.abs(vector.Y), math.abs(vector.Z))
end

function ExtrudeHandle:mouseDrag(mouseRay)
	assert(self._draggingHandleId, "Missing dragging handle ID.")

	if not self._handles[self._draggingHandleId] then
		return
	end

	-- The settings used for the drag may have changed.
	-- Return value intentionally ignored, we're already in the process of
	-- updating the drag, so we're doing the drag update anyways regardless
	-- of whether a refresh was needed due to a settings change.
	self:_refreshDragIfNeeded()

	local hasDistance, distance = self:_getDistanceAlongAxis(mouseRay)
	if not hasDistance then
		return
	end

	local delta = self._draggerContext:snapToGridSize(distance - self._startDistance)
	local handleProps = self._handles[self._draggingHandleId]
	local normalId = handleProps.NormalId
	local axis = handleProps.Axis

	local localOffset
	if self._lastResizeFromCenter then
		delta = delta * 2
		localOffset = Vector3.new()
	else
		localOffset = axis * 0.5 * delta
	end

	-- Add the movement thanks to an offset center
	if getEngineFeatureModelPivotVisual() then
		local sizeComponents = {self._originalBoundingBoxSize.X, self._originalBoundingBoxSize.Y, self._originalBoundingBoxSize.Z}
		local ratio = delta / sizeComponents[normalId]
		
		if getFFlagSummonPivot() then
			-- The condition here is relevant in the case where you summon the
			-- pivot while resizing a single part.
			if self._lastKeepAspectRatio then
				localOffset = localOffset - self._perpendicularMovement * ratio
			end
		else
			localOffset = localOffset - self._perpendicularMovement * ratio
		end
	end

	-- Determine the size change for the selection
	local originalSize = self._originalBoundingBoxSize
	local deltaSize = computeDeltaSize(originalSize, delta, normalId, self._lastKeepAspectRatio)

	-- Apply the minimum size
	local targetSize = self._originalBoundingBoxSize + deltaSize
	local modTargetSize = self._minimumSize:Max(targetSize)
	if targetSize ~= modTargetSize then
		if self._lastKeepAspectRatio then
			-- Can't keep aspect ratio while applying a min size, bail out
			-- TODO: Improve this
			return
		end
		local newDeltaSize = modTargetSize - self._originalBoundingBoxSize
		local denominator = maxComponent(deltaSize)
		local fractionPossible = (denominator > 0) and
			(maxComponent(newDeltaSize) / denominator) or 0
		localOffset = localOffset * fractionPossible
		deltaSize = newDeltaSize
	end

	local deltaSizeToApply = deltaSize + self._committedDeltaSize
	local localOffsetToApply = localOffset + self._committedOffset

	-- Eliminate floating-point error for edits that don't have any visible impact
	if deltaSizeToApply:FuzzyEq(Vector3.new()) then
		deltaSizeToApply = Vector3.new()
	end
	if localOffsetToApply:FuzzyEq(Vector3.new()) then
		localOffsetToApply = Vector3.new()
	end

	self._lastDeltaSize, self._lastOffset =
		self._implementation:updateScale(deltaSizeToApply, localOffsetToApply)
	self._boundingBox.CFrame = self._originalBoundingBoxCFrame * CFrame.new(self._lastOffset - self._committedOffset)
	self._boundingBox.Size = originalSize + (self._lastDeltaSize - self._committedDeltaSize)
	if getEngineFeatureModelPivotVisual() then
		if getFFlagSummonPivot() and self._summonBasisOffset then
			self._summonBasisOffset =
				CFrame.new(self._originalBasisOffset / self._originalBoundingBoxSize * self._boundingBox.Size)
			-- We can't stop summoning in the middle of a drag, so no need to
			-- update _basisOffset in the case where we've summoned, it will not
			-- be used.
		else
			self._basisOffset =
				CFrame.new(self._originalBasisOffset / self._originalBoundingBoxSize * self._boundingBox.Size)
		end
	end
end

function ExtrudeHandle:mouseUp(mouseRay)
	if self._handles[self._draggingHandleId] then
		self._implementation:endScale()
	end

	self._draggingHandleId = nil

	if getFFlagSummonPivot() and not self._tabKeyDown then
		self:_endSummon()
	end
	self._schema.addUndoWaypoint(self._draggerContext, "Scale Selection")
end

function ExtrudeHandle:_getDistanceAlongAxis(mouseRay)
	local axis = self._handleCFrame.LookVector
	if getEngineFeatureModelPivotVisual() then
		return Math.intersectRayRay(
			(self._originalBoundingBoxCFrame * CFrame.new(self._originalBasisOffset)).Position, axis,
			mouseRay.Origin, mouseRay.Direction.Unit)
	else
		return Math.intersectRayRay(self._originalBoundingBoxCFrame.Position, axis, mouseRay.Origin, mouseRay.Direction.Unit)
	end
end

function ExtrudeHandle:_updateHandles()
	if self._selectionInfo:isEmpty() or self._boundingBox.Size:FuzzyEq(Vector3.new()) then
		-- Can't scale something with a zero size.
		self._handles = {}
	else
		for handleId, handleDefinition in pairs(ScaleHandleDefinitions) do
			-- Offset the handle's base position by the size of the bounding
			-- box on that handle's axis.
			local offset = handleDefinition.Offset
			if getEngineFeatureModelPivotVisual() then
				local inverseHandleCFrame = offset:Inverse()
				local localSize = inverseHandleCFrame:VectorToWorldSpace(self._boundingBox.Size)
				local offsetDueToBoundingBox = 0.5 * math.abs(localSize.Z)
				local offsetDueToBasisOffset
				if getFFlagSummonPivot() then
					offsetDueToBasisOffset = inverseHandleCFrame:VectorToWorldSpace(self:_getBasisOffset().Position)
				else
					offsetDueToBasisOffset = inverseHandleCFrame:VectorToWorldSpace(self._basisOffset.Position)
				end
				local handleBaseCFrame =
					self._boundingBox.CFrame *
					offset *
					CFrame.new(offsetDueToBasisOffset.X, offsetDueToBasisOffset.Y, -offsetDueToBoundingBox)
				self._handles[handleId] = {
					Color = handleDefinition.Color,
					Axis = offset.LookVector,
					HandleCFrame = handleBaseCFrame,
					NormalId = handleDefinition.NormalId,
					Scale = self._draggerContext:getHandleScale(handleBaseCFrame.Position),
				}
			else
				local localSize = offset:Inverse():VectorToWorldSpace(self._boundingBox.Size)
				local boundingBoxOffset = 0.5 * math.abs(localSize.Z)
				local handleBaseCFrame = self._boundingBox.CFrame * offset * CFrame.new(0, 0, -boundingBoxOffset)

				self._handles[handleId] = {
					Color = handleDefinition.Color,
					Axis = offset.LookVector,
					HandleCFrame = handleBaseCFrame,
					NormalId = handleDefinition.NormalId,
					Scale = self._draggerContext:getHandleScale(handleBaseCFrame.Position),
				}
			end
		end
	end
end

if getEngineFeatureModelPivotVisual() and getFFlagSummonPivot() then
	function ExtrudeHandle:keyDown(keyCode)
		if keyCode == Enum.KeyCode.Tab then
			self._tabKeyDown = true
			if not self._draggingHandleId then
				self:_summonHandles()
				return true
			end
		end
		return false
	end

	function ExtrudeHandle:keyUp(keyCode)
		if keyCode == Enum.KeyCode.Tab then
			self._tabKeyDown = false
			if not self._draggingHandleId then
				self:_endSummon()
			end
			return true
		end
		return false
	end
end

return ExtrudeHandle
