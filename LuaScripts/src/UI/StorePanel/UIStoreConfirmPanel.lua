require("UI.StorePanel.Item.UIStoreRobotAttItem")
require("UI.StoreExchangePanel.UIStoreExchangePanel")
require("UI.StoreExchangePanel.UIStoreGlobal")
require("UI.StorePanel.UIStoreMainPanel")
require("UI.Common.UICommonItem")
require("UI.UIBasePanel")
require("UI.StorePanel.Item.UIStoreExchangePriceInfoItem")
UIStoreConfirmPanel = class("UIStoreConfirmPanel", UIBasePanel)
UIStoreConfirmPanel.__index = UIStoreConfirmPanel
UIStoreConfirmPanel.mView = nil
UIStoreConfirmPanel.mRoot = nil
UIStoreConfirmPanel.mData = nil
UIStoreConfirmPanel.mGoodsAmountInputField = nil
UIStoreConfirmPanel.mMaxNumPerPurchase = 999
UIStoreConfirmPanel.MAX_PURCHASE_AMOUNT = 999
UIStoreConfirmPanel.REAL_MONEY_ID = 0
UIStoreConfirmPanel.GUN_CORE_ID = 10
UIStoreConfirmPanel.CHIP_CORE_ID = 302
UIStoreConfirmPanel.GUILD_COIN_ID = 303
UIStoreConfirmPanel.GUILD_RESOURCE_ID = 304
UIStoreConfirmPanel.mCurCurrencyId = 1
UIStoreConfirmPanel.mCurBuyNum = 0
UIStoreConfirmPanel.mItemReward = nil
UIStoreConfirmPanel.mIsFristBuy = false
UIStoreConfirmPanel.mNeedCheckRepository = false
UIStoreConfirmPanel.mIsSlider = false
UIStoreConfirmPanel.itemView = nil
UIStoreConfirmPanel.ColorGreen = Color(0.5607843137254902, 0.8, 0.0784313725490196)
UIStoreConfirmPanel.ColorBlack = ColorUtils.StringToColor("325563")
function UIStoreConfirmPanel:ctor(csPanel)
  UIStoreConfirmPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.csPanel = csPanel
  csPanel.UsePool = false
end
function UIStoreConfirmPanel:OnInit(root, data)
  UIStoreConfirmPanel.super.SetRoot(UIStoreConfirmPanel, root)
  self = UIStoreConfirmPanel
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.callBack = nil
  self.RobotDetalList = {}
  self.mRoot = root
  if type(data) == "table" then
    self.mData = data.data
    self.parent = data.parent
    self.callBack = data.callBack
  else
    self.mData = data
  end
  setactive(self.ui.mBtn_Buy, true)
  setactive(self.ui.mBtn_Cancel, true)
  setactive(self.ui.mTrans_MoneyNum, false)
  setactive(self.ui.mTrans_ItemBoxList, false)
  setactive(self.ui.mTrans_GrpTextLeft, false)
  setactive(self.ui.mTrans_PurchaseQuantity, true)
  setactive(self.ui.mTrans_GrpPriceDetails, false)
  setactive(self.ui.mBtn_DetailInfo.gameObject, false)
  setactive(self.ui.mTrans_MacineAttribute, false)
  setactive(self.ui.mBtn_RobotInfo, false)
  setactive(self.ui.mTrans_RobotBg, false)
  setactive(self.ui.mTrans_Att, false)
  self.ui.mScroll_Des.verticalNormalizedPosition = 1
  if self.mData.price == "0" then
    self.ui.mText_CreditNum.text = TableData.GetHintById(901056) or self.mData.price
    setactive(self.ui.mImg_CreditIcon.transform.parent, false)
  else
    setactive(self.ui.mImg_CreditIcon.transform.parent, true)
    self.ui.mText_CreditNum.text = self.mData.price
  end
  setactive(self.ui.mTrans_CreditNum, self.mData.price_type ~= 0)
  self:InitData(self.mData, self.mData.price_type)
  if data.isShowCreditNum == false then
    setactive(self.ui.mTrans_CreditNum, false)
  end
