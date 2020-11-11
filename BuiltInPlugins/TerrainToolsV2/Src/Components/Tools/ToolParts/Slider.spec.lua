local Plugin = script.Parent.Parent.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local MockProvider = require(Plugin.Src.TestHelpers.MockProvider)

local Slider = require(script.Parent.Slider)

return function()
	it("should create and destroy without errors", function()
		local element = MockProvider.createElementWithMockContext(Slider)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
