--[[
    PaidAccess is a wrapper around RadioButtonSet to display a Price config (field for price,
    label for fee, label for actual amount earned) between the "On" and "Off" buttons.

    Necessary props:
        Price = number, the initial price to be shown in the text field.
        Enabled = boolean, whether or not this component is enabled.
        Selected = boolean, "true" if On button should be selected, "false" if the off button should be selected.
        LayoutOrder = number, order in which this component should appear under its parent.
]]

local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Roact)
local Framework = Plugin.Framework
local FitFrameOnAxis = require(Framework.Util).FitFrame.FitFrameOnAxis

local ContextServices = require(Plugin.Framework.ContextServices)

local RadioButtonSet = require(Plugin.Src.Components.RadioButtonSet)
local RobuxFeeBase = require(Plugin.Src.Components.RobuxFeeBase)

local PaidAccess = Roact.PureComponent:extend("PaidAccess")

function PaidAccess:render()
    local props = self.props
    local localization = props.Localization

    local title = localization:getText("Monetization", "TitlePaidAccess")
    local disabledSubText = localization:getText("Monetization", "PaidAccessHint")
    local price = props.Price
    local layoutOrder = props.LayoutOrder

    local enabled = props.Enabled
    local selected = props.Selected

    local buttons = {
        {
            Id = true,
            Title = localization:getText("General", "SettingOn"),
            Children = {
                RobuxFeeBase = Roact.createElement(RobuxFeeBase, {
                    Title = title,
                    Price = price,
                    DisabledSubText = disabledSubText,

                    Enabled = enabled,
                    Selected = selected,
                    SelectionChanged = function()
                    end,
                }),
            },
        },
        {
            Id = false,
            Title = localization:getText("General", "SettingOff"),
        },
    }

    return Roact.createElement(FitFrameOnAxis, {
        axis = FitFrameOnAxis.Axis.Vertical,
        minimumSize = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,

        LayoutOrder = layoutOrder,
    }, {
        OnOffToggle = Roact.createElement(RadioButtonSet, {
            Title = title,

            Buttons = buttons,

            Enabled = true,
            Selected = true,
            SelectionChanged = function()
            end,
        })
    })
end

ContextServices.mapToProps(PaidAccess, {
    Localization = ContextServices.Localization,
})

return PaidAccess