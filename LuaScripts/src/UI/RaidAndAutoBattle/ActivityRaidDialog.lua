require("UI.UIBaseCtrl")
ActivityRaidDialog = class("ActivityRaidDialog", UIBasePanel)
ActivityRaidDialog.__index = ActivityRaidDialog
function ActivityRaidDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  csPanel.UsePool = false
end
function ActivityRaidDialog:OnAwake(root, data)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpClose.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpBtnReduce.gameObject, function()
    self:changeRaidTimes(-1)
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_GrpBtnIncrease.gameObject, function()
    if self.curRaidTimes >= self.maxValue then
      local hint = TableData.GetHintById(601)
      CS.PopupMessageManager.PopupString(hint)
      return
    end
    self:changeRaidTimes(1)
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnCancel.gameObject, function()
    self:onClickClose()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnConfirm.gameObject, function()
    self:onClickStartRaid()
  end)
end
function ActivityRaidDialog:onClickStartRaid()
  if self.curRaidTimes == 0 then
    local hint = TableData.GetHintById(601)
    CS.PopupMessageManager.PopupString(hint)
    return
  end
  if not self:isStaminaEnough() then
    return
  end
  self.ui.mBtn_BtnConfirm.interactable = false
  NetCmdThemeData:SendMonopolyRaid(self.stage_id, self.curRaidTimes, function(ret)
    if ret == ErrorCodeSuc then
      self:onClickClose()
      local param = {
        OnDuringEndCallback = function()
          self:onDuringEnd()
        end
      }
      UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, param)
    end
  end)
end
function ActivityRaidDialog:onDuringEnd()
  UIManager.OpenUI(UIDef.UICommonReceivePanel)
end
function ActivityRaidDialog:onClickClose()
  UIManager.CloseUI(UIDef.ActivityRaidDialog)
end
function ActivityRaidDialog:OnInit(root, data)
  self.stage_id = data.stage_id
  self.sweep_cost = data.sweep_cost
  self.maxValue = data.sweep_times
  self.ui.mBtn_BtnConfirm.interactable = true
  for k, v in pairs(data.sweep_cost) do
    self.itemId = k
    self.itemNum = v
    local itemCount = NetCmdItemData:GetNetItemCount(k)
    local sweepCount = math.floor(itemCount / v)
    if sweepCount < self.maxValue then
      self.maxValue = sweepCount
    end
  end
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
function ActivityRaidDialog:onSliderValueChanged()
  local delta = math.ceil(self.ui.mSlider.value) - self.curRaidTimes
  self:changeRaidTimes(delta)
end
function ActivityRaidDialog:changeRaidTimes(delta)
  local targetValue = self.curRaidTimes + delta
  if targetValue > self.maxValue then
    targetValue = self.maxValue
  elseif targetValue < 1 then
    targetValue = 1
  end
  self.curRaidTimes = targetValue
  self:onRiadTimesChanged()
end
function ActivityRaidDialog:onRiadTimesChanged()
  self:refreshCurValueText()
  self:refreshSliderValue()
  self:refreshSliderBtn()
  self:refreshCostText()
end
function ActivityRaidDialog:refreshCurValueText()
  self.ui.mText_CompoundNum.text = self.curRaidTimes
end
function ActivityRaidDialog:refreshSliderValue()
  self.ui.mSlider.value = self.curRaidTimes
end
function ActivityRaidDialog:refreshSliderBtn()
  self.ui.mBtn_GrpBtnReduce.interactable = self.curRaidTimes ~= 1
  self.ui.mBtn_GrpBtnIncrease.interactable = self.curRaidTimes ~= self.maxValue
end
function ActivityRaidDialog:refreshCostText()
  self.ui.mText_CostNum.text = self.itemNum * self.curRaidTimes
  if self:isStaminaEnough() then
    self.ui.mText_CostNum.color = Color.black
  else
    self.ui.mText_CostNum.color = ColorUtils.RedColor
  end
end
function ActivityRaidDialog:isStaminaEnough()
  local cost = self.itemNum * self.curRaidTimes
  local total = NetCmdItemData:GetNetItemCount(self.itemId)
  if cost > total then
    return false
  end
  return true
end
function ActivityRaidDialog:refreshCostIcon()
  self.ui.mImage_CostItem.sprite = IconUtils.GetItemIconSprite(self.itemId)
end
function ActivityRaidDialog:OnShowStart()
  self:Refresh()
end
function ActivityRaidDialog:OnTop()
  self:Refresh()
end
function ActivityRaidDialog:OnClose()
  self.ui.mSlider.onValueChanged:RemoveListener(self.onSliderValueChangedCallback)
end
function ActivityRaidDialog:OnRelease()
  self.maxValue = nil
  self.curRaidTimes = nil
  self.ui.stageData = nil
  self.ui = nil
end
function ActivityRaidDialog:Refresh()
  self:refreshCurValueText()
  self:refreshCostText()
  self:refreshCostIcon()
  self:refreshSliderBtn()
end
