require("UI.StorePanel.Item.UIStoreExchangePriceInfoItem")
require("UI.UICommonGetPanel.UICommonGetView")
require("UI.UIBasePanel")
UICommonGetPanel = class("UICommonGetPanel", UIBasePanel)
UICommonGetPanel.__index = UICommonGetPanel
UICommonGetPanel.GetType = {Item = 1, Diamond = 2}
UICommonGetPanel.ErrorType = {
  None = 0,
  OverFlow = 1,
  ItemNotEnough = 2
}
UICommonGetPanel.StaminaId = GlobalConfig.StaminaId
UICommonGetPanel.currentReceiveItem = nil
UICommonGetPanel.curSelectContent = nil
UICommonGetPanel.curSelectIndex = 1
function UICommonGetPanel:ctor(csPanel)
  UICommonGetPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonGetPanel:Close()
  if self.mView.mTrans_GrpPriceDetails.gameObject.activeSelf then
    self:HidePriceDetails()
  end
  UIManager.CloseUI(UIDef.UICommonGetPanel)
end
function UICommonGetPanel:OnRelease()
  UICommonGetPanel.currentReceiveItem = nil
  self.IsFirstEnter = true
end
function UICommonGetPanel:OnClose()
  self.super.OnClose(self)
  self.RefreshStamina = nil
end
function UICommonGetPanel.OnUpdateTop()
  self:UpdateView()
end
function UICommonGetPanel:OnInit(root, data)
  UICommonGetPanel.super.SetRoot(UICommonGetPanel, root)
  self.mView = UICommonGetView.New()
  self.mView:InitCtrl(root)
  for i = 1, 2 do
    local button = self.mView.contentList[i]
    local btn = UIUtils.GetButtonListener(button.btnSelect.gameObject)
    function btn.onClick(gameObject)
      self:OnSelectItem(gameObject)
    end
    btn.param = i
  end
  function self.RefreshStamina()
    self:UpdateView()
  end
  self:AddMessageListener(CS.GF2.Message.CommonEvent.BuyStaminaTimeRefresh, self.RefreshStamina)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Cancel.gameObject).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_BGClose.gameObject).onClick = function()
    self:BGClose()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Confirm.gameObject).onClick = function()
    if TipsManager.CheckItemIsOverflowAndStop(self.curSelectContent.data.prizeData.itemid, self.curSelectContent.data.prizeData.num) == true then
      return
    end
    if not MessageBoxPanel.IsItemNotEnough then
      self:OnBuyDataButtonClick(self.curSelectContent)
    else
      self:OnDiamandNeedGotoStoreClicked()
      MessageBoxPanel.Close()
    end
  end
  UIUtils.GetButtonListener(self.mView.mBtn_PriceDetails.gameObject).onClick = function()
    self:ShowPriceDetails()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_GrpPriceDetails.gameObject).onClick = function()
    self:HidePriceDetails()
  end
  self:UpdateView()
  self.IsFirstEnter = false
end
function UICommonGetPanel:UpdateView()
  local flag = false
  for i = 0, TableData.GlobalConfigData.StaminaStoreItem.Count - 1 do
    local id = TableData.GlobalConfigData.StaminaStoreItem[i]
    local data = self:InitItem(id)
    local content = self.mView.contentList[i + 1]
    self:UpdateContentByData(content, data)
    if self.IsFirstEnter then
      if i == 0 and data.isItemEnough then
        self.curSelectIndex = 1
        flag = true
      end
      if i == 1 and data.isItemEnough and not flag and 0 < content.data.storeData.remain_times then
        self.curSelectIndex = 2
      end
    end
  end
  self:OnSelectItem(self.mView.contentList[self.curSelectIndex].item.gameObject)
end
function UICommonGetPanel:InitItem(storeId)
  local item = {}
  local storeData = NetCmdStoreData:GetCurStaminaStage(storeId)
  local itemId = storeData.price_type
  item.storeData = storeData
  item.itemData = TableData.GetItemData(itemId)
  item.prizeData = item.storeData.ItemNumList[0]
  item.itemCount = NetCmdItemData:GetResItemCount(itemId)
  item.isItemEnough = tonumber(item.itemCount) >= tonumber(item.storeData.price)
  return item
end
function UICommonGetPanel:ShowPriceDetails(gameObject)
  local data = self.curSelectContent.data.storeData
  setactive(self.mView.mTrans_GrpPriceDetails, true)
  local priceList = data.MultiPriceDict
  for i = 0, self.mView.mTrans_GrpPriceDetailsContent.transform.childCount - 1 do
    local obj = self.mView.mTrans_GrpPriceDetailsContent.transform:GetChild(i)
    gfdestroy(obj)
  end
  for i = 0, priceList.Count - 1 do
    local item = UIStoreExchangePriceInfoItem.New()
    item:InitCtrl(self.mView.mTrans_GrpPriceDetailsContent)
    item:SetData(priceList[i])
    if data.price == priceList[i].price then
      item:SetNow()
    end
  end
end
function UICommonGetPanel:BGClose()
  if self.mView.mTrans_GrpPriceDetails.gameObject.activeSelf then
    self:HidePriceDetails(nil)
  else
    self:Close()
  end
end
function UICommonGetPanel:HidePriceDetails(gameObj)
  setactive(self.mView.mTrans_GrpPriceDetails, false)
end
function UICommonGetPanel:UpdateContentByData(contet, data)
  if contet == nil or data == nil then
    return
  end
  contet.data = data
  contet.imgIcon.sprite = IconUtils.GetItemSprite(data.itemData.icon)
  contet.txtRemainItem.text = data.itemCount
  contet.txtRemainItem.color = data.isItemEnough and ColorUtils.WhiteColor or ColorUtils.RedColor
  contet.imgRank.color = TableData.GetGlobalGun_Quality_Color2(data.itemData.rank)