end
function UIStoreConfirmPanel:InitData(data, currencyId)
  self.mCurBuyAmount = 1
  self.mCurCurrencyId = currencyId
  self.OnBuySuccessCallback = successHandler
  self.ui.mText_ItemName.text = data.name
  if data.buy_times == 0 and data.price_type == 0 then
    self.ui.mText_Description.text = data.first_buy_description.str
  else
    self.ui.mText_Description.text = data.description
  end
  local rewards = data.ItemNumList
  self.mItemReward = data.ItemNumList
  self.ui.mText_AmountText.text = self.mCurBuyAmount
  self.ui.mText_Price.text = string_format("{0}", formatnum(self.mCurBuyAmount * self.mData.price))
  local stcData = TableData.GetItemData(data.frame, true)
  self.itemView = UICommonItem.New()
  self.itemView:InitCtrl(self.ui.mTrans_Item.transform)
  if data.icon ~= "" then
    local iconSprite = IconUtils.GetItemIcon(data.icon)
    local itemId = self.mData.ItemNumList[0].itemid
    self.itemView:SetRankAndIconData(data.rank, iconSprite, itemId, nil, self.ui.mBtn_StoreDetail)
  elseif data.frame ~= 0 and stcData ~= nil and stcData.type == 25 then
    local costItemNum = NetCmdItemData:GetItemCountById(data.frame)
    self.itemView:SetByItemData(stcData, nil, false, self.ui.mBtn_StoreDetail)
  elseif data.frame ~= 0 and stcData ~= nil then
    self.itemView:SetByItemData(stcData, nil, false, self.ui.mBtn_StoreDetail)
  else
    local itemData = TableData.GetItemData(data.ItemNumList[0].itemid)
    if itemData ~= nil then
      self.itemView:SetByItemData(itemData, nil, false, self.ui.mBtn_StoreDetail)
    end
  end
  setactive(self.ui.mTrans_AttackType, false)
  if data.frame ~= 0 and stcData ~= nil and stcData.Type == 25 then
    setactive(self.ui.mTrans_AttackType.gameObject, true)
    local supplyData = TableData.listSupplyDatas:GetDataById(data.frame)
    local elementData = TableData.listLanguageElementDatas:GetDataById(supplyData.Type)
    self.ui.mText_AttackType.text = elementData.name.str
  end
  local buttons = getComponentsInChildren(self.ui.mTrans_Item.transform, typeof(CS.UnityEngine.UI.Button))
  for i = 0, buttons.Length - 1 do
    buttons[i].enabled = false
  end
  if 0 < data.price_type then
    local stcData = TableData.GetItemData(data.price_type)
    self.ui.mImage_GoldIcon.sprite = UIUtils.GetIconSprite("Icon/Item", stcData.icon)
    self.ui.mImg_CreditIcon.sprite = UIUtils.GetIconSprite("Icon/Item", stcData.icon)
  end
  if self.mCurCurrencyId ~= self.REAL_MONEY_ID then
    local currency = self:GetCurrencyAmount()
    local div = currency / data.price
    self.mMaxNumPerPurchase = math.floor(div)
  end
  if self.mMaxNumPerPurchase > self.MAX_PURCHASE_AMOUNT then
    self.mMaxNumPerPurchase = self.MAX_PURCHASE_AMOUNT
  end
  if data.IsMultiPrice then
    if self.mMaxNumPerPurchase > data.multi_prize_remain_times and data.multi_prize_remain_times ~= 0 then
      self.mMaxNumPerPurchase = data.multi_prize_remain_times
    end
  elseif self.mMaxNumPerPurchase > data.remain_times and data.remain_times ~= 0 then
    self.mMaxNumPerPurchase = data.remain_times
  end
  local itemBtn1 = UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject)
  function itemBtn1.onClick(o)
    self:OnBuyClicked(o)
  end
  itemBtn1.param = self
  itemBtn1.paramData = data
  local itemBtn2 = UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject)
  itemBtn2.onClick = self.OnCancelClicked
  itemBtn2.param = self
  itemBtn2.paramData = nil
  local itemCloseBtn = UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject)
  itemCloseBtn.onClick = self.OnCloseClicked
  itemCloseBtn.param = self
  itemCloseBtn.paramData = nil
  local itemExitBtn = UIUtils.GetButtonListener(self.ui.mBtn_Exit.gameObject)
  itemExitBtn.onClick = self.OnCancelClicked
  itemExitBtn.param = self
  itemExitBtn.paramData = nil
  local itemCloseBtn = UIUtils.GetButtonListener(self.ui.mBtn_DetailInfo.gameObject)
  itemCloseBtn.onClick = self.OnCloseClicked
  itemCloseBtn.param = self
  itemCloseBtn.paramData = nil
  UIUtils.GetListener(self.ui.mBtn_StoreDetail.gameObject).onClick = self.ShowStoreDetails
  self.ui.mSlider_Item.onValueChanged:AddListener(function(value)
    self:OnSliderChange(value)
  end)
  local itemType = 0
  if self.mData.ItemNumList then
    local itemId = self.mData.ItemNumList[0].itemid
    local itemData = TableData.listItemDatas:GetDataById(tonumber(itemId))
    itemType = itemData.Type
    if self.mData.IsMultiPrice then
      setactive(self.ui.mBtn_DetailInfo.gameObject, true)
      UIUtils.GetButtonListener(self.ui.mBtn_InfoOpen.gameObject).onClick = self.ShowPriceDetails
      setactive(self.ui.mBtn_PriceDetails.gameObject, true)
      setactive(self.ui.mBtn_InfoOpen1.gameObject, true)
      setactive(self.ui.mBtn_MultiPriceDetail.transform.parent.gameObject, true)
      setactive(self.ui.mTrans_CreditNum, false)
    else
      setactive(self.ui.mBtn_DetailInfo.gameObject, false)
      setactive(self.ui.mBtn_PriceDetails.gameObject, false)
      setactive(self.ui.mBtn_InfoOpen1.gameObject, false)
      setactive(self.ui.mBtn_MultiPriceDetail.transform.parent.gameObject, false)
    end
  end
  if itemType == ItemType.RobotPackage.value__ or itemType == ItemType.Robot.value__ then
    setactive(self.ui.mBtn_InfoOpen1.gameObject, true)
    UIUtils.GetListener(self.ui.mBtn_RobotInfo.gameObject).onClick = function()
      setactive(self.ui.mTrans_MacineAttribute, false)
      setactive(self.ui.mBtn_InfoOpen1.gameObject, true)
    end
    UIUtils.GetListener(self.ui.mBtn_MultiPriceDetail.gameObject).onClick = function()
      self:RobotDetail()
    end
  end
  if data.price_type ~= self.REAL_MONEY_ID and data.price_type ~= self.GUILD_RESOURCE_ID then
    UIUtils.GetListener(self.ui.mBtn_AmountPlusButton.gameObject).onClick = self.OnIncreaseClicked
    UIUtils.GetListener(self.ui.mBtn_AmountMinusButton.gameObject).onClick = self.OnDecreaseClicked
  else
    setactive(self.ui.mBtn_AmountPlusButton.gameObject, false)
    setactive(self.ui.mBtn_AmountMinusButton.gameObject, false)
    setactive(self.ui.mText_AmountText.gameObject, false)
    setactive(self.ui.mTrans_GoodsAmount, false)
  end
  self:InitAmount()
  for key, value in pairs(self.mData.ItemNumList) do
    local itemId = value.itemid
    local itemData = TableData.listItemDatas:GetDataById(tonumber(itemId))
    if itemData ~= nil and itemData.Type == 5 or itemData.Type == 8 then
      self.mNeedCheckRepository = true
    end
  end
  local buyLimit = data:GetStoreGoodData().limit
  if data.IsMultiPrice then
    buyLimit = data.multi_prize_remain_times
  end
  self.mIsSlider = true
  if self.mMaxNumPerPurchase ~= 0 then
    self.ui.mSlider_Item.value = self.mCurBuyAmount
    self.ui.mSlider_Item.maxValue = self.mMaxNumPerPurchase
    self.ui.mText_MaxNum.text = self.mMaxNumPerPurchase
  else
    self.ui.mSlider_Item.maxValue = 1
    self.ui.mSlider_Item.value = 1
    self.ui.mText_MaxNum.text = "1"
  end
  self.mIsSlider = false
