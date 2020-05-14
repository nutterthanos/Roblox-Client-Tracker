local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Roact)

local provideMockContextForGameSettings = require(Plugin.Src.Components.provideMockContextForGameSettings)

local Monetization = require(Plugin.Src.Components.SettingsPages.Monetization)

return function()
    it("should construct and destroy without any errors", function()
        local element = provideMockContextForGameSettings(nil , {
            MonetizationPage = Roact.createElement((Monetization))
        })

        local handle = Roact.mount(element)
        expect(element).to.be.ok()
        expect(handle).to.be.ok()
        Roact.unmount(handle)
    end)
end