
local DraggerSchemaCore = script.Parent
local Packages = DraggerSchemaCore.Parent
local DraggerFramework = Packages.DraggerFramework

local JointMaker = require(DraggerFramework.Utility.JointMaker)
local getBoundingBoxScale = require(DraggerFramework.Utility.getBoundingBoxScale)
local TemporaryTransparency = require(DraggerFramework.Utility.TemporaryTransparency)
local PivotImplementation = require(DraggerFramework.Utility.PivotImplementation)

local EngineFeatureEditPivot = require(DraggerFramework.Flags.getEngineFeatureEditPivot)()

local ExtrudeHandlesImplementation = {}
ExtrudeHandlesImplementation.__index = ExtrudeHandlesImplementation

function ExtrudeHandlesImplementation.new(draggerContext)
	return setmetatable({
		_draggerContext = draggerContext,
		_jointMaker = JointMaker.new(),
	}, ExtrudeHandlesImplementation)
end

-- The difference from exactly touching to try to bring a pair of parts within
-- when collisions are enabled.
-- After resizing one part into a collision with another one, the closest pair
-- of points P1 on the first part and P2 on the second part should satisfy:
-- (P1 - P2).Magnitude < RESIZE_COLLISION_THRESHOLD
-- Note: This is a deliberately looser threshold than the transform one, so that
-- after resizing parts into a collision, they can still be moved.
local RESIZE_COLLISION_THRESHOLD = 0.001

-- This function can just be `return selectionInfo:getBoundingBox()` unless you
-- need some special behavior.
function ExtrudeHandlesImplementation:getBoundingBox(selection, selectionInfo)
	-- When we only have one part selected, we're in extrude scaling mode,
	-- which can only be done in local space.
	local partsToResize, _ = selectionInfo:getObjectsToTransform()
	if #partsToResize == 1 then
		return selectionInfo:getLocalBoundingBox()
	else
		return selectionInfo:getBoundingBox()
	end
end

-- Should the tool act as an actual scale tool (scaling around the basis
-- CFrame), or scale by moving the edge of the bounding box?
function ExtrudeHandlesImplementation:shouldScaleFromCenter(selection, selectionInfo, normalId)
	return self._draggerContext:isCtrlKeyDown()
end

function ExtrudeHandlesImplementation:shouldKeepAspectRatio(selection, selectionInfo, normalId)
	if self._draggerContext:isShiftKeyDown() then
		return true
	end
	local partsToResize, _ = selectionInfo:getObjectsToTransform()
	if #partsToResize == 1 then
		local part = partsToResize[1]
		if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
			return true
		end
		if part:IsA("UnionOperation") or part:IsA("NegateOperation") then
			return true
		end
		return false
	else
		return true
	end
end