end
function UIStoreConfirmPanel:RobotDetail()
  setactive(self.ui.mTrans_MacineAttribute, true)
  setactive(self.ui.mBtn_RobotInfo.gameObject, true)
  setactive(self.ui.mBtn_RobotInfo.transform.parent, true)
  setactive(self.ui.mTrans_RobotBg, true)
  setactive(self.ui.mTrans_Att, true)
  setactive(self.ui.mBtn_InfoOpen1.gameObject, false)
  local tempSkillData = {}
  for i = 0, self.mData.SkillShow.Count - 1 do
    table.insert(tempSkillData, TableData.listBattleSkillDatas:GetDataById(self.mData.SkillShow[i]))
  end
  for i = 1, #tempSkillData do
    local robotAttItem = self.RobotDetalList[i]
    if not robotAttItem then
      robotAttItem = UIStoreRobotAttItem.New()
      robotAttItem:InitCtrl(self.ui.mScrollChild_MacineAttribute.childItem, self.ui.mScrollChild_MacineAttribute.transform)
      table.insert(self.RobotDetalList, robotAttItem)
    end
    robotAttItem:SetData(tempSkillData[i])
  end
end
function UIStoreConfirmPanel.OnCloseClicked(gameObj)
  local self = UIStoreConfirmPanel
  local view = self.ui
  if view.mTrans_GrpPriceDetails.gameObject.activeSelf then
    setactive(view.mTrans_GrpPriceDetails, false)
  else
    self.OnCancelClicked(gameObj)
  end
