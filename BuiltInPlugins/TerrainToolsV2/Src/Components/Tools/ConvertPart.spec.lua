local Plugin = script.Parent.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local MockProvider = require(Plugin.Src.TestHelpers.MockProvider)

local ConvertPart = require(script.Parent.ConvertPart)

return function()
	it("should create and destroy without errors", function()
		local element = MockProvider.createElementWithMockContext(ConvertPart)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
