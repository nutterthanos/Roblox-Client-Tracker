--[[
	Container component for the Timeline/Scrubber, DopeSheetController, and ZoomBar. Determines what the actual frame
	range displayed on the timeline is.

	Properties:
		int StartFrame = beginning frame of timeline range
		int EndFrame = end frame of timeline range
		int LastFrame = The last frame of the animation
		int FrameRate = the rate (frames per second) of the animation
		int Playhead = current frame the scrubber is on
		UDim2 Size = size of the frame
		int LayoutOrder = The layout order of the frame, if in a Layout.
		int ZIndex = The draw index of the frame.
		bool ShowEvents = Whether to show the Animation Events track.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local UILibrary = require(Plugin.UILibrary)

local Separator = UILibrary.Component.Separator

local Mouse = require(Plugin.SrcDeprecated.Context.Mouse)
local getMouse = Mouse.getMouse

local Constants = require(Plugin.SrcDeprecated.Util.Constants)
local TrackUtils = require(Plugin.SrcDeprecated.Util.TrackUtils)
local Input = require(Plugin.SrcDeprecated.Util.Input)

local DopeSheetController = require(Plugin.SrcDeprecated.Components.DopeSheetController)
local TimelineContainer = require(Plugin.SrcDeprecated.Components.TimelineContainer)
local ZoomBar = require(Plugin.SrcDeprecated.Components.ZoomBar)
local Scrubber = require(Plugin.SrcDeprecated.Components.Timeline.Scrubber)
local KeyboardListener = UILibrary.Focus.KeyboardListener

local SetScrollZoom = require(Plugin.SrcDeprecated.Actions.SetScrollZoom)
local StepAnimation = require(Plugin.SrcDeprecated.Thunks.Playback.StepAnimation)
local SnapToNearestKeyframe = require(Plugin.SrcDeprecated.Thunks.SnapToNearestKeyframe)

local TrackEditor = Roact.PureComponent:extend("TrackEditor")

function TrackEditor:init()
	self.ctrlHeld = false
	self.dragging = false

	self.updateSize = function(rbx)
		self:setState({
			AbsoluteSize = rbx.AbsoluteSize,
			AbsolutePosition = rbx.AbsolutePosition,
		})
	end

	self.inputChanged = function(rbx, input)
		local props = self.props
		local zoom = props.Zoom
		local scroll = props.Scroll
		local trackWidth = self.state.AbsoluteSize.X
		local trackLeft = self.state.AbsolutePosition.X

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local xPos = (input.Position.X  - trackLeft) / trackWidth
			local newScroll = (xPos - scroll) * (1 - zoom)
			newScroll = math.clamp(scroll + newScroll, 0, 1)

			if self.ctrlHeld then
				if input.Position.Z > 0 then
					props.SetScrollZoom(newScroll, math.clamp(zoom + Constants.ZOOM_INCREMENT, 0, 1))
				elseif input.Position.Z < 0 then
					props.SetScrollZoom(newScroll, math.clamp(zoom - Constants.ZOOM_INCREMENT, 0, 1))
				end
			else
				props.OnScroll(input.Position.Z)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseMovement and self.dragging then
			local xDelta = (-input.Delta.X) / trackWidth
			local newScroll = xDelta * (1 / math.max(0.01, zoom))
			newScroll = math.clamp(scroll + newScroll, 0, 1)
			props.SetScrollZoom(newScroll, zoom)
		end
	end

	self.startDragging = function()
		self.dragging = true
	end

	self.stopDragging = function()
		self.dragging = false
	end

	self.inputBegan = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton3 then
			getMouse(self).pushCursor("ClosedHand")
			self.startDragging()
		end
	end

	self.inputEnded = function(_, input)
		if self.dragging and input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.MouseButton3 then
			getMouse(self).popCursor()
			self.stopDragging()
		end
	end

	self.getPlayheadPositionX = function()
		local props = self.props
		local absoluteSize = self.state.AbsoluteSize or Vector2.new()
		local playhead = props.Playhead
		return (Constants.TRACK_PADDING * 0.5) + TrackUtils.getScaledKeyframePosition(
			playhead,
			props.StartFrame,
			props.EndFrame,
			absoluteSize.X - Constants.TRACK_PADDING)
	end

	self.stepAnimation = function(frame)
		local props = self.props
		if not props.IsPlaying then
			props.StepAnimation(frame)
		end
	end
end

function TrackEditor:render()
	local props = self.props
	local state = self.state

	local startFrame = props.StartFrame
	local endFrame = props.EndFrame
	local lastFrame = props.LastFrame
	local snapToKeys = props.SnapToKeys
	local frameRate = props.FrameRate
	local showAsSeconds = props.ShowAsSeconds
	local scroll = props.Scroll
	local zoom = props.Zoom
	local layoutOrder = props.LayoutOrder
	local zIndex = props.ZIndex
	local size = props.Size
	local topTrackIndex = props.TopTrackIndex
	local tracks = props.Tracks or {}
	local showEvents = props.ShowEvents
	local playhead = props.Playhead

	local snapToNearestKeyframe = props.SnapToNearestKeyframe
	local absoluteSize = state.AbsoluteSize or Vector2.new()
	local absolutePosition = state.AbsolutePosition or Vector2.new()

	local showPlayhead = playhead >= startFrame and playhead <= endFrame

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		ZIndex = zIndex,
		LayoutOrder = layoutOrder,
		Size = size,
		[Roact.Change.AbsoluteSize] = self.updateSize,

		[Roact.Event.InputBegan] = self.inputBegan,
		[Roact.Event.InputChanged] = self.inputChanged,
		[Roact.Event.InputEnded] = self.inputEnded,
		[Roact.Event.MouseLeave] = self.stopDragging,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),

		TimelineContainer = Roact.createElement(TimelineContainer, {
			StartFrame = startFrame,
			EndFrame = endFrame,
			LastFrame = lastFrame,
			SnapToKeys = snapToKeys,
			FrameRate = frameRate,
			ShowAsSeconds = showAsSeconds,
			LayoutOrder = 0,
			ParentSize = absoluteSize,
			ParentPosition = absolutePosition,
			StepAnimation = self.stepAnimation,
			SnapToNearestKeyframe = snapToNearestKeyframe,
		}),

		DopeSheetController = Roact.createElement(DopeSheetController, {
			ShowEvents = showEvents,
			StartFrame = startFrame,
			EndFrame = endFrame,
			TopTrackIndex = topTrackIndex,
			Tracks = tracks,
			Size = UDim2.new(1, 0, 1, -Constants.TIMELINE_HEIGHT - Constants.SCROLL_BAR_SIZE),
		}),

		ZoomBar = Roact.createElement(ZoomBar, {
			Size = UDim2.new(0, absoluteSize.X - Constants.SCROLL_BAR_PADDING, 0, Constants.SCROLL_BAR_SIZE),
			ZIndex = 4,
			LayoutOrder = 2,
			ContainerSize = absoluteSize,
			AdjustScrollZoom = props.SetScrollZoom,
			Scroll = scroll,
			Zoom = zoom,
			LeftX = absolutePosition.X,
		}),

		IgnoreLayout = Roact.createElement("Folder", {}, {
			TimelineBorder = Roact.createElement(Separator, {
				Position = UDim2.new(0.5, 0, 0, Constants.TIMELINE_HEIGHT),
				DominantAxis = Enum.DominantAxis.Width,
				Weight = 1,
				Padding = 0,
				ZIndex = 2,
			}),

			Scrubber = showPlayhead and Roact.createElement(Scrubber, {
				Position = UDim2.new(0, self.getPlayheadPositionX(), 0, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Height = absoluteSize.Y,
				ShowHead = true,
				HeadSize = UDim2.new(0, 5, 0, 5),
				ZIndex = 3,
				Thickness = 1,
			}),

			KeyboardListener = Roact.createElement(KeyboardListener, {
				OnKeyPressed = function(input)
					if Input.isControl(input.KeyCode) then
						self.ctrlHeld = true
					end
				end,
				OnKeyReleased = function(input)
					if Input.isControl(input.KeyCode) then
						self.ctrlHeld = false
					end
				end,
			}),
		}),
	})
end

local function mapStateToProps(state, props)
	return {
		IsPlaying = state.Status.IsPlaying,
		SnapToKeys = state.Status.SnapToKeys,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SetScrollZoom = function(scroll, zoom)
			dispatch(SetScrollZoom(scroll, zoom))
		end,

		StepAnimation = function(frame)
			dispatch(StepAnimation(frame))
		end,

		SnapToNearestKeyframe = function(frame, trackWidth)
			dispatch(SnapToNearestKeyframe(frame, trackWidth))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(TrackEditor)