end
function UIStoreConfirmPanel.OnCancelClicked(gameObj)
  local self = UIStoreConfirmPanel
  local eventTrigger = getcomponent(gameObj, typeof(CS.ButtonEventTriggerListener))
  if eventTrigger ~= nil then
    local view = eventTrigger.param
    view:OnRelease()
    self.mView = nil
    UIStoreMainPanel.IsConfirmPanelOpening = false
    UIStoreExchangePanel.IsConfirmPanelOpening = false
    UIManager.CloseUI(UIDef.UIStoreConfirmPanel)
  end
end
UIStoreConfirmPanel.mCurrencyItem = nil
function UIStoreConfirmPanel:InitGrpCurrency()
  if self.mCurrencyItem ~= nil then
    self.mCurrencyItem:OnRelease()
  end
  setactive(self.ui.mTrans_Top, self.mData.price_type ~= 0)
  if self.mData.price_type > 0 then
    local item = {}
    item.id = self.mData.price_type
    item.jumpID = nil
    item.param = 0
    local data = item
    local currencyParent = CS.TransformUtils.DeepFindChild(self.mUIRoot, "TopResourceBarRoot(Clone)")
    if currencyParent == nil then
      TimerSys:DelayCall(0.1, function()
        self:InitGrpCurrency()
      end)
      return
    end
    self.mCurrencyItem = ResourcesCommonItem.New()
    self.mCurrencyItem:InitCtrl(currencyParent.transform, true)
    self.mCurrencyItem:SetData(data)
  end
end
function UIStoreConfirmPanel.ShowPriceDetails(gameObject)
  self = UIStoreConfirmPanel
  local view = self.ui
  setactive(view.mTrans_GrpPriceDetails, true)
  local priceList = self.mData.MultiPriceDict
  for i = 0, view.mTrans_PriceDetailsContent.transform.childCount - 1 do
    local obj = view.mTrans_PriceDetailsContent.transform:GetChild(i)
    gfdestroy(obj)
  end
  for i = 0, priceList.Count - 1 do
    local item = UIStoreExchangePriceInfoItem.New()
    item:InitCtrl(view.mTrans_PriceDetailsContent)
    item:SetData(priceList[i])
    if self.mData.price == priceList[i].price then
      item:SetNow()
    end
  end
