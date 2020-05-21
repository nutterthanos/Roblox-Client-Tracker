-- Lua flag definitions should go in this file so that they can be used by both main and runTests
-- If the flags are defined in main, then it's possible for the tests run first
-- And then error when trying to use flags that aren't yet defined

game:DefineFastFlag("AvatarSizeFixForReorganizeHeaders", false)
game:DefineFastFlag("StudioLocalizationInGameSettingsEnabled", false)
game:DefineFastFlag("StudioConvertGameSettingsToDevFramework", false)
game:DefineFastFlag("StudioGameSettingsResetStoreAction2", false)
game:DefineFastFlag("StudioStandaloneGameMetadata", false)

return nil
