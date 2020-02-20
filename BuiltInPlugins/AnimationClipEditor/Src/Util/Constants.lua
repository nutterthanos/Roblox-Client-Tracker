local FFlagStudioUseAnimationEditorAnalytics2 = game:DefineFastFlag("StudioUseAnimationEditorAnalytics2", false)

local Constants = {
	PLUGIN_NAME = "AnimationClipEditor",

	PLUGIN_BUTTON_IMAGE = "rbxasset://textures/AnimationEditor/animation_editor_blue.png",
	CHECK_IMAGE = "rbxasset://textures/ui/LuaChat/icons/ic-check@2x.png",

	USE_MOCK_ANALYTICS = not FFlagStudioUseAnimationEditorAnalytics2,

	ZOOM_INCREMENT = 0.04,

	DEFAULT_FRAMERATE = 30,
	MIN_FRAMERATE = 1,
	MAX_FRAMERATE = 120,

	MAX_TIME = 30,
	MIN_TIMELINE_RANGE = 30,

	MAIN_FLOATING_SIZE = Vector2.new(640, 200),
	MAIN_MINIMUM_SIZE = Vector2.new(535, 200),

	MAX_WAYPOINT_SIZE = 20,
	MIN_SPACE_BETWEEN_KEYS = 8,

	TRACK_PADDING = 32,
	SUMMARY_TRACK_HEIGHT = 22,
	TRACK_HEIGHT = 22,
	EVENT_MARKER_SIZE = UDim2.new(0, 6, 0, 20),
	EVENT_MARKER_BORDER_SIZE = UDim2.new(0, 8, 0, 22),

	TIMELINE_HEIGHT = 24,
	CONTROLS_WIDTH = 110,
	TIME_DISPLAY_WIDTH = 100,

	SCROLL_BAR_SIZE = 17,
	SCROLL_BAR_PADDING = 2,

	TRACK_LIST_START_WIDTH = 335,
	TRACK_LIST_MIN_WIDTH = 335,
	TIMELINE_MIN_WIDTH = 200,

	INDENT_PADDING = 8,
	ARROW_SIZE = 10,
	TRACKLIST_BUTTON_SIZE = 16,
	TRACKLIST_RIGHT_PADDING = 8,

	NUMBERBOX_WIDTH = 70,
	NUMBERTRACK_PADDING = 5,

	KEYFRAME_WIDTH = 6,
	SUMMARY_KEYFRAME_WIDTH = 8,

	MAX_VISIBLE_KEYFRAMES = 1000,
	LENGTH_PADDING = 1,
	NUM_TICKS = 5,
	TICK_SPACING = 125,

	PROMPT_SIZE = UDim2.new(0, 320, 0, 130),
	PROMPT_BUTTON_SIZE = Vector2.new(100, 25),
	PROMPT_BUTTON_PADDING = 10,
	PROMPT_VERTICAL_PADDING = 15,
	PROMPT_HORIZONTAL_PADDING = 20,

	TRANSLATION_STIFFNESS = 0.7,
	ROTATION_STIFFNESS = 0.7,
	MIN_TRANSLATION_STIFFNESS = 0.01,
	MIN_ROTATION_STIFFNESS = 0.01,
	MIN_EFFECTOR_DISTANCE = 10,

	BONE_CLASS_NAME = "Bone",
	MOTOR_CLASS_NAME = "Motor6D",

	-- Bone Vis Constants
	BONE_NODE_COLOR = Color3.fromRGB(232, 112, 240),
	BONE_LINK_COLOR = Color3.fromRGB(107, 50, 124),
	BONE_CONE_COLOR = Color3.fromRGB(207, 88, 224),
	BONE_NODE_TRANSPARENCY = 0.15,
	BONE_LINK_TRANSPARENCY = 0.45,
	LENGTH_TO_RADIUS_RATIO = 15,

	SNAP_TO_KEYFRAME_THRESHOLD = 30, --in pixels

	TEMPORARY_CONSTRAINTS = "ROBLOX_R15_IK_CONSTRAINTS",

	DEFAULT_ANIMATION_NAME = "Untitled Animation Clip",
	DEFAULT_IMPORTED_NAME = "Imported Animation Clip",
	DEFAULT_AUTOSAVE_NAME = "Automatic Save",
	DEFAULT_KEYFRAME_NAME = "Keyframe",

	TRACK_TYPES = {
		CFrame = "CFrame",
		Other = "Other",
	},

	INSTANCE_TYPES = {
		Skeleton = "Skeleton",
		Rig = "Rig",
	},

	-- User-facing text values that should not be localized,
	-- because they can be referenced from code.
	PROPERTY_KEYS = {
		Position = "Position",
		Rotation = "Rotation",
		X = "X",
		Y = "Y",
		Z = "Z",
	},

	-- Button or menu item keys that are referenced in code.
	-- Not used for display text.
	ACTION_KEYS = {
		Edit = "Edit",
		Delete = "Delete",
	},

	CLIP_DROPDOWN_TYPES = {
		Clip = "Clip",
		NewClip = "New Clip",
		Separator = "Separator",
	},

	RIG_ERRORS = {
		NameCollision = "NameCollision",
		NoMotors = "NoMotors",
		PartsAnchored = "PartsAnchored",
		MissingPart0 = "MissingPart0",
		MissingPart1 = "MissingPart1",
		MultipleParents = "MultipleParents",
		CircularRig = "CircularRig",
		NoAnimationController = "NoAnimationController",
	},

	TIMELINE_UNITS = {
		Seconds = "Seconds",
		Frames = "Frames",
	},

	FRAMERATES = {
		FPS_24 = 24,
		FPS_30 = 30,
		FPS_60 = 60,
		FPS_120 = 120,
		CUSTOM = -1
	},

	CLIPBOARD_TYPE = {
		Events = "Events",
		Keyframes = "Keyframes",
	},

	MENU_SEPARATOR = "Separator",

	KEYFRAME_STYLE = {
		Primary = "Primary",
		Error = "Error",
		PrimaryError = "PrimaryError",
		[Enum.PoseEasingStyle.Bounce] = "Bounce",
		[Enum.PoseEasingStyle.Constant] = "Constant",
		[Enum.PoseEasingStyle.Cubic] = "Cubic",
		[Enum.PoseEasingStyle.Elastic] = "Elastic",
	},

	MENU_ICONS = {
		[Enum.PoseEasingStyle.Linear] = "rbxasset://textures/AnimationEditor/image_keyframe_linear_unselected.png",
		[Enum.PoseEasingStyle.Bounce] = "rbxasset://textures/AnimationEditor/image_keyframe_bounce_unselected.png",
		[Enum.PoseEasingStyle.Constant] = "rbxasset://textures/AnimationEditor/image_keyframe_constant_unselected.png",
		[Enum.PoseEasingStyle.Cubic] = "rbxasset://textures/AnimationEditor/image_keyframe_cubic_unselected.png",
		[Enum.PoseEasingStyle.Elastic] = "rbxasset://textures/AnimationEditor/image_keyframe_elastic_unselected.png",
	},

	IK_MODE = {
		BodyPart = "BodyPart",
		FullBody = "FullBody",
	},

	R15_PARTS = {
		UpperTorso = "UpperTorso",
		LowerTorso = "LowerTorso",
		LeftFoot = "LeftFoot",
		RightFoot = "RightFoot",
		HumanoidRootPart = "HumanoidRootPart",
		Head = "Head",
		RightUpperLeg = "RightUpperLeg",
		RightLowerLeg = "RightLowerLeg",
		RightHand = "RightHand",
		LeftUpperLeg = "LeftUpperLeg",
		LeftLowerLeg = "LeftLowerLeg",
		LeftHand = "LeftHand",
		RightUpperArm = "RightUpperArm",
		RightLowerArm = "RightLowerArm",
		LeftUpperArm = "LeftUpperArm",
		LeftLowerArm = "LeftLowerArm",
	},

	CONSTRAINTS_CONFIG = {
		Ankle = {
			Type = "BallSocketConstraint",
			LimitsEnabled = false,
			Restitution = 0,
			TwistLimitsEnabled = false,
			UpperAngle = 20,
			TwistLowerAngle = -20,
			TwistUpperAngle = 20,
		},

		Knee = {
			Type = "HingeConstraint",
			LimitsEnabled = true,
			LowerAngle = -135,
			Restitution = 0,
			UpperAngle = -10,
		},

		Hip = {
			Type = "BallSocketConstraint",
			LimitsEnabled = true,
			Restitution = 0,
			TwistLimitsEnabled = true,
			UpperAngle = 80,
			TwistLowerAngle = -3,
			TwistUpperAngle = 3,
			Axis = Vector3.new(0, -1, 0),
			SecondaryAxis = Vector3.new(0, 0, 1)
		},

		Waist = {
			Type = "HingeConstraint",
			LimitsEnabled = true,
			LowerAngle = -90,
			Restitution = 0,
			UpperAngle = 90,
		},

		Shoulder = {
			Type = "BallSocketConstraint",
			LimitsEnabled = true,
			Restitution = 0,
			TwistLimitsEnabled = false,
			UpperAngle = 170,
			TwistLowerAngle = -90,
			TwistUpperAngle = 135,
		},

		Elbow = {
			Type = "HingeConstraint",
			LimitsEnabled = true,
			LowerAngle = 0,
			Restitution = 0,
			UpperAngle = 135,
		},

		Wrist = {
			Type = "BallSocketConstraint",
			LimitsEnabled = true,
			Restitution = 0,
			TwistLimitsEnabled = true,
			UpperAngle = 20,
			TwistLowerAngle = 0,
			TwistUpperAngle = 0,
		},

		Neck = {
			Type = "BallSocketConstraint",
			LimitsEnabled = true,
			Restitution = 0,
			TwistLimitsEnabled = false,
			UpperAngle = 30,
			TwistLowerAngle = -70,
			TwistUpperAngle = 70,
		}
	}
}