end
function UIStoreConfirmPanel.ShowStoreDetails()
  local self = UIStoreConfirmPanel
  local view = self.mView
end
function UIStoreConfirmPanel:InitAmount()
  local price = formatnum(self.mData.price * self.mCurBuyAmount)
  if self.mData.price_type > 0 then
    local stcData = TableData.GetItemData(self.mData.price_type)
    self.ui.mImage_PriceDetailsIcon.sprite = UIUtils.GetIconSprite("Icon/Item", stcData.icon)
  end
  self.ui.mText_PriceDetailsNum.text = self.mData.price
  if self.CheckRichEnough(price, self.mData.price_type) then
    self.ui.mText_Price.color = self.ColorBlack
    self.ui.mText_AmountText.color = self.ColorBlack
  else
    self.ui.mText_AmountText.color = ColorUtils.RedColor
    self.ui.mText_Price.color = ColorUtils.RedColor
  end
  self.CheckCanBuyItem()
  if 0 < self.mData.limit then
    setactive(self.ui.mTrans_GrpTextLeft, true)
    local hint = TableData.GetHintReplaceById(808, self.mData.remain_times)
    if self.mData.refresh_type == 1 then
      hint = TableData.GetHintReplaceById(106001, self.mData.remain_times)
    end
    if self.mData.refresh_type == 2 then
      hint = TableData.GetHintReplaceById(106002, self.mData.remain_times)
    end
    if self.mData.refresh_type == 3 then
      hint = TableData.GetHintReplaceById(106003, self.mData.remain_times)
    end
    self.ui.mText_GrpTextLeftText.text = hint
    self.ui.mText_LeftNum.text = ""
  end
end
function UIStoreConfirmPanel:OnSliderChange(value)
  if self.mIsSlider == true then
    return
  end
  self.mCurBuyAmount = luaRoundNum(value)
  self.mCurBuyAmount = self.mCurBuyAmount == 0 and 1 or self.mCurBuyAmount
  self.ui.mText_AmountText.text = self.mCurBuyAmount
  self.ui.mText_Price.text = string_format("{0}", formatnum(self.mCurBuyAmount * self.mData.price))
  self.CheckCanBuyItem()
  self.mIsSlider = true
  if self.mMaxNumPerPurchase ~= 0 then
    self.ui.mSlider_Item.value = self.mCurBuyAmount
    self.ui.mSlider_Item.maxValue = self.mMaxNumPerPurchase
    self.ui.mText_MaxNum.text = self.mMaxNumPerPurchase
  else
    self.ui.mSlider_Item.maxValue = 1
    self.ui.mSlider_Item.value = 1
    self.ui.mText_MaxNum.text = "1"
  end
  self.mIsSlider = false
end
function UIStoreConfirmPanel.CheckCanBuyItem()
  local self = UIStoreConfirmPanel
  if self.mMaxNumPerPurchase == 0 then
    self.ui.mText_AmountText.text = self.mCurBuyAmount
    local price = formatnum(self.mData.price * self.mCurBuyAmount)
    self.ui.mText_Price.text = string_format("{0}", price)
  end
  self.ui.mBtn_AmountPlusButton.interactable = self.mCurBuyAmount ~= self.mMaxNumPerPurchase and self.mMaxNumPerPurchase ~= 0
  self.ui.mBtn_AmountMinusButton.interactable = self.mCurBuyAmount ~= 1
