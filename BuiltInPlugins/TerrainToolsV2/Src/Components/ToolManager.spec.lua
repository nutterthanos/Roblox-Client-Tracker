local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local MockProvider = require(Plugin.Src.TestHelpers.MockProvider)

local ToolManager = require(script.Parent.ToolManager)

return function()
	it("should create and destroy without errors", function()
		local element = MockProvider.createElementWithMockContext(ToolManager)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