--[[
	Find the smallest extents size that assures that all parts are larger
	than the minimum allowed part size.

	Resizing Cases:
	Suppose you have a part 5.5 studs long and a grid snap of 2
	 * You should be able to resize it down to 1.5 (5.5 % 2)
	Suppose you have a part 4 studs long and a grid snap of 2
	 * You should be able to resize it down to 2
	 * You should NOT be able to resize it down to 0 or MIN_PART_SIZE (It should
	   stop resizing at 2)
	Suppose you have a part 2.02 studs long and grid snap of 2
	 * You should NOT be able to resize it down to 0.02 (< MIN_PART_SIZE)
]]
function ExtrudeHandlesImplementation:getMinimumSize(selection, selectionInfo, normalId)
	local partsToResize = selectionInfo:getObjectsToTransform()
	local boundsCFrame, boundsOffset, boundsSize = self:getBoundingBox(selection, selectionInfo)

	local MIN_PART_SIZE = 0.05
	if #partsToResize == 1 then
		-- The modulo covers resizing down to smaller than the initial size in
		-- gridSize increments.
		local gridSizeValue = self._draggerContext:getGridSize()
		local partSize = partsToResize[1].Size
		local xmod = partSize.X % gridSizeValue
		local ymod = partSize.Y % gridSizeValue
		local zmod = partSize.Z % gridSizeValue

		-- This handles the edge case of trying to resize down to zero from an
		-- even multiple of the grid size.
		local modSize = Vector3.new(
			xmod > 0 and xmod or gridSizeValue,
			ymod > 0 and ymod or gridSizeValue,
			zmod > 0 and zmod or gridSizeValue)

		-- This Max call handles the resizing down to less than MIN_PART_SIZE
		-- but still greater than zero edge case.
		local hardMinSize = Vector3.new(MIN_PART_SIZE, MIN_PART_SIZE, MIN_PART_SIZE)
		return hardMinSize:Max(modSize)
	else
		local smallest = math.huge
		local minimumSize
		for _, part in ipairs(partsToResize) do
			local size = part.Size
			local minLength = math.min(size.X, size.Y, size.Z)
			if minLength < smallest then
				smallest = minLength
				local sizeRatio = minLength / MIN_PART_SIZE
				minimumSize = boundsSize / sizeRatio
			end
		end

		-- Make sure that the resized normal of the part is at least as
		-- large as the grid size.
		local minSizeComponents =
			{minimumSize.X, minimumSize.Y, minimumSize.Z}
		local sizeRatio = minSizeComponents[normalId] / self._draggerContext:getGridSize()
		if sizeRatio < 1 then
			minimumSize = minimumSize / sizeRatio
		end

		-- Finally, we CAN still resize down to less than the grid size if
		-- we started out smaller than the grid size.
		return minimumSize:Min(boundsSize)
	end
end

function ExtrudeHandlesImplementation:beginScale(selection, initialSelectionInfo, normalId)
	local boundsCFrame, boundsOffset
	boundsCFrame, boundsOffset, self._originalBoundingBoxSize =
		initialSelectionInfo:getBoundingBox()
	self._originalBoundingBoxCFrame = boundsCFrame * CFrame.new(boundsOffset)

	self._originalCFrameMap = initialSelectionInfo:getOriginalCFrameMap()
	self._partsToResize, self._attachmentsToMove =
		initialSelectionInfo:getObjectsToTransform()

	self._originalSizeMap = {}
	for _, part in ipairs(self._partsToResize) do
		self._originalSizeMap[part] = part.Size
	end

	self._lastDeltaSize = Vector3.new(0, 0, 0)
	self._jointMaker:pickUpParts(self._partsToResize)
	self._jointMaker:anchorParts()
	self._jointMaker:breakJointsToOutsiders()
	self._jointMaker:disconnectInternalJoints()

	self:_recordItemsToFixup(self._partsToResize)

	if not self._draggerContext:areCollisionsEnabled() then
		self._temporaryTransparency = TemporaryTransparency.new(self._partsToResize)
	end
end

local function roundDownIfClose(value, gridSize, threshold)
	local snapped = math.floor(value / gridSize) * gridSize
	if value - snapped < threshold then
		return snapped
	else
		return value
	end
end

-- If the part size is almost (within RESIZE_COLLISION_THRESHOLD) aligned to the
-- grid size, then snap it exactly back to the grid size, to allow parts which
-- somehow gained a floating point error in their size to return to being sized
-- exactly on grid. Note: We can only round down because rounding up may bring
-- the part into collision with something it wasn't before.
function ExtrudeHandlesImplementation:_maybeSnapPartSizeBackDownToGrid(size)
	local gridSize = self._draggerContext:getGridSize()
	return Vector3.new(
		roundDownIfClose(size.X, gridSize, RESIZE_COLLISION_THRESHOLD),
		roundDownIfClose(size.Y, gridSize, RESIZE_COLLISION_THRESHOLD),
		roundDownIfClose(size.Z, gridSize, RESIZE_COLLISION_THRESHOLD))
end

local function largestComponent(vector)
	return math.min(math.abs(vector.X), math.abs(vector.Y), math.abs(vector.Z))