end
function UIStoreConfirmPanel:OnBuyClicked(gameObj)
  if self.mNeedCheckRepository == true and TipsManager.CheckRepositoryIsFull() == true then
    return
  end
  local eventTrigger = getcomponent(gameObj, typeof(CS.ButtonEventTriggerListener))
  if eventTrigger ~= nil then
    local view = eventTrigger.param
    local data = eventTrigger.paramData
    local num = view.mCurBuyAmount
    local goodData = self.mData:GetStoreGoodData()
    self.mCurBuyNum = num
    local curBuyNum = view.mCurBuyAmount ~= 0 and view.mCurBuyAmount or 1
    local price = view.mData.price * curBuyNum
    if data.IsTagShowTime == false then
      MessageBox.Show("提示", "该商品已过期!", MessageBox.ShowFlag.eMidBtn, price, nil, nil)
      view:OnRelease()
      gfdestroy(view:GetRoot().gameObject)
      self.mView = nil
      return
    end
    if view.mData.ItemNumList then
      local itemId = self.mData.ItemNumList[0].itemid
      local itemData = TableData.listItemDatas:GetDataById(tonumber(itemId))
      if itemData.Type == 6 and self:StaminaOverFlowWarning(self.mData.ItemNumList[0].num * self.mCurBuyNum, data.id, num, self.OnBuyCallback) == true then
        return
      end
    end
    local buyCallback = function()
      MessageSys:SendMessage(CS.GF2.Message.StoreEvent.StoreExchangeRefresh, nil)
    end
    if self.CheckRichEnough(price, view.mData.price_type) == false then
      local str = ""
      if 0 < view.mData.price_type then
        local stcData = TableData.GetItemData(view.mData.price_type)
        if stcData == nil then
          gferror("未知的PriceType" .. data.price_type .. ",Item表里没有该ID")
          return
        end
        str = stcData.name.str
      end
      if view.mData.price_type == UIStoreGlobal.Diamond or view.mData.price_type == GlobalConfig.ResourceType.CreditFree then
        UIStoreGlobal.OnBuyClick(self, data, nil, num, buyCallback)
        return
      else
        CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), str))
      end
      return
    end
    local storeHistory = NetCmdStoreData:GetGoodsHistoryById(data.tag .. "#" .. data.id)
    if storeHistory ~= nil and storeHistory.Total == 0 then
      self.mIsFristBuy = true
    end
    local rewardList = {}
    if goodData ~= nil then
      if self.mIsFristBuy == true then
        for key, value in pairs(goodData.FirstBuyReward) do
          if value ~= nil then
            rewardList[value.itemid] = value.num
          end
        end
      end
      for key, value in pairs(goodData.BuyReward) do
        local hasNum = 0
        if rewardList[key] ~= nil then
          hasNum = rewardList[key]
        end
        rewardList[key] = value * self.mCurBuyNum + hasNum
      end
      local rewards = view.mData.ItemNumList
      for i = 0, rewards.Count - 1 do
        local key = rewards[i].itemid
        local value = rewards[i].num
        local hasNum = 0
        if rewardList[key] ~= nil then
          hasNum = rewardList[key]
        end
        rewardList[key] = value * self.mCurBuyNum + hasNum
      end
    end
    local otherTable = {}
    for itemId, num in pairs(rewardList) do
      if otherTable[itemId] == nil then
        otherTable[itemId] = 0
      end
      otherTable[itemId] = otherTable[itemId] + num
    end
    if TipsManager.CheckItemIsOverflowAndStopByList(otherTable) then
      return
    end
    if data.price_type ~= self.REAL_MONEY_ID then
      if data.price_type ~= self.GUILD_RESOURCE_ID then
        if data.is_black_market then
          NetCmdStoreData:SendStoreBlackBuy(data.index, data.tag, self.OnBuyCallback)
        elseif data.price_type == UIStoreGlobal.Diamond or data.price_type == GlobalConfig.ResourceType.CreditFree then
          UIStoreGlobal.OnBuyClick(self, data, nil, num, buyCallback)
        else
          NetCmdStoreData:SendStoreBuy(data.id, num, self.OnBuyCallback)
        end
      else
        NetCmdStoreData:SendSocialBuyStore(data.id, self.OnBuyCallback)
      end
    else
      NetCmdStoreData:SendStoreOrder(data.id, self.OnStoreOrderCallback)
    end
  end
  UIManager.CloseUI(UIDef.UIStoreConfirmPanel)
end
function UIStoreConfirmPanel:OnShowFinish()
  if self.block then
    self.parent.mCSPanel:Block()
    self.parent.block = true
    self.block = nil
  end
  self:InitGrpCurrency()
