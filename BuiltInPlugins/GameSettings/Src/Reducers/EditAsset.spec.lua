local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)
local Rodux = require(Plugin.Packages.Rodux)

local EditAsset = require(script.parent.EditAsset)

local SetEditPlaceId = require(Plugin.Src.Actions.SetEditPlaceId)

local testImmutability = require(Plugin.Src.Util.testImmutability)

return function()
	it("should return a table with the correct members", function()
		local state = EditAsset(nil, {})

		expect(type(state)).to.equal("table")
		expect(state.editingPlaceId).to.ok()
	end)

	describe("SetEditPlaceId action", function()
		it("should validate its inputs", function()
			expect(function()
				SetEditPlaceId("yeet")
			end).to.throw()

			expect(function()
				SetEditPlaceId(Cryo.None)
			end).to.throw()

			expect(function()
				SetEditPlaceId({ id = true, })
			end).to.throw()

			expect(function()
				SetEditPlaceId({})
			end).to.throw()
		end)

		it("should not mutate the state", function()
			local immutabilityPreserved = testImmutability(EditAsset, SetEditPlaceId(1337))
			expect(immutabilityPreserved).to.equal(true)
		end)

		it("should set places", function()
			local r = Rodux.Store.new(EditAsset)
			local state = r:getState()
			expect(state.editingPlaceId).to.equal(0)

			state = EditAsset(state, SetEditPlaceId(1337))
			expect(#state.editingPlaceId).to.equal(1337)

			state = EditAsset(state, SetEditPlaceId(0))
			expect(state.editingPlaceId).to.equal(0)
		end)
	end)

end