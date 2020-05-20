local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local Framework = Plugin.Framework

local Header = require(Plugin.Src.Components.Header)
local GameIconWidget = require(Plugin.Src.Components.GameIcon.GameIconWidget)
local PaidAccess = require(Plugin.Src.Components.PaidAccess)
local VIPServers = require(Plugin.Src.Components.VIPServers)
local DevProducts = require(Plugin.Src.Components.DevProducts)

local FrameworkUI = require(Framework.UI)
local HoverArea = FrameworkUI.HoverArea
local Separator = FrameworkUI.Separator

local FrameworkUtil = require(Framework.Util)
local LayoutOrderIterator = FrameworkUtil.LayoutOrderIterator
local FitFrameOnAxis = FrameworkUtil.FitFrame.FitFrameOnAxis

local UILibrary = require(Plugin.UILibrary)
local TitledFrame = UILibrary.Component.TitledFrame
local RoundTextBox = UILibrary.Component.RoundTextBox
local RoundFrame = UILibrary.Component.RoundFrame
local TextEntry = UILibrary.Component.TextEntry

local layoutIndex = LayoutOrderIterator.new()

local AddChange = require(Plugin.Src.Actions.AddChange)
local AddErrors = require(Plugin.Src.Actions.AddErrors)
local DiscardError = require(Plugin.Src.Actions.DiscardError)
local SetEditDevProductId = require(Plugin.Src.Actions.SetEditDevProductId)

local FileUtils = require(Plugin.Src.Util.FileUtils)

local PageName = "Monetization"

local MAX_NAME_LENGTH = 50
local MAX_DESCRIPTION_LENGTH = 1000
local PAID_ACCESS_MIN_PRICE = 25
local PAID_ACCESS_MAX_PRICE = 1000
local VIP_SERVERS_MIN_PRICE = 10

local createSettingsPage = require(Plugin.Src.Components.SettingsPages.DEPRECATED_createSettingsPage)

local priceErrors = {
    BelowMin = "ErrorPriceBelowMin",
    AboveMax = "ErrorPriceAboveMax",
    Invalid = "ErrorPriceInvalid",
}

--Loads settings values into props by key
local function loadValuesToProps(getValue, state)
    local errors = state.Settings.Errors
    local loadedProps = {
        TaxRate = getValue("taxRate"),
        MinimumFee = getValue("minimumFee"),

        PaidAccess = {
            enabled = getValue("isForSale"),
            price = getValue("price"),
        },
        VIPServers = {
            isEnabled = getValue("vipServersIsEnabled"),
			price = getValue("vipServersPrice"),
			activeServersCount = getValue("vipServersActiveServersCount"),
			activeSubscriptionsCount = getValue("vipServersActiveSubscriptionsCount"),
        },

        DevProducts = getValue("developerProducts"),

        EditDevProductId = state.EditAsset.editDevProductId,

        PriceError = errors.monetizationPrice,
    }

    return loadedProps
end

--Implements dispatch functions for when the user changes values
local function dispatchChanges(setValue, dispatch)
    local dispatchFuncs = {
        PaidAccessToggled = function(button)
            dispatch(AddChange("isForSale", button.Id))
        end,

        PaidAccessPriceChanged = function(text)
            local numberValue = tonumber(text)

            if not numberValue then
                dispatch(AddErrors({monetizationPrice = "Invalid"}))
            elseif numberValue < PAID_ACCESS_MIN_PRICE then
                dispatch(AddErrors({monetizationPrice = "BelowMin"}))
            elseif numberValue > PAID_ACCESS_MAX_PRICE then
                dispatch(AddErrors({monetizationPrice = "AboveMax"}))
            else
                dispatch(AddChange("price", tostring(text)))
                dispatch(DiscardError("monetizationPrice"))
            end
        end,

        VIPServersToggled = function(button)
            dispatch(AddChange("vipServersIsEnabled", button.Id))
        end,

        VIPServersPriceChanged = function(text)
            local numberValue = tonumber(text)
            if not numberValue then
                dispatch(AddErrors({monetizationPrice = "Invalid"}))
            elseif numberValue < VIP_SERVERS_MIN_PRICE then
                dispatch(AddErrors({monetizationPrice = "BelowMin"}))
            else
                dispatch(AddChange("vipServersPrice", text))
                dispatch(DiscardError("monetizationPrice"))
            end
        end,

        SetEditDevProductId = function(devProductId)
            dispatch(SetEditDevProductId(devProductId))
        end,

        SetDevProduct = function(productId, product)
            dispatch(AddChange("developerProducts",{
                [productId] = product,
            }))
        end,
    }
    return dispatchFuncs
end