end
function UIStoreConfirmPanel:GetCurrencyAmount()
  local currency = 0
  local stcData = TableData.GetItemData(self.mCurCurrencyId)
  if stcData ~= nil and stcData.type ~= GlobalConfig.ItemType.Resource then
    local data = NetCmdItemData:GetNormalItem(self.mCurCurrencyId)
    if data == nil then
      currency = 0
    else
      currency = data.item_num
    end
  else
    currency = NetCmdItemData:GetResItemCount(stcData.id)
  end
  return currency
end
function UIStoreConfirmPanel.OnIncreaseClicked(gameObj)
  local self = UIStoreConfirmPanel
  local view = self
  if self.mData.remain_times == 0 then
    if (self.mData.limit == 0 or self.mCurBuyAmount < self.mData.limit) and self.mCurBuyAmount < self.mMaxNumPerPurchase then
      self.mCurBuyAmount = self.mCurBuyAmount + 1
    end
  elseif (self.mData.limit == 0 or self.mCurBuyAmount < self.mData.limit) and self.mCurBuyAmount < self.mMaxNumPerPurchase and self.mCurBuyAmount < self.mData.remain_times then
    self.mCurBuyAmount = self.mCurBuyAmount + 1
  end
  local price = formatnum(self.mData.price * self.mCurBuyAmount)
  self.ui.mText_Price.text = string_format("{0}", price)
  gfdebug(self.mCurBuyAmount)
  if self.CheckRichEnough(price, self.mData.price_type) then
    local ColorBlack = ColorUtils.StringToColor("325563")
    self.ui.mText_Price.color = ColorBlack
    self.ui.mText_AmountText.color = ColorBlack
  else
    self.ui.mText_AmountText.color = ColorUtils.RedColor
    self.ui.mText_Price.color = ColorUtils.RedColor
  end
  self.mIsSlider = true
  if self.mMaxNumPerPurchase ~= 0 then
    self.ui.mSlider_Item.maxValue = self.mMaxNumPerPurchase
    self.ui.mSlider_Item.value = self.mCurBuyAmount
    self.ui.mText_MaxNum.text = self.mMaxNumPerPurchase
  else
    self.ui.mSlider_Item.value = 1
    self.ui.mSlider_Item.maxValue = 1
    self.ui.mText_MaxNum.text = "1"
  end
  self.mIsSlider = false
  self.ui.mText_AmountText.text = self.mCurBuyAmount
  self.CheckCanBuyItem()
end
function UIStoreConfirmPanel.OnDecreaseClicked(gameObj)
  local self = UIStoreConfirmPanel
  if self.mCurBuyAmount > 1 then
    self.mCurBuyAmount = self.mCurBuyAmount - 1
  end
  local price = formatnum(self.mData.price * self.mCurBuyAmount)
  self.ui.mText_Price.text = string_format("{0}", price)
  if self.CheckRichEnough(price, self.mData.price_type) then
    self.ui.mText_Price.color = self.ColorBlack
    self.ui.mText_AmountText.color = self.ColorBlack
  else
    self.ui.mText_AmountText.color = ColorUtils.RedColor
    self.ui.mText_Price.color = ColorUtils.RedColor
  end
  self.mIsSlider = true
  if self.mMaxNumPerPurchase ~= 0 then
    self.ui.mSlider_Item.maxValue = self.mMaxNumPerPurchase
    self.ui.mSlider_Item.value = self.mCurBuyAmount
    self.ui.mText_MaxNum.text = self.mMaxNumPerPurchase
  else
    self.ui.mSlider_Item.value = 1
    self.ui.mSlider_Item.maxValue = 1
    self.ui.mText_MaxNum.text = "1"
  end
  self.mIsSlider = false
  self.ui.mText_AmountText.text = self.mCurBuyAmount
  self.CheckCanBuyItem()
