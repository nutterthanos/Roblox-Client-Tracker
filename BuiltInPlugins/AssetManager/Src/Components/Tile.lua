local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = Plugin.Packages.Framework
local ContextServices = require(Framework.ContextServices)
local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier

local UI = require(Framework.UI)
local Tooltip = UI.Tooltip

local UILibrary = require(Plugin.Packages.UILibrary)
local GetTextSize = UILibrary.Util.GetTextSize

local PopUpButton = require(Plugin.Src.Components.PopUpButton)
local enableAudioImport = require(Plugin.Src.Util.AssetManagerUtilities).enableAudioImport

local SetEditingAssets = require(Plugin.Src.Actions.SetEditingAssets)
local SetSelectedAssets = require(Plugin.Src.Actions.SetSelectedAssets)

local GetAssetPreviewData = require(Plugin.Src.Thunks.GetAssetPreviewData)
local OnAssetDoubleClick = require(Plugin.Src.Thunks.OnAssetDoubleClick)
local OnAssetRightClick = require(Plugin.Src.Thunks.OnAssetRightClick)
local OnAssetSingleClick = require(Plugin.Src.Thunks.OnAssetSingleClick)

local FFlagStudioAssetManagerDisableHoverOnOverlay = game:GetFastFlag("StudioAssetManagerDisableHoverOnOverlay")

local AssetManagerService = game:GetService("AssetManagerService")
local ContentProvider = game:GetService("ContentProvider")

local Tile = Roact.PureComponent:extend("Tile")

local function stripText(text)
    local newText = string.gsub(text, "%s+", "")
    newText = string.gsub(newText, "\n", "")
    newText = string.gsub(newText, "\t", "")
    return newText
end

local ICON_SIZE = 150

