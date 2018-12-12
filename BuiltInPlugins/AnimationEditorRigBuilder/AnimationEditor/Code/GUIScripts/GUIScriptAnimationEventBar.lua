-- singleton
local EventBar = {}

EventBar.TargetWidget = nil
EventBar.EventArea = nil
EventBar.Connections = nil
EventBar.KeyframeMarkers = {}

local function initKeyframeMarkers(self, keyframes)
	self:clearKeyframeMarkers()
	for time, key in pairs(keyframes) do
		if not self.Paths.HelperFunctionsTable:isNilOrEmpty(key.Markers) then
			self:addKeyframeMarker(time)
		end
	end
end

local function findEventsInMultiSelectArea(self)
	for _, marker in ipairs(self.KeyframeMarkers) do
		if self.SelectAndDragBox:isInSelectedTimeRange(marker.Time) then
			self.Paths.DataModelAnimationEvents:addMultiSelectedAnimationEvent(marker.Time)
		else
			self.Paths.DataModelAnimationEvents:removeMultiSelectedAnimationEvent(marker.Time)
		end
	end
	self.Paths.DataModelAnimationEvents.SelectionChangedEvent:fire()
end

local function onAddClicked(self)
	local time = self.Paths.DataModelSession:getScrubberTime()
	local keyframe = self.Paths.DataModelKeyframes:getOrCreateKeyframe(time)
	if keyframe then
		self.Paths.GUIScriptEditAnimationEvents:show(time)
	end
end

local function onAreaClicked(self, input)
	if Enum.UserInputType.MouseButton1 == input.UserInputType and not self.Paths.InputKeyboard:isKeyCtrlOrCmdDown() then
		self.Paths.DataModelAnimationEvents:selectNone()
	end
	if Enum.UserInputType.MouseButton2 == input.UserInputType then
		self.Paths.GUIScriptAnimationEventMenu:show(self.Paths.UtilityScriptDisplayArea:getFormattedMouseTime(true))
	end
end

local function onManageClicked(self)
	self.Paths.GUIScriptManageEvents:show()
	self.ManageEventsButton:setPressed(true)
end

function EventBar:init(Paths)
	self.Paths = Paths
	self.TargetWidget = self.Paths.GUIAnimationEventBar
	self.EventArea = self.Paths.GUIEventArea
	self.Paths.UtilityScriptDisplayArea:addDisplay(self.EventArea)
	self.Connections = Paths.UtilityScriptConnections:new()

	self.SelectAndDragBox = self.Paths.WidgetSelectAndDragBox:new(Paths, Paths.GUIEventMultiSelectBox, self.EventArea, function() findEventsInMultiSelectArea(self) end)
	self.ManageEventsButton = self.Paths.WidgetCustomImageButton:new(self.Paths, self.TargetWidget.AnimationEventsButtons.ManageEventsButton)

	initKeyframeMarkers(self, self.Paths.DataModelKeyframes.keyframeList)
	self.Connections:add(self.Paths.DataModelKeyframes.ChangedEvent:connect(function(keyframes) initKeyframeMarkers(self, keyframes) end))
	self.Connections:add(self.TargetWidget.AnimationEventsButtons.AddEventsButton.MouseButton1Click:connect(function() onAddClicked(self) end))
	self.Connections:add(self.EventArea.InputBegan:connect(function(input) onAreaClicked(self, input) end))
	self.Connections:add(self.TargetWidget.AnimationEventsButtons.ManageEventsButton.MouseButton1Click:connect(function() onManageClicked(self) end))
	self.Connections:add(self.Paths.GUIScriptManageEvents.WindowClosedEvent:connect(function() self.ManageEventsButton:setPressed(false) end))
end

function EventBar:addKeyframeMarker(time)
	self.KeyframeMarkers[#self.KeyframeMarkers + 1] = self.Paths.GUIScriptKeyframeMarker:new(self.Paths, self.EventArea, time)
end

function EventBar:clearKeyframeMarkers()
	for _, marker in ipairs(self.KeyframeMarkers) do
		marker:terminate()
	end
	self.KeyframeMarkers = {}
end

function EventBar:terminate()
	self.Paths.UtilityScriptDisplayArea:removeDisplay(self.EventArea)
	self.ManageEventsButton:terminate()
	self.TargetWidget = nil
	self.EventArea = nil
	self.Connections:disconnectAll()
end

return EventBar