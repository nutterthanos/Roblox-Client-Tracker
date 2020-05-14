local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)

local provideMockContextForGameSettings = require(Plugin.Src.Components.provideMockContextForGameSettings)

local VIPServers = require(Plugin.Src.Components.VIPServers)

return function()
    it("should construct and destroy without errors", function()
        local VIPServers = provideMockContextForGameSettings(nil, {
            element = Roact.createElement(VIPServers, {
            Title = "VIP Servers",
            Price = 200,
            DisabledSubText = "Mutually exclusive with Paid Access",

            LayoutOrder = 1,
            Enabled = true,
            Selected = true,
            SelectionChanged = function()
            end,
        })})

        local handle = Roact.mount(VIPServers)
        expect(VIPServers).to.be.ok()
        expect(handle).to.be.ok()
        Roact.unmount(handle)
    end)
end