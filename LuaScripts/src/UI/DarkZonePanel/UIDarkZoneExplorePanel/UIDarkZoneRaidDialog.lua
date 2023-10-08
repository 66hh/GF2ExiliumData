require("UI.UIBasePanel")
UIDarkZoneRaidDialog = class("UIDarkZoneRaidDialog", UIBasePanel)
UIDarkZoneRaidDialog.__index = UIDarkZoneRaidDialog
function UIDarkZoneRaidDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneRaidDialog:OnAwake(root, data)
end
function UIDarkZoneRaidDialog:OnInit(root, data)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  self.mData = data
  self:AddBtnListen()
  self:RefreshCostItem()
  self:InitSlider()
end
function UIDarkZoneRaidDialog:AddBtnListen()
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:OnBtnClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpClose.gameObject, function()
    self:OnBtnClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpBtnReduce.gameObject, function()
    self:onClickReduce()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpBtnIncrease.gameObject, function()
    self:onClickIncrease()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnCancel.gameObject, function()
    self:OnBtnClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnConfirm.gameObject, function()
    self:onClickStartRaid()
  end)
  self:AddMsgListener()
end
function UIDarkZoneRaidDialog:AddMsgListener()
  function self.raidCallBack(msg)
    self:OnRaidReward(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkZoneRaidReward, self.raidCallBack)
end
function UIDarkZoneRaidDialog:RemoveMsgListener()
  if self.raidCallBack then
    MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkZoneRaidReward, self.raidCallBack)
    self.raidCallBack = nil
  end
end
function UIDarkZoneRaidDialog:RefreshCostItem()
  self.curItemNum = 0
  self.costItemNum = 1
  self.costItem = 0
  for k, v in pairs(self.mData.use_item) do
    self.costItem = tonumber(k)
    self.costItemNum = tonumber(v)
    self.curItemNum = NetCmdItemData:GetItemCount(self.costItem)
  end
  self.maxValue = math.min(TableData.GlobalSystemData.RaidOnetimeLimit, self.curItemNum)
end
function UIDarkZoneRaidDialog:InitSlider()
  self.ui.mBtn_BtnConfirm.interactable = true
  self.ui.mSlider.minValue = 1
  self.ui.mSlider.maxValue = self.maxValue
  self.ui.mSlider.value = 1
  self.ui.mText_MinNum.text = tostring(1)
  self.ui.mText_MaxNum.text = tostring(self.maxValue)
  self.curRaidTimes = 1
  function self.onSliderValueChangedCallback()
    self:onSliderValueChanged()
  end
  self.ui.mSlider.onValueChanged:AddListener(self.onSliderValueChangedCallback)
end
function UIDarkZoneRaidDialog:onSliderValueChanged()
  local delta = math.ceil(self.ui.mSlider.value) - self.curRaidTimes
  self:changeRaidTimes(delta)
end
function UIDarkZoneRaidDialog:changeRaidTimes(delta)
  local targetValue = self.curRaidTimes + delta
  if targetValue > self.maxValue then
    targetValue = self.maxValue
  elseif targetValue < 1 then
    targetValue = 1
  end
  self.curRaidTimes = targetValue
  self:onRaidTimesChanged()
end
function UIDarkZoneRaidDialog:onRaidTimesChanged()
  self:refreshCurValueText()
  self:refreshSliderValue()
  self:refreshSliderBtn()
  self:refreshCostText()
end
function UIDarkZoneRaidDialog:refreshCurValueText()
  self.ui.mText_CompoundNum.text = self.curRaidTimes
end
function UIDarkZoneRaidDialog:refreshSliderValue()
  self.ui.mSlider.value = self.curRaidTimes
end
function UIDarkZoneRaidDialog:refreshSliderBtn()
  self.ui.mBtn_GrpBtnReduce.interactable = self.curRaidTimes ~= 1
  self.ui.mBtn_GrpBtnIncrease.interactable = self.curRaidTimes ~= self.maxValue
end
function UIDarkZoneRaidDialog:refreshCostText()
  if not self.oriColor then
    self.oriColor = self.ui.mText_CostNum.color
  end
  local totalCost = self.costItemNum * self.curRaidTimes
  self.ui.mText_CostNum.text = totalCost
  if totalCost <= self.curItemNum then
    self.ui.mText_CostNum.color = self.oriColor
  else
    self.ui.mText_CostNum.color = ColorUtils.RedColor
  end
end
function UIDarkZoneRaidDialog:refreshCostIcon()
  setactive(self.ui.mTrans_CostItem, self.costItem > 0)
  if self.costItem > 0 then
    self.ui.mImage_CostItem.sprite = IconUtils.GetItemIconSprite(self.costItem)
  end
end
function UIDarkZoneRaidDialog:OnShowStart()
  self:Refresh()
end
function UIDarkZoneRaidDialog:OnTop()
  self:Refresh()
end
function UIDarkZoneRaidDialog:OnShowFinish()
end
function UIDarkZoneRaidDialog:OnBackFrom()
end
function UIDarkZoneRaidDialog:OnClose()
  self.ui.mSlider.onValueChanged:RemoveListener(self.onSliderValueChangedCallback)
  self.ui = nil
  self.mData = nil
  self:RemoveMsgListener()
end
function UIDarkZoneRaidDialog:OnHide()
end
function UIDarkZoneRaidDialog:OnHideFinish()
end
function UIDarkZoneRaidDialog:Release()
end
function UIDarkZoneRaidDialog:OnRecover()
end
function UIDarkZoneRaidDialog:OnSave()
end
function UIDarkZoneRaidDialog:OnBtnClose()
  UIManager.CloseUI(UIDef.UIDarkZoneRaidDialog)
end
function UIDarkZoneRaidDialog:onClickReduce()
  self:changeRaidTimes(-1)
end
function UIDarkZoneRaidDialog:Refresh()
  self:refreshCurValueText()
  self:refreshCostText()
  self:refreshCostIcon()
  self:refreshSliderBtn()
end
function UIDarkZoneRaidDialog:onClickIncrease()
  if self.curRaidTimes >= self.maxValue then
    local hint = TableData.GetHintById(601)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  if self.curRaidTimes >= TableData.GlobalSystemData.RaidOnetimeLimit then
    local hint = TableData.GetHintById(609)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  self:changeRaidTimes(1)
end
function UIDarkZoneRaidDialog:onClickStartRaid()
  if self.curRaidTimes <= 0 then
    local hint = TableData.GetHintById(601)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  local totalCost = self.costItemNum * self.curRaidTimes
  self.ui.mText_CostNum.text = totalCost
  if totalCost > self.curItemNum then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(240100))
    return
  end
  self.ui.mBtn_BtnConfirm.interactable = false
  DarkNetCmdStoreData:RequestRaid(self.curRaidTimes, function(ret)
    self:onResponseRaid(ret)
  end)
end
function UIDarkZoneRaidDialog:onResponseRaid(ret)
  self.ui.mBtn_BtnConfirm.interactable = true
end
function UIDarkZoneRaidDialog:OnRaidReward(msg)
  self:OnBtnClose()
  self.rewardList = msg.Sender
  local param = {
    OnDuringEndCallback = function()
      self:onDuringEnd()
    end
  }
  UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, param)
end
function UIDarkZoneRaidDialog:onDuringEnd()
  if not self.rewardList then
    return
  end
  local itemlist = {}
  for _, v in pairs(self.rewardList) do
    table.insert(itemlist, {
      ItemId = v.ItemId,
      ItemNum = v.ItemNum
    })
  end
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {itemlist})
  self.rewardList = nil
end