function Tile:init()
    self.state = {
        -- StyleModifier must be upper case first character because of how Theme in ContextServices uses it.
        StyleModifier = nil,
        assetFetchStatus = nil,
        assetPreviewButtonHovered = false,
        editText = "",
    }

    self.editing = false

    self.textBoxRef = Roact.createRef()

    self.onMouseEnter = function()
        if FFlagStudioAssetManagerDisableHoverOnOverlay then
            local props = self.props
            if not props.Enabled then
                return
            end
        end
        if self.state.StyleModifier == nil then
            self:setState({
                StyleModifier = StyleModifier.Hover,
            })
        end
        self:setState({
            assetPreviewButtonHovered = true,
        })
        local assetData = self.props.AssetData
        local isFolder = assetData.ClassName == "Folder"
        local isPlace = assetData.assetType == Enum.AssetType.Place
        if not isFolder and not isPlace then
            self.props.dispatchGetAssetPreviewData(self.props.API:get(), {assetData.id})
        end
    end

    self.onMouseLeave = function()
        if FFlagStudioAssetManagerDisableHoverOnOverlay then
            local props = self.props
            if not props.Enabled then
                return
            end
        end
        if self.state.StyleModifier == StyleModifier.Hover then
            self:setState({
                StyleModifier = Roact.None,
            })
        end
        self:setState({
            assetPreviewButtonHovered = false,
        })
    end

    self.onMouseActivated = function(rbx, obj, clickCount)
        local props = self.props
        if not props.Enabled then
            return
        end
        local assetData = props.AssetData
        if clickCount == 0 then
            props.dispatchOnAssetSingleClick(obj, assetData)
        elseif clickCount == 1 then
            props.dispatchOnAssetDoubleClick(props.Analytics, assetData)
        end
    end

    self.onMouseButton2Click = function(rbx, x, y)
        local props = self.props
        if not props.Enabled then
            return
        end
        local assetData = props.AssetData
        local isFolder = assetData.ClassName == "Folder"
        if isFolder then
            if not props.SelectedAssets[assetData.Screen.LayoutOrder] then
                props.dispatchOnAssetSingleClick(nil, assetData)
            end
        else
            if not props.SelectedAssets[assetData.key] then
                props.dispatchOnAssetSingleClick(nil, assetData)
            end
        end
        props.dispatchOnAssetRightClick(props)
    end

    self.openAssetPreview = function()
        local assetData = self.props.AssetData
        -- when opening asset preview, set selected assets to that asset only
        self.props.dispatchSetSelectedAssets({ [assetData.key] = true })
        self.props.OnOpenAssetPreview(assetData)
    end

    self.onTextChanged = function(rbx)
        local text = rbx.Text
        if text ~= self.props.AssetData.name then
            self:setState({
                editText = text,
            })
        end
	end

	self.onTextBoxFocusLost = function(rbx, enterPressed, inputObject)
        local props = self.props
        local assetData = props.AssetData
        local newName = self.state.editText
        if utf8.len(newName) ~= 0 and utf8.len(stripText(newName)) ~= 0 then
            if assetData.assetType == Enum.AssetType.Place then
                AssetManagerService:RenamePlace(assetData.id, newName)
            elseif assetData.assetType == Enum.AssetType.Image
            or assetData.assetType == Enum.AssetType.MeshPart
            or assetData.assetType == Enum.AssetType.Lua
            or (enableAudioImport() and assetData.assetType == Enum.AssetType.Audio)
            then
                local prefix
                -- Setting asset type to same value as Enum.AssetType since it cannot be passed into function
                if assetData.assetType == Enum.AssetType.Image then
                    prefix = "Images/"
                elseif assetData.assetType == Enum.AssetType.MeshPart then
                    prefix = "Meshes/"
                elseif assetData.assetType == Enum.AssetType.Lua then
                    prefix = "Scripts/"
                elseif (enableAudioImport() and assetData.assetType == Enum.AssetType.Audio) then
                    prefix = "Audio/"
                end
                AssetManagerService:RenameAlias(assetData.assetType.Value, assetData.id, prefix .. assetData.name, prefix .. newName)
            end
            props.AssetData.name = newName
        end
        props.dispatchSetEditingAssets({})
        self.editing = false
        -- force re-render to show updated name
        self:setState({
            editText = props.AssetData.name,
        })
	end

    local props = self.props
    local assetData = props.AssetData

    local isFolder = assetData.ClassName == "Folder"
    local assetId = assetData.id
    if not isFolder then
        if assetData.assetType == Enum.AssetType.Place then
            self.thumbnailUrl = string.format("rbxthumb://type=AutoGeneratedAsset&id=%i&w=%i&h=%i", assetId, ICON_SIZE, ICON_SIZE)
        else
            self.thumbnailUrl = string.format("rbxthumb://type=Asset&id=%i&w=%i&h=%i", assetId, ICON_SIZE, ICON_SIZE)
        end
        spawn(function()
            local asset = { self.thumbnailUrl }
            local function setStatus(contentId, status)
                self:setState({
                    assetFetchStatus = status
                })
            end
            ContentProvider:PreloadAsync(asset, setStatus)
        end)
    end
end

function Tile:didMount()
    self:setState({
        editText = self.props.AssetData.name
    })
end

function Tile:didUpdate(lastProps, lastState)
    local props = self.props
    local assetData = props.AssetData
    local isEditingAsset = props.EditingAssets[assetData.id]
    if isEditingAsset then
        if self.textBoxRef and self.textBoxRef.current and not self.editing then
            local textBox = self.textBoxRef.current
            textBox:CaptureFocus()
            textBox.SelectionStart = 1
            textBox.CursorPosition = #textBox.Text + 1
            self.editing = true
        end
    end
end

