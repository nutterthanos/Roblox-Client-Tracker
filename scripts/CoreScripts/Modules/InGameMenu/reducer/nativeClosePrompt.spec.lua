return function()
	local InGameMenu = script.Parent.Parent
	local OpenNativeClosePrompt = require(InGameMenu.Actions.OpenNativeClosePrompt)
	local CloseNativeClosePrompt = require(InGameMenu.Actions.CloseNativeClosePrompt)
	local nativeClosePrompt = require(script.Parent.nativeClosePrompt)

	it("should be closed by default", function()
		local defaultState = nativeClosePrompt(nil, {})
		expect(defaultState.closingApp).to.equal(false)
	end)

	describe("OpenNativeClosePrompt", function()
		it("should set the popup dialog open", function()
			local oldState = nativeClosePrompt(nil, {})
			local newState = nativeClosePrompt(oldState, OpenNativeClosePrompt())
			expect(oldState).to.never.equal(newState)
			expect(newState.closingApp).to.equal(true)
		end)
	end)

	describe("CloseNativeClosePrompt", function()
		it("should set the report dialog closed", function()
			local oldState = nativeClosePrompt(nil, {})
			oldState = nativeClosePrompt(oldState, OpenNativeClosePrompt())
			local newState = nativeClosePrompt(oldState, CloseNativeClosePrompt())
			expect(oldState).to.never.equal(newState)
			expect(newState.closingApp).to.equal(false)
		end)
	end)
end