Constants.PartToConstraintConfigMap = {
	[Constants.R15_PARTS.UpperTorso] = Constants.CONSTRAINTS_CONFIG.Waist,
	[Constants.R15_PARTS.RightUpperLeg] = Constants.CONSTRAINTS_CONFIG.Hip,
	[Constants.R15_PARTS.LeftUpperLeg] = Constants.CONSTRAINTS_CONFIG.Hip,
	[Constants.R15_PARTS.RightUpperArm] = Constants.CONSTRAINTS_CONFIG.Shoulder,
	[Constants.R15_PARTS.LeftUpperArm] = Constants.CONSTRAINTS_CONFIG.Shoulder,
	[Constants.R15_PARTS.Head] = Constants.CONSTRAINTS_CONFIG.Neck,
	[Constants.R15_PARTS.LeftLowerArm] = Constants.CONSTRAINTS_CONFIG.Elbow,
	[Constants.R15_PARTS.LeftHand] = Constants.CONSTRAINTS_CONFIG.Wrist,
	[Constants.R15_PARTS.RightLowerArm] = Constants.CONSTRAINTS_CONFIG.Elbow,
	[Constants.R15_PARTS.RightHand] = Constants.CONSTRAINTS_CONFIG.Wrist,
	[Constants.R15_PARTS.LeftLowerLeg] = Constants.CONSTRAINTS_CONFIG.Knee,
	[Constants.R15_PARTS.LeftFoot] = Constants.CONSTRAINTS_CONFIG.Ankle,
	[Constants.R15_PARTS.RightLowerLeg] = Constants.CONSTRAINTS_CONFIG.Knee,
	[Constants.R15_PARTS.RightFoot] = Constants.CONSTRAINTS_CONFIG.Ankle,
}

