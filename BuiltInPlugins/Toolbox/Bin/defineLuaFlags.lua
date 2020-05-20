-- Lua flag definitions should go in this file so that they can be used by both main and runTests
-- If the flags are defined in main, then it's possible for the tests run first
-- And then error when trying to use flags that aren't yet defined

game:DefineFastFlag("RemoveNilInstances", false)
game:DefineFastFlag("UseRBXThumbInToolbox", false)
game:DefineFastFlag("EnableAssetConfigVersionCheckForModels", false)
game:DefineFastFlag("FixAssetConfigManageableGroups", false)
game:DefineFastFlag("ShowAssetConfigReasons2", false)
game:DefineFastFlag("DebugAssetConfigNetworkError", false)
game:DefineFastFlag("FixAssetConfigIcon", false)
game:DefineFastFlag("EnableAssetConfigFreeFix2", false)

-- when removing this flag, remove all references to isCatalogItemCreator
game:DefineFastFlag("EnableNonWhitelistedToggle", false)
game:DefineFastFlag("CMSTabErrorIcon", false)
game:DefineFastFlag("EnablePurchaseV2", false)
game:DefineFastFlag("CMSConsolidateAssetTypeInfo", false)
game:DefineFastFlag("EnableDefaultSortFix2", false)
game:DefineFastFlag("EnableOverrideAssetCursorFix", false)
game:DefineFastFlag("EnableOverrideAssetGroupCreationApi", false)
game:DefineFastFlag("FixAssetUploadName", false)
game:DefineFastFlag("EnableSearchedWithoutInsertionAnalytic", false)
game:DefineFastFlag("UseCategoryNameInToolbox", false)
-- Need to explicitly return something from a module
-- Else you get an error "Module code did not return exactly one value"

game:DefineFastFlag("EnableToolboxAssetNameColorChange", false)
game:DefineFastFlag("RemoveAudioEndorsedIcon", false)

game:DefineFastFlag("StudioToolboxEnabledDevFramework", false)
game:DefineFastFlag("EnableToolboxImpressionAnalytics", false)

game:DefineFastFlag("AssetConfigDarkerScrollBar", false)
game:DefineFastFlag("AssetConfigUseItemConfig", false)
game:DefineFastFlag("EnableToolboxVideos", false)

game:DefineFastFlag("CMSPremiumBenefitsLink", false)
game:DefineFastFlag("CMSFixAssetPreviewForThumbnailConfig", false)

game:DefineFastFlag("ToolboxUseNewAssetType", false)

game:DefineFastFlag("StudioToolboxSearchOverflowFix", false)

game:DefineFastFlag("StudioFixComparePageInfo", false)

return nil
