local FFlagTerrainToolsUseDevFramework = game:GetFastFlag("TerrainToolsUseDevFramework")

local Plugin = script.Parent.Parent.Parent

local Framework = require(Plugin.Packages.Framework)
local Cryo = require(Plugin.Packages.Cryo)
local Roact = require(Plugin.Packages.Roact)
local UILibrary = not FFlagTerrainToolsUseDevFramework and require(Plugin.Packages.UILibrary) or nil

local ContextItem = FFlagTerrainToolsUseDevFramework and Framework.ContextServices.ContextItem or nil
local Provider = FFlagTerrainToolsUseDevFramework and Framework.ContextServices.Provider or nil

local FrameworkUtil = FFlagTerrainToolsUseDevFramework and Framework.Util or nil
local Signal = FFlagTerrainToolsUseDevFramework and FrameworkUtil.Signal or UILibrary.Util.Signal

local Constants = require(Plugin.Src.Util.Constants)

local makeTerrainGenerator = require(script.Parent.makeTerrainGenerator)

local DEBUG_LOG_WORK_TIME = false

local TerrainGeneration
if FFlagTerrainToolsUseDevFramework then
	TerrainGeneration = ContextItem:extend("TerrainGeneration")
else
	TerrainGeneration = {}
	TerrainGeneration.__index = TerrainGeneration
end

function TerrainGeneration.new(options)
	assert(options and type(options) == "table", "TerrainGeneration requires an options table")

	local self = setmetatable({
		_terrain = options.terrain,
		_localization = options.localization,
		_analytics = options.analytics,

		_generateSettings = {
			position = Vector3.new(0, 0, 0),
			size = Vector3.new(0, 0, 0),
			biomeSelection = {},
			biomeSize = 0,
			haveCaves = false,
			seed = "0",
		},

		-- True once start() is called and we've created a generator
		-- False once we're done with the generator
		-- Does not indicate whether the generator is actively running or if we're paused
		_generating = false,
		_generateStartTime = 0,

		-- Generator instance that actually does the terrain generating
		_generator = nil,
		-- Our connections to signals from the generator
		_generatorProgressConnection = nil,
		_generatorPausedConnection = nil,
		_generatorFinishedConnection = nil,
	}, TerrainGeneration)

	assert(self._terrain, "TerrainGeneration.new() requires a terrain instance")

	if FFlagTerrainToolsUseDevFramework then
		self._updateSignal = Signal.new()
	else
		self._generatingStateChangedSignal = Signal.new()
		self._generatingProgressUpdateSignal = Signal.new()
		self._generatingPausedSignal = Signal.new()
	end

	-- These functions are connected to the signals from the generator
	self._onGeneratorProgressUpdate = function(progress)
		if FFlagTerrainToolsUseDevFramework then
			self._updateSignal:Fire()
		else
			-- Pass the progress on to our subscribers
			self._generatingProgressUpdateSignal:Fire(progress)
		end
	end

	self._onGeneratorPaused = function(paused)
		if FFlagTerrainToolsUseDevFramework then
			self._updateSignal:Fire()
		else
			-- Pass the paused update on to our subscribers
			self._generatingPausedSignal:Fire(paused)
		end
	end

	self._onGeneratorFinished = function()
		local endTime = tick()
		local totalTime = endTime - self._generateStartTime
		print(self._localization:getText("Generate", "GenerationFinished", totalTime))

		if DEBUG_LOG_WORK_TIME then
			local yieldTime = self._generator.getYieldTime()
			local workTime = totalTime - yieldTime
			print(("Yielded for %.2f seconds; Did work for %.2f"):format(yieldTime, workTime))
		end

		-- Before killing our generator
		self:_stopAndClearGenerator()
	end

	return self
end

if FFlagTerrainToolsUseDevFramework then
	function TerrainGeneration:createProvider(root)
		return Roact.createElement(Provider, {
			ContextItem = self,
			UpdateSignal = self._updateSignal,
		}, {root})
	end
end

function TerrainGeneration:subscribeToStartStopGeneratingChanged(...)
	assert(not FFlagTerrainToolsUseDevFramework, "TerrainGeneration:subscribeToStartStopGeneratingChanged() is deprecated")
	return self._generatingStateChangedSignal:Connect(...)
end

