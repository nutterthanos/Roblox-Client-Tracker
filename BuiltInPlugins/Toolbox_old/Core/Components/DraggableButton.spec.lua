return function()
	local Plugin = script.Parent.Parent.Parent

	local Libs = Plugin.Libs
	local Roact = require(Libs.Roact)

	local DraggableButton = require(Plugin.Core.Components.DraggableButton)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(DraggableButton)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