local function convertDeveloperProductsForTable(devProducts)
    local result = {}
    local index = 2
    for id, product in pairs(devProducts) do
        result[id] = {
            index = index,
            row = {
                id,
                product.name,
                product.price,
            },
        }
    end

    return result
end

--Uses props to display current settings values
local function displayMonetizationPage(props, localization)
    local taxRate = props.TaxRate
    local minimumFee = props.MinimumFee

    local paidAccessEnabled = props.PaidAccess.enabled
    local paidAccessPrice = props.PaidAccess.price

    local vipServers = props.VIPServers

    local devProducts = props.DevProducts and props.DevProducts or {}
    local devProductsForTable = convertDeveloperProductsForTable(devProducts)

    local paidAccessToggled = props.PaidAccessToggled
    local paidAccessPriceChanged = props.PaidAccessPriceChanged

    local vipServersToggled = props.VIPServersToggled
    local vipServersPriceChanged = props.VIPServersPriceChanged

    local setEditDevProductId = props.SetEditDevProductId

    local priceError
    if props.PriceError and priceErrors[props.PriceError] then
        local errorValue
        if props.PriceError == "BelowMin" and vipServers.isEnabled then
            errorValue = string.format("%.f", VIP_SERVERS_MIN_PRICE)
        elseif props.PriceError == "BelowMin" and paidAccessEnabled then
            errorValue = string.format("%.f", PAID_ACCESS_MIN_PRICE)
        elseif props.PriceError == "AboveMax" and paidAccessEnabled then
            errorValue = string.format("%.f", PAID_ACCESS_MAX_PRICE)
        end
        priceError = localization:getText("Errors", priceErrors[props.PriceError], {errorValue})
    end

    if not taxRate then
        paidAccessEnabled = nil
        vipServers.isEnabled = nil
    end

    return {
        Header = Roact.createElement(Header, {
            Title = localization:getText("General", "Category"..PageName),
			LayoutOrder = layoutIndex:getNextOrder(),
        }),

        PaidAccess = Roact.createElement(PaidAccess, {
            Price = paidAccessPrice,
            TaxRate = taxRate,
            MinimumFee = minimumFee,

            PriceError = paidAccessEnabled and priceError or nil,

            LayoutOrder = layoutIndex:getNextOrder(),
            Enabled = vipServers.isEnabled == false,
            Selected = paidAccessEnabled,

            OnPaidAccessToggle = paidAccessToggled,
            OnPaidAccessPriceChanged = paidAccessPriceChanged,
        }),

        VIPServers = Roact.createElement(VIPServers, {
            VIPServersData = vipServers,
            TaxRate = taxRate,
            MinimumFee = minimumFee,

            PriceError = vipServers.isEnabled and priceError or nil,

            LayoutOrder = layoutIndex:getNextOrder(),
            Enabled = paidAccessEnabled == false,

            OnVipServersToggled = vipServersToggled,
            OnVipServersPriceChanged = vipServersPriceChanged,
        }),

		DevProducts = Roact.createElement(DevProducts, {
            ProductList = devProductsForTable,

            LayoutOrder = layoutIndex:getNextOrder(),

            OnEditDevProductClicked = setEditDevProductId
		})
    }
end

