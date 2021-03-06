return function()
    local Plugin = script.Parent.Parent.Parent
    local Category = require(Plugin.Core.Types.Category)
    local Rollouts = require(Plugin.Core.Rollouts)
    local Urls = require(script.Parent.Urls)

    describe("Toolbox Endpoint Migration Rollout generates correct URLs", function()
        local originalRolloutFunction
        local originalApiNames

        beforeAll(function()
            originalRolloutFunction = Rollouts.getToolboxEndpointMigration

            Rollouts.getToolboxEndpointMigration = function()
                return true
            end

            originalApiNames = Category.API_NAMES
            Category.updateForToolboxEndpointMigrationRollout()
        end)

        afterAll(function()
            Rollouts.getToolboxEndpointMigration = originalRolloutFunction
            Category.API_NAMES = originalApiNames
        end)

        local OWNER_ID = 3
        local EXPECTED_BASE_URL = "https://apis.roblox.com/toolbox-service/v1"

        local function urlForCategory(category)
            return Urls.ToolboxEndpointMigration_constructGetToolboxItemsUrl(category, nil, nil, nil, nil, nil, OWNER_ID, nil, nil, nil, nil)
        end

        local EXPECTED = {
            { Category.FREE_AUDIO,          "/Audio" },
            { Category.WHITELISTED_PLUGINS, "/Plugins" },
            { Category.FREE_MESHES,         "/Meshes" },
            { Category.FREE_DECALS,         "/Decals" },
            { Category.MARKETPLACE_VIDEOS,  "/Videos" },
            { Category.FREE_MODELS,         "/Models" },

            { Category.MY_AUDIO,            ("/inventory/user/%d/audio"):format(OWNER_ID) },
            { Category.MY_PLUGINS,          ("/inventory/user/%d/plugin"):format(OWNER_ID) },
            { Category.MY_MODELS,           ("/inventory/user/%d/model"):format(OWNER_ID) },
            { Category.MY_MESHES,           ("/inventory/user/%d/meshpart"):format(OWNER_ID) },
            { Category.MY_DECALS,           ("/inventory/user/%d/decal"):format(OWNER_ID) },
            { Category.MY_VIDEOS,           ("/inventory/user/%d/video"):format(OWNER_ID) },
            { Category.MY_PACKAGES,         ("/inventory/user/%d/package"):format(OWNER_ID) },

            { Category.RECENT_AUDIO,        ("/recent/user/%d/audio"):format(OWNER_ID) },
            { Category.RECENT_MODELS,       ("/recent/user/%d/model"):format(OWNER_ID) },
            { Category.RECENT_MESHES,       ("/recent/user/%d/meshpart"):format(OWNER_ID) },
            { Category.RECENT_DECALS,       ("/recent/user/%d/decal"):format(OWNER_ID) },
            { Category.RECENT_VIDEO,        ("/recent/user/%d/video"):format(OWNER_ID) },
        }

        for _, item in ipairs(EXPECTED) do
            local category = item[1]
            local expectedPath = item[2]

            it(string.format("for getting %s", category.name), function()
                local expectedUrl = string.format("%s%s?", EXPECTED_BASE_URL, expectedPath)
                expect(urlForCategory(category.name)).to.equal(expectedUrl)
            end)
        end

        it("for inserts", function()
            expect(Urls.constructInsertAssetUrl(123)).to.equal(string.format("%s/insert/asset/123", EXPECTED_BASE_URL))
        end)

    end)

end