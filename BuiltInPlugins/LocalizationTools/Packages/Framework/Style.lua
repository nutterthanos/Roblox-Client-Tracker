local strict = require(script.Parent.Util.strict)

return strict({
	Colors = require(script.Colors),
	ComponentSymbols = require(script.ComponentSymbols),
	createDefaultTheme =  require(script.createDefaultTheme),
	getRawComponentStyle = require(script.getRawComponentStyle),
	StyleKey = require(script.StyleKey),
	Stylizer = require(script.Stylizer),

	Themes = strict({
		BaseTheme = require(script.Themes.BaseTheme),
		DarkTheme = require(script.Themes.DarkTheme),
		LightTheme = require(script.Themes.LightTheme),
		StudioTheme = require(script.Themes.StudioTheme),
	})
})