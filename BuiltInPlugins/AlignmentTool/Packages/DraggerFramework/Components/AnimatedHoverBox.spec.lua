return function()
	local Framework = script.Parent.Parent
	local Library = Framework.Parent.Parent

	local Roact = require(Library.Packages.Roact)

	local AnimatedHoverBox = require(Framework.Components.AnimatedHoverBox)

	local function createTestHoverBox(hoverTarget)
		hoverTarget = hoverTarget or Instance.new("Part")
		return Roact.createElement(AnimatedHoverBox, {
			hoverTarget = hoverTarget,
		})
	end

	it("should error if HoverTarget not provided", function()
		local element = Roact.createElement(AnimatedHoverBox, {})

		expect(function()
			local handle = Roact.mount(element)
			Roact.unmount(handle)
		end).to.throw()
	end)

	it("should create and destroy without errors", function()
		local element = createTestHoverBox()

		expect(function()
			local handle = Roact.mount(element)
			Roact.unmount(handle)
		end).to.never.throw()
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local hoverTarget = Instance.new("Part")
		local element = createTestHoverBox(hoverTarget)
		local handle = Roact.mount(element, container)

		local selectionBox = container:FindFirstChildOfClass("SelectionBox")
		-- Cleanup before testing expectation, so AnimatedHoverBox can unbind
		-- its render step function.
		Roact.unmount(handle)

		expect(selectionBox).to.be.ok()
		expect(selectionBox.Adornee).to.equal(hoverTarget)
	end)
end