end

local function getFraction(lastSizeDelta, thisSizeDelta)
	local maxLast = largestComponent(lastSizeDelta)
	local maxThis = largestComponent(thisSizeDelta)
	if maxThis == 0 then
		return 0
	else
		return maxLast / maxThis
	end
end

-- Scale / offset the selection by some local offset relative to the
-- initialSelectionInfo's basisCFrame. Also takes the new size of the bounding
-- box for convenience, though you may not need this.
function ExtrudeHandlesImplementation:updateScale(localDeltaSize, localOffset)
	local doResize
	local lastOffset = localOffset

	if #self._partsToResize == 1 then
		local part = self._partsToResize[1]
		local originalSize = self._originalSizeMap[part]
		local originalCFrame = self._originalCFrameMap[part]

		function doResize(frac)
			self._lastDeltaSize = localDeltaSize * frac
			part.Size = originalSize + self._lastDeltaSize
			lastOffset = localOffset * frac
			part.CFrame = originalCFrame * CFrame.new(lastOffset)
		end
	else
		local originalCFrame = self._originalBoundingBoxCFrame
		local originalSize = self._originalBoundingBoxSize
		local center = originalCFrame.Position

		local globalOffset = originalCFrame:VectorToWorldSpace(localOffset)
		local totalScale =
			(originalSize + localDeltaSize).Magnitude / originalSize.Magnitude

		-- Precalculate the offsets to apply while scaling
		local totalOffsetForPartMap = {}
		for _, part in ipairs(self._partsToResize) do
			local originalPartPosition = self._originalCFrameMap[part].Position
			local offsetFromCenter = originalPartPosition - center
			totalOffsetForPartMap[part] = globalOffset + offsetFromCenter * (totalScale - 1)
		end

		function doResize(frac)
			self._lastDeltaSize = localDeltaSize * frac
			lastOffset = localOffset * frac
			local scale = 1 + frac * (totalScale - 1)
			local scaleVector = Vector3.new(scale, scale, scale)
			for part, totalOffset in pairs(totalOffsetForPartMap) do
				part.CFrame = self._originalCFrameMap[part] + totalOffset * frac
				part.Size = self._originalSizeMap[part] * scaleVector
			end
		end
	end

	if self._draggerContext:areCollisionsEnabled() then
		local initialFraction = getFraction(self._lastDeltaSize, localDeltaSize)
		local targetFraction = 1.0
		local includeInitiallyTouching = true
		local threshold =
			RESIZE_COLLISION_THRESHOLD / math.max(largestComponent(localDeltaSize), 1)
		self:_binarySearchForGoodPartSize(doResize,
			initialFraction,
			targetFraction,
			includeInitiallyTouching,
			threshold)
	else
		doResize(1.0)
	end

	-- Try to fix up floating point error on parts which are very close to the
	-- grid size.
	if #self._partsToResize == 1 then
		local thePart = self._partsToResize[1]
		thePart.Size = self:_maybeSnapPartSizeBackDownToGrid(thePart.Size)
	end

	-- Fixup stuff like meshes / constraint lengths
	local appliedScale =
		(self._originalBoundingBoxSize + self._lastDeltaSize) / self._originalBoundingBoxSize
	self:_applyFixup(appliedScale)
	self._jointMaker:fixupConstraintLengths()

	if self._draggerContext:shouldJoinSurfaces() then
		self._jointPairs = self._jointMaker:computeJointPairs()
	end

	return self._lastDeltaSize, lastOffset
end

function ExtrudeHandlesImplementation:endScale()
	self._originalSizeMap = {}

	if self._jointPairs then
		self._jointPairs:createJoints()
		self._jointPairs = nil
	end

	local appliedScale = getFraction(
		self._originalBoundingBoxSize + self._lastDeltaSize,
		self._originalBoundingBoxSize)
	self._jointMaker:reconnectInternalJointsWithScale(appliedScale)
	self._jointMaker:restoreAnchored()
	self._jointMaker:putDownParts()

	if self._temporaryTransparency then
		self._temporaryTransparency:destroy()
		self._temporaryTransparency = nil
	end