Constants.R15links = {
	[Constants.R15_PARTS.LowerTorso] = Constants.R15_PARTS.HumanoidRootPart,
	[Constants.R15_PARTS.UpperTorso] = Constants.R15_PARTS.LowerTorso,
	[Constants.R15_PARTS.RightUpperLeg] = Constants.R15_PARTS.LowerTorso,
	[Constants.R15_PARTS.LeftUpperLeg] = Constants.R15_PARTS.LowerTorso,
	[Constants.R15_PARTS.RightUpperArm] = Constants.R15_PARTS.UpperTorso,
	[Constants.R15_PARTS.LeftUpperArm] = Constants.R15_PARTS.UpperTorso,
	[Constants.R15_PARTS.Head] = Constants.R15_PARTS.UpperTorso,
	[Constants.R15_PARTS.LeftLowerArm] = Constants.R15_PARTS.LeftUpperArm,
	[Constants.R15_PARTS.LeftHand] = Constants.R15_PARTS.LeftLowerArm,
	[Constants.R15_PARTS.RightLowerArm] = Constants.R15_PARTS.RightUpperArm,
	[Constants.R15_PARTS.RightHand] = Constants.R15_PARTS.RightLowerArm,
	[Constants.R15_PARTS.LeftLowerLeg] = Constants.R15_PARTS.LeftUpperLeg,
	[Constants.R15_PARTS.LeftFoot] = Constants.R15_PARTS.LeftLowerLeg,
	[Constants.R15_PARTS.RightLowerLeg] = Constants.R15_PARTS.RightUpperLeg,
	[Constants.R15_PARTS.RightFoot] = Constants.R15_PARTS.RightLowerLeg,
}

return Constants