function Tile:render()
    local props = self.props
    local pluginStyle = props.Theme:get("Plugin")

    -- Must use getStyle(namespace, component) for StyleModifiers to work
    -- otherwise functionality equivalent to prop.Theme:get("Plugin").Tile.Default
    local tileStyle = props.Theme:getStyle("Plugin", self)

    local enabled = props.Enabled

    local size = tileStyle.Size

    local assetData = props.AssetData

    local backgroundColor = tileStyle.BackgroundColor
    local backgroundTransparency = tileStyle.BackgroundTransparency
    local borderSizePixel = tileStyle.BorderSizePixel

    local textColor = tileStyle.Text.Color
    local textFont = pluginStyle.Font
    local textSize = tileStyle.Text.Size
    local textBGTransparency = tileStyle.Text.BackgroundTransparency
    local textTruncate = tileStyle.Text.TextTruncate
    local textXAlignment = tileStyle.Text.XAlignment
    local textYAlignment = tileStyle.Text.YAlignment

    local textFrameSize = tileStyle.Text.Frame.Size
    local textFramePos = tileStyle.Text.Frame.Position

    local editText = self.state.editText
    local isEditingAsset = props.EditingAssets[assetData.id]
    local editTextWrapped = tileStyle.EditText.TextWrapped
    local editTextClearOnFocus = tileStyle.EditText.ClearTextOnFocus
    local editTextXAlignment = tileStyle.Text.XAlignment

    local editTextFrameBackgroundColor = tileStyle.EditText.Frame.BackgroundColor
    local editTextFrameBorderColor = tileStyle.EditText.Frame.BorderColor

    local editTextSize = GetTextSize(editText, textSize, textFont, Vector2.new(tileStyle.Size.X.Offset, math.huge))
    local editTextPadding
    if editTextSize.X < tileStyle.Size.X.Offset then
        editTextPadding = tileStyle.EditText.TextPadding
    else
        editTextPadding = 0
    end

    local name = assetData.name
    local displayName = assetData.name
    local nameSize = GetTextSize(assetData.name, textSize, textFont,
        Vector2.new(textFrameSize.X.Offset, math.huge))
    if nameSize.Y > textFrameSize.Y.Offset then
        -- using hardcoded values for now since tile size is constant
        displayName = string.sub(assetData.name, 1, 12) .. "..." ..
            string.sub(assetData.name, string.len(assetData.name) - 5)
    end

    local isFolder = assetData.ClassName == "Folder"
    local isPlace = assetData.assetType == Enum.AssetType.Place

    local image
    if isFolder then
        image = assetData.Screen.Image
    else
        image = self.state.assetFetchStatus == Enum.AssetFetchStatus.Success and self.thumbnailUrl
            or tileStyle.Image.PlaceHolder
    end

    local imageFrameSize = tileStyle.Image.FrameSize
    local imageSize = tileStyle.Image.ImageSize
    local imagePos = tileStyle.Image.Position
    local imageFolderPos = tileStyle.Image.FolderPosition
    local imageFolderAnchorPos = tileStyle.Image.FolderAnchorPosition
    local imageBGColor = tileStyle.Image.BackgroundColor

    local createAssetPreviewButton = not isFolder and not isPlace
    local showAssetPreviewButton = self.state.assetPreviewButtonHovered
    local magnifyingGlass = tileStyle.AssetPreview.Image
    local assetPreviewButtonOffset = tileStyle.AssetPreview.Button.Offset

    local isRootPlace = assetData.isRootPlace
    local rootPlaceImageSize = tileStyle.Image.StartingPlace.Size
    local rootPlaceIcon = tileStyle.Image.StartingPlace.Icon
    local rootPlaceIconXOffset = tileStyle.Image.StartingPlace.XOffset
    local rootPlaceIconYOffset = tileStyle.Image.StartingPlace.YOffset

    local layoutOrder = props.LayoutOrder

    local thumbnailContainer = isFolder and "Frame" or "ImageLabel"
    local thumbnailContainerProps = {
        Size = imageFrameSize,
        Position = imagePos,

        BackgroundTransparency = 0,
        BackgroundColor3 = imageBGColor,
        BorderSizePixel = 0,
    }

    if not isFolder then
        thumbnailContainerProps.Image = image
    end

    return Roact.createElement("ImageButton", {
        Size = size,
        BackgroundColor3 = backgroundColor,
        BackgroundTransparency = backgroundTransparency,
        BorderSizePixel = borderSizePixel,

        LayoutOrder = layoutOrder,

        [Roact.Event.Activated] = self.onMouseActivated,
        [Roact.Event.MouseButton2Click] = self.onMouseButton2Click,
        [Roact.Event.MouseEnter] = self.onMouseEnter,
        [Roact.Event.MouseLeave] = self.onMouseLeave,
    }, {
        ThumbnailContainer = Roact.createElement(thumbnailContainer, thumbnailContainerProps, {
            AssetPreviewButton = createAssetPreviewButton and Roact.createElement(PopUpButton, {
                Position = UDim2.new(1, -assetPreviewButtonOffset, 0, assetPreviewButtonOffset),

                Image = magnifyingGlass,
                ShowIcon = showAssetPreviewButton,
                OnClick = self.openAssetPreview,
                OnRightClick = self.onMouseButton2Click,
            }),

            RootPlaceImage = isRootPlace and Roact.createElement("ImageLabel", {
                Size = UDim2.new(0, rootPlaceImageSize, 0, rootPlaceImageSize),
                Position = UDim2.new(0, rootPlaceIconXOffset, 0, rootPlaceIconYOffset),

                Image = rootPlaceIcon,
                BackgroundTransparency = 1,
            }),

            FolderImage = isFolder and Roact.createElement("ImageLabel", {
                Size = imageSize,
                Image = image,
                Position = imageFolderPos,
                AnchorPoint = imageFolderAnchorPos,

                BackgroundTransparency = 1,
            })
        }),

        Name = not isEditingAsset and Roact.createElement("TextLabel", {
            Size = textFrameSize,
            Position = textFramePos,

            Text = displayName,
            TextColor3 = textColor,
            Font = textFont,
            TextSize = textSize,

            BackgroundTransparency = textBGTransparency,
            TextXAlignment = textXAlignment,
            TextYAlignment = textYAlignment,
            TextTruncate = textTruncate,
            TextWrapped = true,
        }),

        RenameTextBox = isEditingAsset and Roact.createElement("TextBox",{
            Size = UDim2.new(0, editTextSize.X + editTextPadding,
                0, editTextSize.Y),
            Position = textFramePos,

            BackgroundColor3 = editTextFrameBackgroundColor,
            BorderColor3 = editTextFrameBorderColor,

            Text = editText,
            TextColor3 = textColor,
            Font = textFont,
            TextSize = textSize,

            TextXAlignment = editTextXAlignment,
            TextTruncate = Enum.TextTruncate.None,
            TextWrapped = editTextWrapped,
            ClearTextOnFocus = editTextClearOnFocus,

            [Roact.Ref] = self.textBoxRef,

            [Roact.Change.Text] = self.onTextChanged,
            [Roact.Event.FocusLost] = self.onTextBoxFocusLost,
        }),

        Tooltip = enabled and Roact.createElement(Tooltip, {
            Text = name,
            Enabled = true,
        }),
    })
