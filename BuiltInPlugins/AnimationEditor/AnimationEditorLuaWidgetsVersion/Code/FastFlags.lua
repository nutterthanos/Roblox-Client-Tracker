-- singleton

local FastFlags = {}

FastFlags.FlagExists = {}
FastFlags.FlagValue = {}

local function isFlagOn(theFlag)
	if nil == FastFlags.FlagExists[theFlag] then
		local status, result = pcall(function () return settings():GetFFlag(theFlag) end)
		FastFlags.FlagExists[theFlag] = status
		if status then
			FastFlags.FlagValue[theFlag] = result
		end
	end
	return FastFlags.FlagExists[theFlag] and FastFlags.FlagValue[theFlag]
end

function FastFlags:isUsePluginBindToCloseOn()
	return isFlagOn("StudioAnimationEditorUsePluginBindToClose")
end

function FastFlags:isRightClickAddKeyFixOn()
	return isFlagOn("StudioAnimationEditorRightClickAddKeyFix")
end

function FastFlags:isPartIncludeFixOn()
	return isFlagOn("StudioAnimationEditorPartIncludeFix")
end

function FastFlags:isFixRenameKeyOptionOn()
	return isFlagOn("StudioAnimationEditorFixRenameKeyOption")
end

function FastFlags:isUseNewThemeAPIOn()
	return isFlagOn("StudioAnimationEditorUseNewThemeAPIV2")
end

function FastFlags:isUseAnimationNameAsTitleOn()
	return isFlagOn("StudioAnimationEditorUseAnimationNameAsTitle")
end

function FastFlags:isIKModeFlagOn()
	return isFlagOn("StudioAnimationEditorIKMode") and self:isScaleKeysOn()
end

function FastFlags:isScaleKeysOn()
	return isFlagOn("StudioAnimationEditorScaleKeys")
end

function FastFlags:isDebugStudioRigImporterFlagOn()
	return isFlagOn("DebugStudioRigImporter")
end

function FastFlags:isUseDevHubHelpLinksOn()
	return isFlagOn("StudioAnimationEditorUseDevHubHelpLinks")
end

function FastFlags:isFixResetJointOn()
	return isFlagOn("StudioAnimationEditorFixResetJoint")
end

function FastFlags:isImportAndExportFixOn()
	return isFlagOn("StudioAnimationEditorImportAndExportFix")
end

function FastFlags:isAutoAddBeginningKeyframeOn()
	return isFlagOn("StudioAnimationEditorAutoAddBeginningKeyframe")
end

function FastFlags:isUseRigNameForPromptsOn()
	return isFlagOn("StudioAnimationEditorUseRigNameForPrompts")
end

function FastFlags:isSelectAndDragOn()
	return isFlagOn("StudioAnimationEditorSelectAndDrag")
end

function FastFlags:isLockedPartStaysAnimatableOn()
	return isFlagOn("StudioAnimationEditorLockedPartStaysAnimatable")
end

function FastFlags:clearIKOnNew()
	return isFlagOn("StudioAnimationEditorFixClearIKOnNew")
end

return FastFlags