end
function UIStoreConfirmPanel.OnStoreOrderCallback(ret)
  local self = UIStoreConfirmPanel
  UIStoreMainPanel.IsConfirmPanelOpening = false
  UIStoreExchangePanel.IsConfirmPanelOpening = false
  local rewardList = {}
  local goodData = self.mData:GetStoreGoodData()
  if goodData ~= nil then
    if self.mIsFristBuy == true then
      for key, value in pairs(goodData.FirstBuyReward) do
        if value ~= nil then
          rewardList[value.itemid] = value.num
        end
      end
    end
    for key, value in pairs(goodData.BuyReward) do
      local hasNum = 0
      if rewardList[key] ~= nil then
        hasNum = rewardList[key]
      end
      rewardList[key] = value * self.mCurBuyNum + hasNum
    end
  end
  for key, value in pairs(self.mItemReward) do
    if value ~= nil then
      local hasNum = 0
      if rewardList[value.itemid] ~= nil then
        hasNum = rewardList[value.itemid]
      end
      rewardList[value.itemid] = value.num * self.mCurBuyNum + hasNum
    end
  end
  local rewardItemList = {}
  for key, value in pairs(rewardList) do
    local rewardItem = {ItemId = key, ItemNum = value}
    table.insert(rewardItemList, rewardItem)
  end
  if self.callBack then
    UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
      nil,
      self.callBack
    })
  else
    UIManager.OpenUI(UIDef.UICommonReceivePanel)
  end
  self.CheckMultiPriceChange()
  MessageSys:SendMessage(CS.GF2.Message.StoreEvent.StoreExchangeRefresh, nil)
  self:ResetUI()
end
function UIStoreConfirmPanel.OnBuyCallback(ret)
  local self = UIStoreConfirmPanel
  gfwarning("ret" .. tostring(ret) .. type(ret) .. tostring(ErrorCodeSuc) .. type(ErrorCodeSuc))
  if ret == ErrorCodeSuc then
    gfdebug("购买成功")
    self.OnStoreOrderCallback(ret)
  else
    gfdebug("购买失败")
    TimerSys:DelayCall(0.1, function(idx)
      if not MessageBox.IsVisible() then
        MessageBox.Show("出错了", "购买失败!", MessageBox.ShowFlag.eMidBtn, nil, nil, nil)
      end
    end, 0)
  end
end
function UIStoreConfirmPanel.CheckMultiPriceChange()
  local self = UIStoreConfirmPanel
  if self.mData.IsMultiPrice and self.mData.remain_times == 0 and 0 < self.mData.jump_id then
    UIManager.OpenUIByParam(UIDef.UIStoreExchangePriceChangeDialog, self.mData)
  end
end
function UIStoreConfirmPanel.CheckRichEnough(total_price, price_type)
  local self = UIStoreConfirmPanel
  if price_type == self.REAL_MONEY_ID then
    return true
  end
  local currency = self:GetCurrencyAmount()
  if total_price > currency then
    return false
  else
    return true
  end
end
function UIStoreConfirmPanel:StaminaOverFlowWarning(addNum, dataId, num, BuyCallback)
  local playerStamina = GlobalData.GetStaminaResourceItemCount(UICommonGetPanel.StaminaId)
  local maxStamina = TableData.GetPlayerCurExtraStaminaMax()
  if playerStamina <= maxStamina and maxStamina < playerStamina + addNum then
    local hint = TableData.GetHintById(211)
    MessageBoxPanel.ShowDoubleType(hint, function()
      NetCmdStoreData:SendStoreBuy(dataId, num, BuyCallback)
    end)
    return true
  end
  return false
end
function UIStoreConfirmPanel.Close()
  UIManager.CloseUI(UIDef.UIStoreConfirmPanel)
end
function UIStoreConfirmPanel:OnClose()
  if self.itemView ~= nil then
    gfdestroy(self.itemView.ui.mObj)
  end
  if self.RobotDetalList then
    for i = 1, #self.RobotDetalList do
      if self.RobotDetalList[i] then
        gfdestroy(self.RobotDetalList[i]:GetRoot())
      end
    end
    self.RobotDetalList = nil
  end
  if self.mCurrencyItem ~= nil then
    self.mCurrencyItem:OnRelease()
  end
end
function UIStoreConfirmPanel:OnRelease()
  self = UIStoreConfirmPanel
  self:ResetUI()
  self.ui = nil
end
function UIStoreConfirmPanel:ResetUI()
  if self.ui then
    setactive(self.ui.mBtn_MultiPriceDetail.transform.parent.gameObject, false)
  end
end
