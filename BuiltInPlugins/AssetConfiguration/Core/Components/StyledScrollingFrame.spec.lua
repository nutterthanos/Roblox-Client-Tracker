return function()
	local Plugin = script.Parent.Parent.Parent

	local Libs = Plugin.Libs
	local Roact = require(Libs.Roact)

	local MockWrapper = require(Plugin.Core.Util.MockWrapper)

	local StyledScrollingFrame = require(Plugin.Core.Components.StyledScrollingFrame)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(MockWrapper, {}, {
			StyledScrollingFrame = Roact.createElement(StyledScrollingFrame),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
