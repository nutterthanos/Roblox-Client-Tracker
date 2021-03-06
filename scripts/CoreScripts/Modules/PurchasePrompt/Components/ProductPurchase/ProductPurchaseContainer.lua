local Root = script.Parent.Parent.Parent
local GuiService = game:GetService("GuiService")

local CorePackages = game:GetService("CorePackages")
local PurchasePromptDeps = require(CorePackages.PurchasePromptDeps)
local Roact = PurchasePromptDeps.Roact

local UIBlox = PurchasePromptDeps.UIBlox
local InteractiveAlert = UIBlox.App.Dialog.Alert.InteractiveAlert
local ButtonType = UIBlox.App.Button.Enum.ButtonType

local IAPExperience = require(CorePackages.IAPExperience)
local ProductPurchase =  IAPExperience.ProductPurchase
local ProductPurchaseRobuxUpsell =  IAPExperience.ProductPurchaseRobuxUpsell

local RequestType = require(Root.Enums.RequestType)
local PromptState = require(Root.Enums.PromptState)
local WindowState = require(Root.Enums.WindowState)
local PurchaseError = require(Root.Enums.PurchaseError)
local hideWindow = require(Root.Thunks.hideWindow)
local completeRequest = require(Root.Thunks.completeRequest)
local purchaseItem = require(Root.Thunks.purchaseItem)
local launchRobuxUpsell = require(Root.Thunks.launchRobuxUpsell)
local initiatePurchasePrecheck = require(Root.Thunks.initiatePurchasePrecheck)
local connectToStore = require(Root.connectToStore)

local ExternalEventConnection = require(Root.Components.Connection.ExternalEventConnection)
local MultiTextLocalizer = require(Root.Components.Connection.MultiTextLocalizer)
local LocalizationService = require(Root.Localization.LocalizationService)
local getPlayerPrice = require(Root.Utils.getPlayerPrice)

local Animator = require(script.Parent.Animator)

local ProductPurchaseContainer = Roact.Component:extend(script.Name)

local PURCHASE_MESSAGE_KEY = "CoreScripts.PurchasePrompt.PurchaseMessage.%s"

local BUY_ITEM_LOCALE_KEY = "CoreScripts.PurchasePrompt.Title.BuyItem"
local OK_LOCALE_KEY = "CoreScripts.PurchasePrompt.Button.OK"
local ERROR_LOCALE_KEY = "CoreScripts.PremiumModal.Title.Error"

local function isRelevantRequestType(requestType)
	return requestType == RequestType.Asset
		or requestType == RequestType.Bundle
		or requestType == RequestType.GamePass
		or requestType == RequestType.Product
		or requestType == RequestType.Subscription
end

function ProductPurchaseContainer:init()
	self.state = {
		screenSize = Vector2.new(0, 0),
	}

	self.changeScreenSize = function(rbx)
		if self.state.screenSize ~= rbx.AbsoluteSize then
			self:setState({
				screenSize = rbx.AbsoluteSize,
			})
		end
	end
end

function ProductPurchaseContainer:getMessageKeysFromPromptState()
	local promptState = self.props.promptState
	local productInfo = self.props.productInfo
	local purchaseError = self.props.purchaseError

	if promptState == PromptState.PurchaseComplete then
		return {
			messageText = {
				key = PURCHASE_MESSAGE_KEY:format("Succeeded"),
				params = {
					ITEM_NAME = productInfo.name,
				}
			},
			okText = { key = OK_LOCALE_KEY },
			titleText = { key = BUY_ITEM_LOCALE_KEY },
		}
	elseif promptState == PromptState.U13PaymentModal then
		return {
			messageText = { key = "CoreScripts.PurchasePrompt.PurchaseDetails.ScaryModalOne", },
			okText = { key = OK_LOCALE_KEY },
			titleText = { key = BUY_ITEM_LOCALE_KEY },
		}
	elseif promptState == PromptState.U13MonthlyThreshold1Modal then
		return {
			messageText = { key = "CoreScripts.PurchasePrompt.PurchaseDetails.ScaryModalTwo", },
			okText = { key = OK_LOCALE_KEY },
			titleText = { key = BUY_ITEM_LOCALE_KEY },
		}
	elseif promptState == PromptState.U13MonthlyThreshold2Modal then
		return {
			messageText = { key = "CoreScripts.PurchasePrompt.PurchaseDetails.ScaryModalParental", },
			okText = { key = OK_LOCALE_KEY },
			titleText = { key = BUY_ITEM_LOCALE_KEY },
		}
	elseif promptState == PromptState.Error then
		if purchaseError == PurchaseError.UnknownFailure then
			return {
				messageText = { 
					key = LocalizationService.getErrorKey(purchaseError),
					params = {
						ITEM_NAME = productInfo.name
					}
				},
				okText = { key = OK_LOCALE_KEY },
				titleText = { key = ERROR_LOCALE_KEY },
			}
		else
			return {
				messageText = { key = LocalizationService.getErrorKey(purchaseError), },
				okText = { key = OK_LOCALE_KEY },
				titleText = { key = ERROR_LOCALE_KEY },
			}
		end
	end
