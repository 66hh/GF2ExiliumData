UIRaidDialogV2 = class("UIRaidDialogV2", UIBasePanel)
function UIRaidDialogV2:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIRaidDialogV2:OnInit(root, data)
  self.mData = data
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  local challengeRemainingNum = self:getRemainingChallengeTimes()
  if challengeRemainingNum == -1 then
    self.maxValue = TableData.GlobalSystemData.RaidOnetimeLimit
  else
    self.maxValue = math.min(TableData.GlobalSystemData.RaidOnetimeLimit, challengeRemainingNum)
  end
  self.minValue = self.maxValue >= 1 and 1 or 0
  self.ui.mBtn_BtnConfirm.interactable = true
  self.ui.mSlider.minValue = self.minValue
  self.ui.mSlider.maxValue = self.maxValue
  self.ui.mSlider.value = self.minValue
  self.ui.mText_MinNum.text = tostring(self.minValue)
  self.ui.mText_MaxNum.text = tostring(self.maxValue)
  self.curRaidTimes = self.minValue
  self.formatString = TableData.GetHintById(193010)
  self.currentCostItemCount = 0
  self.itemList = {}
  self:AddBtnListener()
  self:refreshCostIcon()
end
function UIRaidDialogV2:OnShowFinish()
  self.currentCostItemCount = NetCmdItemData:GetNetItemCount(self.mData.costItemId)
  self:Refresh()
end
function UIRaidDialogV2:OnTop()
end
function UIRaidDialogV2:OnClose()
  self.maxValue = nil
  self.curRaidTimes = nil
  self.ui.mSlider.onValueChanged:RemoveListener(self.onSliderValueChangedCallback)
  self.ui = nil
  self.mData = nil
  self.formatString = nil
  self:ReleaseCtrlTable(self.itemList, true)
  self.itemList = nil
end
function UIRaidDialogV2:OnRelease()
end
function UIRaidDialogV2:Refresh()
  self:onRiadTimesChanged()
end
function UIRaidDialogV2:AddBtnListener()
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpClose.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpBtnReduce.gameObject, function()
    self:onClickReduce()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpBtnIncrease.gameObject, function()
    self:onClickIncrease()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnCancel.gameObject, function()
    self:onClickCancel()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnConfirm.gameObject, function()
    self:onClickStartRaid()
  end)
  function self.onSliderValueChangedCallback(num)
    self:onSliderValueChanged(num)
  end
  self.ui.mSlider.onValueChanged:AddListener(self.onSliderValueChangedCallback)
end
function UIRaidDialogV2:refreshCurValueText()
  self.ui.mText_CompoundNum.text = string_format(self.formatString, self.curRaidTimes)
end
function UIRaidDialogV2:refreshSliderValue()
  self.ui.mSlider.value = self.curRaidTimes
end
function UIRaidDialogV2:refreshSliderBtn()
  self.ui.mBtn_GrpBtnReduce.interactable = self.curRaidTimes ~= self.minValue
  self.ui.mBtn_GrpBtnIncrease.interactable = self.curRaidTimes ~= self.maxValue
end
function UIRaidDialogV2:refreshCostText()
  self.ui.mText_CostNum.text = self.mData.costItemNum * self.curRaidTimes
  if self.currentCostItemCount >= self.mData.costItemNum * self.curRaidTimes then
    self.ui.mText_CostNum.color = Color.black
  else
    self.ui.mText_CostNum.color = ColorUtils.RedColor
  end
end
function UIRaidDialogV2:refreshCostIcon()
  local valid = self.mData.costItemId > 0 and 0 < self.mData.costItemNum
  setactive(self.ui.mTrans_CostItem, valid)
  if valid then
    self.ui.mImage_CostItem.sprite = IconUtils.GetItemIconSprite(self.mData.costItemId)
  end
end
function UIRaidDialogV2:RefreshRewardList()
  self.itemDataTable = {}
  for _, v in ipairs(self.mData.rewardItemList) do
    local itemID = v.id
    local itemNum = v.num
    local rewardNum = itemNum * self.curRaidTimes
    if self.itemDataTable[itemID] == nil then
      self.itemDataTable[itemID] = 0
    end
    self.itemDataTable[itemID] = self.itemDataTable[itemID] + rewardNum
  end
  for i, v in ipairs(self.mData.rewardItemList) do
    local itemID = v.id
    local itemNum = v.num
    if self.itemList[i] == nil then
      self.itemList[i] = UICommonItem.New()
      self.itemList[i]:InitCtrl(self.ui.mTrans_RewardContent)
    end
    local item = self.itemList[i]
    item:SetItemData(itemID, itemNum)
  end
end
function UIRaidDialogV2:onClickClose()
  self:closeSelf()
end
function UIRaidDialogV2:onClickIncrease()
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
function UIRaidDialogV2:onClickReduce()
  self:changeRaidTimes(-1)
end
function UIRaidDialogV2:onSliderValueChanged()
  local delta = math.ceil(self.ui.mSlider.value) - self.curRaidTimes
  self:changeRaidTimes(delta)
end
function UIRaidDialogV2:onClickStartRaid()
  if self.curRaidTimes == 0 then
    local hint = TableData.GetHintById(601)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  if not TipsManager.CheckStaminaIsEnoughOnly(self.mData.costItemNum * self.curRaidTimes) then
    return
  end
  local sendRaidCmd = function()
    self.ui.mBtn_BtnConfirm.interactable = false
    self.mData.raidCallBack(self.curRaidTimes, function(ret)
      self:onResponseRaid(ret)
    end)
  end
  if self:checkNormalDropIsOverflow() then
    return
  end
  sendRaidCmd()
end
function UIRaidDialogV2:changeRaidTimes(delta)
  local targetValue = self.curRaidTimes + delta
  if targetValue > self.maxValue then
    targetValue = self.maxValue
  elseif targetValue < self.minValue then
    targetValue = self.minValue
  end
  self.curRaidTimes = targetValue
  self:onRiadTimesChanged()
end
function UIRaidDialogV2:onRiadTimesChanged()
  self:refreshCurValueText()
  self:refreshSliderValue()
  self:refreshSliderBtn()
  self:refreshCostText()
  self:RefreshRewardList()
end
function UIRaidDialogV2:onClickCancel()
  self:closeSelf()
end
function UIRaidDialogV2:onResponseRaid(ret)
  if ret ~= ErrorCodeSuc then
    return
  end
  self:closeSelf()
  local param = {
    OnDuringEndCallback = function()
      self:onDuringEnd()
    end
  }
  UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, param)
end
function UIRaidDialogV2:closeSelf()
  UIManager.CloseUI(UIDef.UIRaidDialogV2)
end
function UIRaidDialogV2:onDuringEnd()
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
    nil,
    nil,
    nil,
    true
  })
  MessageSys:SendMessage(UIEvent.OnRaidDuringEnd, self.simTypeId)
end
function UIRaidDialogV2:getRemainingChallengeTimes()
  if self.mData.maxSweepsNum then
    return self.mData.maxSweepsNum
  end
  if self.mData.costItemId == 0 or self.mData.costItemNum == 0 then
    return -1
  end
  local itemNum = NetCmdItemData:GetNetItemCount(self.mData.costItemId)
  local result = math.floor(itemNum / self.mData.costItemNum)
  return result
end
function UIRaidDialogV2:checkNormalDropIsOverflow()
  for itemId, num in pairs(self.itemDataTable) do
    if TipsManager.CheckItemIsOverflow(itemId, num, true) then
      return true
    end
  end
  return false
end
