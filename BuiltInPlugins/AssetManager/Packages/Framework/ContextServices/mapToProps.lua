--[[
	Wraps an existing Roact component to map context items to props.
	Using this function allows easy pulling of items, such as
	Theme and Localization, from context.

	This function must be called after the render function of the
	component is defined. Otherwise it will throw an error.

	Parameters:
		Component component = The component to wrap.
		table<string><ContextItem> ContextMap:
			This table is used to pull items from context
			and insert them into the props of the component by name.

	Example:
		local ContextServices = require(Framework.ContextServices)
		local MyComponent = Roact.PureComponent:extend("MyComponent")

		MyComponent:render()
			local props = self.props
			local theme = props.Theme
			local localization = props.Localization
			...
		end

		ContextServices.mapToProps(MyComponent, {
			Theme = ContextServices.Theme,
			Localization = ContextServices.Localization,
		})
]]

local missingRenderMessage = [[
The Component %q is missing the `render` method.
`mapToProps` must be called after `render` is defined!]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Consumer = require(Framework.ContextServices.Consumer)

local function mapToProps(component, contextMap)
	assert(component.render ~= Roact.Component.render,
		string.format(missingRenderMessage, tostring(component)))
	assert(contextMap, "mapToProps expects a contextMap table.")

	local __initWithContext = component.init
	component.__renderWithContext = component.render

	function component:init(props)
		for key, item in pairs(contextMap) do
			if item.initConsumer then
				item:initConsumer(self)
			end
		end
		if __initWithContext then
			__initWithContext(self, props)
		end
	end

	function component:render()
		return Roact.createElement(Consumer, {
			ContextMap = contextMap,
			Render = function(items)
				if items then
					for key, item in pairs(items) do
						if item.getConsumerItem then
							self.props[key] = item:getConsumerItem(self)
						else
							self.props[key] = item
						end
					end
				end
				return self:__renderWithContext()
			end,
		})
	end
end

return mapToProps