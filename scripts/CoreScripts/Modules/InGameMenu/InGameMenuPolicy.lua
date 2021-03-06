local CorePackages = game:GetService("CorePackages")
local InGameMenuDependencies = require(CorePackages.InGameMenuDependencies)
local PolicyProvider = InGameMenuDependencies.PolicyProvider

local implementation = PolicyProvider.GetPolicyImplementations.MemStorageService("app-policy")
local InGameMenuPolicy = PolicyProvider.withGetPolicyImplementation(implementation)

local GetFIntEducationalPopupDisplayMaxCount = require(
	script.Parent.Parent.Flags.GetFIntEducationalPopupDisplayMaxCount)

InGameMenuPolicy.Mapper = function(policy)
	local UniversalAppOnWindows = game:GetEngineFeature("UniversalAppOnWindows")
	return {
		enableInGameHomeIcon = function()
			return UniversalAppOnWindows
		end,

		enableEducationalPopup = function()
			local isNativeCloseIntercept = game:GetEngineFeature("NativeCloseIntercept")
			if UniversalAppOnWindows and isNativeCloseIntercept then
				return true
			end
			return false
		end,

		educationalPopupMaxDisplayCount = function()
			return UniversalAppOnWindows and GetFIntEducationalPopupDisplayMaxCount() or 0
		end,

		enableFullscreenTitleBar = function()
			if UniversalAppOnWindows then
				return true
			end
			return false
		end,
	}
end

return InGameMenuPolicy