local function displayEditDevProductsPage(props, localization)
	local theme = props.Theme:get("Plugin")

	local layoutIndex = LayoutOrderIterator.new()

    local productId = props.EditDevProductId
    local currentDevProduct = props.DevProducts[productId]

    local baseDevProduct = currentDevProduct
    if not baseDevProduct then
        baseDevProduct = {
            name = "",
            description = "",
            iconImageAssetId = "",
            price = 10,
        }
    end

    local productTitle = baseDevProduct.name
    local productDescripton = baseDevProduct.description
    local productIcon = baseDevProduct.iconImageAssetId
    local productPrice = baseDevProduct.price

    local setEditDevProductId = props.SetEditDevProductId
    local setDevProduct = props.SetDevProduct

	return {
		HeaderFrame = Roact.createElement(FitFrameOnAxis, {
			LayoutOrder = layoutIndex:getNextOrder(),
			BackgroundTransparency = 1,
			axis = FitFrameOnAxis.Axis.Vertical,
			minimumSize = UDim2.new(1, 0, 0, 0),
			contentPadding = UDim.new(0, theme.settingsPage.headerPadding),
		}, {
			BackButton = Roact.createElement("ImageButton", {
				Size = UDim2.new(0, theme.backButton.size, 0, theme.backButton.size),
				LayoutOrder = 0,

				Image = theme.backButton.image,

				BackgroundTransparency = 1,

                [Roact.Event.Activated] = function()
                    setEditDevProductId(nil)
				end,
			}, {
				Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
			}),

			Roact.createElement(Separator, {
				LayoutOrder = 1
			}),

			Header = Roact.createElement(Header, {
				Title = localization:getText("Monetization", "EditDeveloperProduct"),
				LayoutOrder = 2,
			}),
		}),

		Name = Roact.createElement(TitledFrame, {
			Title = localization:getText("General", "TitleName"),
			MaxHeight = 60,
			LayoutOrder = layoutIndex:getNextOrder(),
			TextSize = theme.fontStyle.Normal.TextSize,
		}, {
			TextBox = Roact.createElement(RoundTextBox, {
				Active = true,
				MaxLength = MAX_NAME_LENGTH,
				Text = productTitle,
                TextSize = theme.fontStyle.Normal.TextSize,

                SetText = function(name)
                    baseDevProduct.name = tostring(name)
                    setDevProduct(productId, baseDevProduct)
                end
			}),
		}),

        Description = Roact.createElement(TitledFrame, {
			Title = localization:getText("General", "TitleDescription"),
			MaxHeight = 150,
			LayoutOrder = layoutIndex:getNextOrder(),
			TextSize = theme.fontStyle.Normal.TextSize,
		}, {
			TextBox = Roact.createElement(RoundTextBox, {
				Height = 130,
				Multiline = true,

				Active = true,
				MaxLength = MAX_DESCRIPTION_LENGTH,
				Text = productDescripton,
                TextSize = theme.fontStyle.Normal.TextSize,

                SetText = function(description)
                    baseDevProduct.description = tostring(description)
                    setDevProduct(productId, baseDevProduct)
                end
			}),
        }),

        -- TODO: Rename GameIconWidget to IconWidget
        Icon = Roact.createElement(GameIconWidget, {
			Title = localization:getText("Monetization", "ProductIcon"),
			LayoutOrder = layoutIndex:getNextOrder(),
            TutorialEnabled = true,
            Icon = productIcon,
            AddIcon = function()
                local icon = FileUtils.PromptForGameIcon()
                if icon then
                    baseDevProduct.iconImageAssetId = icon
                    setDevProduct(productId, baseDevProduct)
                end
            end,
        }),

        Price = Roact.createElement(TitledFrame, {
			Title = localization:getText("Monetization", "PriceTitle"),
			MaxHeight = 150,
			LayoutOrder = layoutIndex:getNextOrder(),
			TextSize = theme.fontStyle.Normal.TextSize,
		}, {
            --TODO: Change price entry in RobuxFeeBase and this to be a shared component
            PriceFrame = Roact.createElement(RoundFrame, {
                Size = UDim2.new(0, theme.robuxFeeBase.priceField.width, 0, theme.rowHeight),

                BorderSizePixel = 0,
                BackgroundColor3 = theme.textBox.background,

                LayoutOrder = 1,
            },{
                HorizontalLayout = Roact.createElement("UIListLayout",{
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),

                RobuxIcon = Roact.createElement("ImageLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(0, theme.robuxFeeBase.icon.size, 0, theme.robuxFeeBase.icon.size),

                    Image = theme.robuxFeeBase.icon.image,

                    BackgroundTransparency = 1,
                }),

                PriceTextBox = Roact.createElement(TextEntry, Cryo.Dictionary.join(theme.fontStyle.Normal, {
                    Size = UDim2.new(1, -theme.robuxFeeBase.icon.size, 1, 0),
                    Visible = true,

                    Text = productPrice,
                    PlaceholderText = "",
                    Enabled = true,

                    SetText = function(price)
                        baseDevProduct.price = tostring(price)
                        setDevProduct(productId, baseDevProduct)
                    end,

                    FocusChanged = function()
                    end,

                    HoverChanged = function()
                    end,
                }))
            }),
        }),
    }
end

--Uses props to display current settings values
local function displayContents(page, localization, theme)
    local props = page.props

    local editDevProductId = props.EditDevProductId

    if editDevProductId == nil then
	    return displayMonetizationPage(props, localization)
    -- editDevProductId will be 0 for a new Dev Product otherwise will be the id of the Dev Product.
    elseif type(editDevProductId) == "number" then
        return displayEditDevProductsPage(props, localization)
    end
end

local SettingsPage = createSettingsPage(PageName, loadValuesToProps, dispatchChanges)

local function Monetization(props)
	return Roact.createElement(SettingsPage, {
		ContentHeightChanged = props.ContentHeightChanged,
		SetScrollbarEnabled = props.SetScrollbarEnabled,
		LayoutOrder = props.LayoutOrder,
		Content = displayContents,

		AddLayout = true,
	})
end

return Monetization