function TerrainGeneration:subscribeToProgressUpdate(...)
	assert(not FFlagTerrainToolsUseDevFramework, "TerrainGeneration:subscribeToProgressUpdate() is deprecated")
	return self._generatingProgressUpdateSignal:Connect(...)
end

function TerrainGeneration:subscribeToPaused(...)
	assert(not FFlagTerrainToolsUseDevFramework, "TerrainGeneration:subscribeToPaused() is deprecated")
	return self._generatingPausedSignal:Connect(...)
end

function TerrainGeneration:isGenerating()
	return self._generating
end

function TerrainGeneration:getProgress()
	return self._generator and self._generator.getProgress() or 0
end

function TerrainGeneration:isPaused()
	if self._generator then
		return self._generator.isPaused()
	end
	return false
end

-- Updates terrain generation settings with new values
-- Does not modify an in-progress generation
-- Only saves these for the next generation
function TerrainGeneration:updateSettings(newSettings)
	self._generateSettings = Cryo.Dictionary.join(self._generateSettings, newSettings)
end

function TerrainGeneration:destroy()
	-- TerrainGeneration is going away so tell our generator to stop
	self:cancelGeneration()
end

function TerrainGeneration:startGeneration()
	if self._generating or self._generator then
		return
	end

	self:_setGenerating(true)

	local position = self._generateSettings.position
	local size = self._generateSettings.size
	local seed = self._generateSettings.seed
	local biomes = self._generateSettings.biomeSelection

	-- Position and size from generateSettings are dictionaries, so turn them into Vector3s
	local positionV3 = Vector3.new(position.X, position.Y, position.Z)
	local sizeV3 = Vector3.new(size.X, size.Y, size.Z)

	-- Biome selection is a table, so copy it before sending to the generator
	local biomesCopy = Cryo.Dictionary.join(biomes, {})

	local localizedBiomes = {}
	for biome, selected in pairs(biomes) do
		if selected then
			table.insert(localizedBiomes, self._localization:getText("Generate", Constants.BiomeToLocalizationKey[biome]))
		end
	end
	local biomesStr = table.concat(localizedBiomes, ", ")

	print(self._localization:getText("Generate", "StartGeneration",
		tostring(sizeV3), tostring(positionV3), tostring(seed), biomesStr
	))

	-- Copy the generate settings table in case it is modified whilst we are generating
	self._generator = makeTerrainGenerator(self._terrain, {
		position = positionV3,
		size = sizeV3,
		biomeSelection = biomesCopy,
		biomeSize = self._generateSettings.biomeSize,
		haveCaves = self._generateSettings.haveCaves,
		seed = seed,
	}, self._analytics)

	-- Start listening to what the generator is doing
	self._generatorProgressConnection = self._generator.progressSignal:Connect(self._onGeneratorProgressUpdate)
	self._generatorPausedConnection = self._generator.pauseSignal:Connect(self._onGeneratorPaused)
	self._generatorFinishedConnection = self._generator.finishSignal:Connect(self._onGeneratorFinished)

	-- Record how long the generation takes
	self._generateStartTime = tick()

	-- Run the generator on a different thread
	spawn(self._generator.start)
end

function TerrainGeneration:togglePauseGeneration()
	if not self._generator then
		return
	end

	if self._generator.isPaused() then
		self._generator.resume()
	else
		self._generator.pause()
	end
end

function TerrainGeneration:cancelGeneration()
	if not self._generator then
		return
	end

	self._generator.cancel()
end

function TerrainGeneration:_setGenerating(generating)
	if generating ~= self._generating then
		self._generating = generating

		if FFlagTerrainToolsUseDevFramework then
			self._updateSignal:Fire()
		else
			self._generatingStateChangedSignal:Fire(generating)
		end
	end
end

function TerrainGeneration:_stopAndClearGenerator()
	if self._generatorProgressConnection then
		self._generatorProgressConnection:Disconnect()
		self._generatorProgressConnection = nil
	end

	if self._generatorPausedConnection then
		self._generatorPausedConnection:Disconnect()
		self._generatorPausedConnection = nil
	end

	if self._generatorFinishedConnection then
		self._generatorFinishedConnection:Disconnect()
		self._generatorFinishedConnection = nil
	end

	self._generator = nil
	self:_setGenerating(false)
end

return TerrainGeneration
