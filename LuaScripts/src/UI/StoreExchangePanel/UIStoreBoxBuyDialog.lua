require("UI.StoreExchangePanel.UIStoreBoxBuyDialogView")
require("UI.UIBasePanel")
UIStoreBoxBuyDialog = class("UIStoreBoxBuyDialog", UIBasePanel)
UIStoreBoxBuyDialog.__index = UIStoreBoxBuyDialog
UIStoreBoxBuyDialog.itemList = {}
function UIStoreBoxBuyDialog:ctor(csPanel)
  UIStoreBoxBuyDialog.super.ctor(UIStoreBoxBuyDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function UIStoreBoxBuyDialog.Open()
  UIStoreBoxBuyDialog.OpenUI(UIDef.UIStoreBoxBuyDialog)
end
function UIStoreBoxBuyDialog.Close()
  UIManager.CloseUI(UIDef.UIStoreBoxBuyDialog)
end
function UIStoreBoxBuyDialog:OnInit(root, data)
  UIStoreBoxBuyDialog.super.SetRoot(UIStoreBoxBuyDialog, root)
  self.mView = UIStoreBoxBuyDialogView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  if type(data) == "table" then
    self.mData = data.data
    self.parent = data.parent
  else
    self.mData = data
  end
  setactive(self.ui.mTrans_Top, false)
  self.BigItem = UICommonItem.New()
  self.BigItem:InitCtrl(self.ui.mTrans_Item)
  self.BigItem.mUIRoot.transform.anchoredPosition = vector2zero
  self.BigItem:SetRankAndIconData(self.mData.rank, IconUtils.GetCharacterItemSprite(self.mData.icon))
  self.BigItem.mUIRoot:GetComponent(typeof(CS.UnityEngine.CanvasGroup)).blocksRaycasts = false
  self.stcData = self.mData:GetStoreGoodData()
  self.ui.mText_ItemName.text = self.stcData.name.str
  self.ui.mText_Description.text = self.stcData.description.str
  self.ui.mScroll_Des.verticalNormalizedPosition = 1
  self.rewardList = {}
  local reward = string.sub(self.stcData.reward, 1, -2)
  local rewards = string.split(reward, ",")
  for i = 1, #rewards do
    local itemArr = string.split(rewards[i], ":")
    local itemId = tonumber(itemArr[1])
    local itemCount = tonumber(itemArr[2])
    local itemData = TableData.GetItemData(itemId)
    if itemData.type == GlobalConfig.ItemType.Weapon then
      local weaponInfoItem = UICommonItem.New()
      weaponInfoItem:InitCtrl(self.ui.mTrans_BoxContent)
      weaponInfoItem:SetData(itemData.args[0], 1, nil, true, itemData)
      self.itemList[itemId] = weaponInfoItem
    else
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mTrans_BoxContent)
      item:SetItemData(itemId, itemCount)
      self.itemList[itemId] = item
    end
    if self.rewardList[itemId] == nil then
      self.rewardList[itemId] = itemCount
    else
      self.rewardList[itemId] = self.rewardList[itemId] + itemCount
    end
  end
  for itemId, itemCount in pairs(self.stcData.BuyReward) do
    local itemData = TableData.GetItemData(itemId)
    local item = UICommonItem.New()
    item:InitCtrl(self.ui.mTrans_Content)
    item:SetItemData(itemId, itemCount)
    self.itemList[itemId] = item
    if self.rewardList[itemId] == nil then
      self.rewardList[itemId] = itemCount
    else
      self.rewardList[itemId] = self.rewardList[itemId] + itemCount
    end
  end
  if 0 < self.mData.price_type then
    self.costItemData = TableData.listItemDatas:GetDataById(self.mData.price_type)
    self.ui.mImg_CreditIcon.sprite = ResSys:GetAtlasSprite("Icon/Item/" .. self.costItemData.icon)
    if self.mData.price == "0" then
      self.ui.mText_CreditNum.text = TableData.GetHintById(901056) or self.mData.price
      setactive(self.ui.mImg_CreditIcon.transform.parent, false)
    else
      setactive(self.ui.mImg_CreditIcon.transform.parent, true)
      self.ui.mText_CreditNum.text = self.mData.price
    end
    self:InitGrpCurrency()
  else
    self.ui.mText_MoneyNum.text = self.mData.price
  end
  setactive(self.ui.mTrans_CreditNum, self.mData.price_type ~= 0)
  setactive(self.ui.mTrans_BoxPaid, self.mData.price_type == GlobalConfig.ResourceType.CreditPay and 0 < TableData.SystemVersionOpenData.FreePayCredit)
  setactive(self.ui.mTrans_MoneyNum, self.mData.price_type == 0)
  setactive(self.ui.mTrans_PurchaseQuantity, false)
  setactive(self.ui.mTrans_ItemBoxList, true)
  setactive(self.ui.mBtn_PriceDetails, false)
  setactive(self.ui.mTrans_GrpTextLeft, false)
  setactive(self.ui.mBtn_InfoOpen1.gameObject, false)
  UIUtils.GetButtonListener(self.ui.mBtn_StoreDetail.gameObject).onClick = function()
    UITipsPanel.OpenStoreGood(self.stcData.name.str, self.stcData.icon, self.stcData.description.str, self.stcData.rank, self.stcData)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Exit.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreBoxBuyDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreBoxBuyDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreBoxBuyDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Buy.gameObject).onClick = function()
    for itemId, itemCount in pairs(self.rewardList) do
      if TipsManager.CheckItemIsOverflowAndStop(itemId, itemCount) then
        return
      end
    end
    UIStoreGlobal.OnBuyClick(self, self.mData)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIStoreBoxBuyDialog)
  end
end
function UIStoreBoxBuyDialog:InitGrpCurrency()
  if self.mCurrencyItem ~= nil then
    self.mCurrencyItem:OnRelease()
  end
  setactive(self.ui.mTrans_Top, self.mData.price_type ~= 0 and self.mData.price ~= "0")
  if self.mData.price_type > 0 then
    local item = {}
    item.id = self.mData.price_type
    item.jumpID = nil
    item.param = 0
    local data = item
    self.mCurrencyItem = ResourcesCommonItem.New()
    self.mCurrencyItem:InitCtrl(self.ui.mTrans_GrpCurrency.transform, true)
    self.mCurrencyItem:SetData(data)
  end
end
function UIStoreBoxBuyDialog:OnShowStart()
  if self.mData.price_type == 0 then
    self.ui.mText_MoneyMark.text = "¥"
  end
end
function UIStoreBoxBuyDialog:OnClose()
  for _, item in pairs(self.itemList) do
    gfdestroy(item:GetRoot())
  end
  self.itemList = {}
  if self.BigItem then
    gfdestroy(self.BigItem:GetRoot())
  end
  if self.mCurrencyItem ~= nil then
    self.mCurrencyItem:OnRelease()
  end
  setactive(self.ui.mTrans_Top, false)
end
function UIStoreBoxBuyDialog:OnRelease()
end