end
function UICommonGetPanel:OnSelectItem(gameObject)
  for i = 1, #self.mView.contentList do
    local c = self.mView.contentList[i]
    UICommonGetPanel.SetSelect(c, false)
  end
  local btn = UIUtils.GetButtonListener(gameObject)
  local index = btn.param
  local content = self.mView.contentList[index]
  UICommonGetPanel.SetSelect(content, true)
  self.curSelectContent = content
  self.curSelectIndex = index
  local hint1 = TableData.GetHintById(203)
  self.mView.mTextTitle.text = string_format(hint1, content.data.itemData.name.str)
  local hint2 = TableData.GetHintById(204)
  local num1 = content.data.storeData.price
  local name1 = content.data.itemData.name.str
  local num2 = content.data.prizeData.num
  local stcData = TableData.GetItemData(content.data.prizeData.itemid)
  local name2 = stcData.name.str
  self.mView.mTextInfo.text = string_format(hint2, num1, name1, num2, name2)
  if content.data.storeData.IsMultiPrice then
    setactive(self.mView.mTrans_PriceDetails, true)
    setactive(self.mView.mTrans_TextNum, true)
    local stcData = TableData.GetItemData(content.data.storeData.price_type)
    self.mView.mImg_PriceDetailsImageIcon.sprite = UIUtils.GetIconSprite("Icon/Item", stcData.icon)
    self.mView.mTxt_PriceSetailsNum.text = content.data.storeData.price
    self.mView.mTxt_TextNum.text = content.data.storeData.remain_times
  else
    setactive(self.mView.mTrans_PriceDetails, false)
    setactive(self.mView.mTrans_TextNum, false)
  end
end
function UICommonGetPanel.SetSelect(content, isSelect)
  setactive(content.transChoose, isSelect)
  setactive(content.tranSel, isSelect)
end
function UICommonGetPanel:OnBuyDataButtonClick(content)
  if not content then
    return
  end
  self.currentReceiveItem = content
  local item = content.data
  local type = content.type
  if self:NeedShowBuyTips(item, type) then
    return
  else
    if self.curSelectContent.data.storeData.remain_times == 0 and self.curSelectIndex == 2 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(106012))
      return
    end
    if self:StaminaOverFlowWarning(item.prizeData.num) then
      return
    else
      NetCmdStoreData:SendStoreBuy(item.storeData.id, 1, function()
        self:TakeQuestRewardCallBack()
      end)
    end
  end
end
function UICommonGetPanel:OnDiamandNeedGotoStoreClicked()
  MessageBoxPanel.IsItemNotEnough = false
  if self.currentReceiveItem then
    if self.currentReceiveItem.type == UICommonGetPanel.GetType.Diamond then
      SceneSwitch:SwitchByID(5)
    elseif self.currentReceiveItem.type == UICommonGetPanel.GetType.Item then
      SceneSwitch:SwitchByID(19)
    end
    UIManager.CloseUI(UIDef.UIRaidDialog)
    UICommonGetPanel.Close()
    UIStoreExchangePriceChangeDialog.Close()
  end
end
function UICommonGetPanel:TakeQuestRewardCallBack()
  self:CheckMultiPriceChange()
  MessageSys:SendMessage(CS.GF2.Message.CommonEvent.BuyStaminaTimeRefresh, nil)
  local hint = TableData.GetHintById(106013)
  CS.PopupMessageManager.PopupPositiveString(hint)
end
function UICommonGetPanel:CheckMultiPriceChange()
  local view = self.curSelectContent
  if view.data.storeData.IsMultiPrice and view.data.storeData.remain_times == 0 and 0 < view.data.storeData.jump_id then
    UIManager.OpenUIByParam(UIDef.UIStoreExchangePriceChangeDialog, view.data.storeData)
  end
end
function UICommonGetPanel:CheckCanBuyStamina(item)
  if self:CheckStaminaIsOverFlow() then
    return UICommonGetPanel.ErrorType.OverFlow
  elseif not item.isItemEnough then
    return UICommonGetPanel.ErrorType.ItemNotEnough
  else
    return UICommonGetPanel.ErrorType.None
  end
end
function UICommonGetPanel:NeedShowBuyTips(item, type)
  local error = self:CheckCanBuyStamina(item)
  if error == UICommonGetPanel.ErrorType.OverFlow then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(212))
    return true
  elseif error == UICommonGetPanel.ErrorType.ItemNotEnough then
    if type == UICommonGetPanel.GetType.Item then
      CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), item.itemData.name.str))
    elseif type == UICommonGetPanel.GetType.Diamond then
      CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), item.itemData.name.str))
    end
    return true
  end
  return false
end
function UICommonGetPanel:CheckStaminaIsOverFlow()
  local playerStamina = GlobalData.GetStaminaResourceItemCount(UICommonGetPanel.StaminaId)
  local maxStamina = TableData.GetPlayerCurExtraStaminaMax()
  if playerStamina >= maxStamina then
    return true
  end
  return false
end
function UICommonGetPanel:StaminaOverFlowWarning(addNum)
  local playerStamina = GlobalData.GetStaminaResourceItemCount(UICommonGetPanel.StaminaId)
  local maxStamina = TableData.GetPlayerCurExtraStaminaMax()
  if playerStamina < maxStamina and maxStamina < playerStamina + addNum then
    local hint = TableData.GetHintById(211)
    MessageBoxPanel.ShowDoubleType(hint, function()
      NetCmdStoreData:SendStoreBuy(self.currentReceiveItem.data.storeData.id, 1, self.TakeQuestRewardCallBack)
    end)
    return true
  end
  return false
end