end

function ExtrudeHandlesImplementation:render(localDeltaSize, localOffset)
	if self._draggerContext:shouldJoinSurfaces() and self._jointPairs then
		local cframe = self._originalBoundingBoxCFrame * CFrame.new(localOffset)
		local size = self._originalBoundingBoxSize + localDeltaSize
		local scale = getBoundingBoxScale(self._draggerContext, cframe, size)
		return self._jointPairs:renderJoints(scale)
	else
		return nil
	end
end

--[[
	Finds the maximum value resizeFunction can be called with (called with a
	fraction between initialFraction and targetFraction) without any of the
	_jointMaker's parts colliding with other parts.
	If includeInitiallyTouching is false then collisions with parts it was
	colliding with to begin with are ignored.
]]
function ExtrudeHandlesImplementation:_binarySearchForGoodPartSize(
	resizeFunction, initialFraction, targetFraction, includeInitiallyTouching, threshold)
	-- Early out, can we resize right to the target?
	resizeFunction(targetFraction)
	local lastIterationHadCollision = self._jointMaker:isColliding(includeInitiallyTouching)
	if not lastIterationHadCollision then
		return
	end

	local collides = 0
	local min = initialFraction
	local max = targetFraction
	for _ = 1, 32 do
		local mid = 0.5 * (min + max)
		resizeFunction(mid)
		lastIterationHadCollision = self._jointMaker:isColliding(includeInitiallyTouching)
		if lastIterationHadCollision then
			collides = collides + 1
			max = mid
		else
			min = mid
		end
	end

	-- Don't allow slightly resizing away from the last value (which would
	-- introduce floating point error but no useful changes)
	if math.abs(min - initialFraction) < threshold then
		lastIterationHadCollision = true
		min = initialFraction
	end

	-- Ensure we stop in a non-colliding state
	if lastIterationHadCollision then
		resizeFunction(min)
	end

	return min
end

function ExtrudeHandlesImplementation:_recordItemsToFixup(parts)
	self._fixupAttachments = {}
	self._fixupOffsets = {}
	self._fixupScales = {}
	if EngineFeatureEditPivot then
		self._fixupPivot = {}
	end
	for _, part in ipairs(parts) do
		if EngineFeatureEditPivot then
			if PivotImplementation.hasPivot(part) then
				self._fixupPivot[part] = part.CFrame:Inverse() * PivotImplementation.getPivot(part)
			end
		end
		for _, descendant in ipairs(part:GetDescendants()) do
			if descendant:IsA("Attachment") then
				self._fixupAttachments[descendant] = descendant.Position
			elseif descendant:IsA("DataModelMesh") then
				self._fixupOffsets[descendant] = descendant.Offset
				if descendant.ClassName == "FileMesh" or
					(descendant:IsA("SpecialMesh") and descendant.MeshType == Enum.MeshType.FileMesh) then
					self._fixupScales[descendant] = descendant.Scale
				end
			end
		end
	end
end

function ExtrudeHandlesImplementation:_applyFixup(scaledBy)
	for attachment, position in pairs(self._fixupAttachments) do
		attachment.Position = position * scaledBy
	end
	for offsetItem, offset in pairs(self._fixupOffsets) do
		offsetItem.Offset = offset * scaledBy
	end
	for scaleItem, scale in pairs(self._fixupScales) do
		scaleItem.Scale = scale * scaledBy
	end
	if EngineFeatureEditPivot then
		for part, localPivot in pairs(self._fixupPivot) do
			local offset = localPivot.Position
			local rotation = localPivot - offset
			PivotImplementation.setPivot(part, part.CFrame * (rotation + scaledBy * offset))
		end
	end
end

return ExtrudeHandlesImplementation