end

ContextServices.mapToProps(Tile, {
    Analytics = ContextServices.Analytics,
    API = ContextServices.API,
    Localization = ContextServices.Localization,
    Mouse = ContextServices.Mouse,
    Plugin = ContextServices.Plugin,
    Theme = ContextServices.Theme,
})

local function mapStateToProps(state, props)
    local assetManagerReducer = state.AssetManagerReducer
	return {
        EditingAssets = assetManagerReducer.editingAssets,
        SelectedAssets = assetManagerReducer.selectedAssets,
	}
end

local function mapDispatchToProps(dispatch)
	return {
        dispatchGetAssetPreviewData = function(apiImpl, assetIds)
            dispatch(GetAssetPreviewData(apiImpl, assetIds))
        end,
        dispatchOnAssetDoubleClick = function(analytics, assetData)
            dispatch(OnAssetDoubleClick(analytics, assetData))
        end,
        dispatchOnAssetRightClick = function(props)
            dispatch(OnAssetRightClick(props))
        end,
        dispatchOnAssetSingleClick = function(obj, assetData)
            dispatch(OnAssetSingleClick(obj, assetData))
        end,
        dispatchSetEditingAssets = function(editingAssets)
            dispatch(SetEditingAssets(editingAssets))
        end,
        dispatchSetSelectedAssets = function(selectedAssets)
            dispatch(SetSelectedAssets(selectedAssets))
        end,
    }
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Tile)