end

function ProductPurchaseContainer:render()
	local promptState = self.props.promptState
	local requestType = self.props.requestType
	local productInfo = self.props.productInfo
	local accountInfo = self.props.accountInfo
	local nativeUpsell = self.props.nativeUpsell

	local prompt
	if promptState == PromptState.None or not isRelevantRequestType(requestType) then
		--[[
			When the prompt is hidden, we'd rather not keep unused Roblox
			instances for it around, so we don't render them
		]]
		prompt = nil
	elseif promptState == PromptState.PromptPurchase
			or promptState == PromptState.PurchaseInProgress then
		prompt = Roact.createElement(ProductPurchase, {
			screenSize = self.state.screenSize,
		
			isDisabled = promptState == PromptState.PurchaseInProgress,
			itemIcon = productInfo.imageUrl,
			itemName = productInfo.name,
			itemRobuxCost = getPlayerPrice(productInfo, accountInfo.membershipType == 4),
			currentBalance = accountInfo.balance,
		
			buyItemActivated = self.props.onBuy,
			cancelPurchaseActivated = self.props.hideWindow,
		})
	elseif promptState == PromptState.RobuxUpsell
			or promptState == PromptState.UpsellInProgress then
		prompt = Roact.createElement(ProductPurchaseRobuxUpsell, {
			screenSize = self.state.screenSize,
		
			isDisabled = promptState == PromptState.UpsellInProgress,
			itemIcon = productInfo.imageUrl,
			itemName = productInfo.name,
			itemRobuxCost = getPlayerPrice(productInfo, accountInfo.membershipType == 4),
			robuxPurchaseAmount = nativeUpsell.robuxPurchaseAmount,
			balanceAmount = accountInfo.balance,
		
			buyItemActivated = self.props.onRobuxUpsell,
			cancelPurchaseActivated = self.props.hideWindow,
		})
	else
		local onActivated = self.props.hideWindow

		if promptState == PromptState.U13PaymentModal
				or promptState == PromptState.U13MonthlyThreshold1Modal
				or promptState == PromptState.U13MonthlyThreshold2Modal then
			onActivated = self.props.onScaryModalConfirm
		end

		prompt = Roact.createElement(MultiTextLocalizer, {
			keys = self:getMessageKeysFromPromptState(),
			render = function(localeMap)
				return Roact.createElement(InteractiveAlert, {
					bodyText = localeMap.messageText,
					buttonStackInfo = {
						buttons = {
							{
								buttonType = ButtonType.PrimarySystem,
								props = {
									onActivated = onActivated,
									text = localeMap.okText,
								},
							},
						},
					},
					screenSize = self.state.screenSize,
					title = localeMap.titleText,
				})
			end
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		[Roact.Change.AbsoluteSize] = self.changeScreenSize,
		BackgroundTransparency = 1,
	}, {
		Animator = Roact.createElement(Animator, {
			shouldShow = self.props.windowState ~= WindowState.Hidden,
			onHidden = function()
				if self.props.windowState == WindowState.Hidden and isRelevantRequestType(self.props.requestType) then
					self.props.completeRequest()
				end
			end,
		}, {
			Prompt = prompt,
		}),
		OnCoreGuiMenuOpened = Roact.createElement(ExternalEventConnection, {
			event = GuiService.MenuOpened,
			callback = function()
				if self.props.hideWindow then
					self.props.hideWindow()
				end
			end,
		})
	})
end

local function mapStateToProps(state)
	return {
		promptState = state.promptState,
		requestType = state.promptRequest.requestType,
		windowState = state.windowState,
		purchaseError = state.purchaseError,
		productInfo = state.productInfo,
		accountInfo = state.accountInfo,
		nativeUpsell = state.nativeUpsell,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		onBuy = function()
			dispatch(purchaseItem())
		end,
		onScaryModalConfirm = function()
			dispatch(launchRobuxUpsell())
		end,
		onRobuxUpsell = function()
			dispatch(initiatePurchasePrecheck())
		end,
		hideWindow = function()
			dispatch(hideWindow())
		end,
		completeRequest = function()
			dispatch(completeRequest())
		end
	}
end

ProductPurchaseContainer = connectToStore(
	mapStateToProps,
	mapDispatchToProps
)(ProductPurchaseContainer)

return ProductPurchaseContainer
