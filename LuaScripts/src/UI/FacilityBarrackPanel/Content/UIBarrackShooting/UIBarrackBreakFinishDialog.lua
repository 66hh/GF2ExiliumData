require("UI.FacilityBarrackPanel.Item.ComAttributeDetailItem")
UIBarrackBreakFinishDialog = class("UIBarrackBreakFinishDialog", UIBasePanel)
function UIBarrackBreakFinishDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
end
function UIBarrackBreakFinishDialog:OnAwake(root, gunId)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:onClickClose()
  end)
end
function UIBarrackBreakFinishDialog:OnInit(root, data)
  self.gunId = data.GunId
  self.onCloseCallback = data.OnCloseCallback
  self.gunCmdData = NetCmdTeamData:GetGunByID(self.gunId)
  self.itemViewTable = {}
end
function UIBarrackBreakFinishDialog:OnShowStart()
  self:SetVisible(true)
  self.ui.mBtn_Close.interactable = false
  TimerSys:DelayCall(0.5, function()
    self.ui.mBtn_Close.interactable = true
  end)
  self:refreshGunInfo()
  self:refreshAllProperty()
end
function UIBarrackBreakFinishDialog:OnCameraStart()
  return 0.01
end
function UIBarrackBreakFinishDialog:OnCameraBack()
  local isFullLevel = self.gunCmdData.IsFullLevel
  if isFullLevel then
    return BarrackHelper.CameraMgr:GetDuration(BarrackCameraOperate.SettlementToOverview)
  else
    return BarrackHelper.CameraMgr:GetAlmostEndDuration(BarrackCameraOperate.SettlementToUpgrade)
  end
end
function UIBarrackBreakFinishDialog:OnClose()
  if self.onCloseCallback then
    self.onCloseCallback()
  end
  self.onCloseCallback = nil
  self:ReleaseCtrlTable(self.itemViewTable, true)
  self.itemViewTable = nil
  self.gunId = nil
  self.gunCmdData = nil
end
function UIBarrackBreakFinishDialog:OnRelease()
  self.ui = nil
  self.super.OnRelease(self)
end
function UIBarrackBreakFinishDialog:onClickClose()
  if self.gunCmdData.IsFullLevel then
    self:SetVisible(false)
    local duration = BarrackHelper.CameraMgr:GetAlmostEndDuration(BarrackCameraOperate.SettlementToOverview)
    TimerSys:DelayCall(duration, function()
      UIManager.CloseUI(UIDef.UIBarrackTrainingPanel)
    end)
  else
    UIManager.CloseUI(self.mCSPanel)
  end
  if self.onCloseCallback then
    self.onCloseCallback()
  end
  self.onCloseCallback = nil
end
function UIBarrackBreakFinishDialog:refreshGunInfo()
  self.ui.mText_ChrName.text = self.gunCmdData.gunData.name.str
  self.ui.mText_Num.text = self.gunCmdData.MaxGunLevel
end
function UIBarrackBreakFinishDialog:refreshAllProperty()
  local itemIndex = 1
  for i = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
    local propertyType = DevelopProperty.__CastFrom(i)
    if propertyType then
      local prevValue = PropertyUtils.GetBasePropertyValue(self.gunId, self.gunCmdData.level, propertyType) + self.gunCmdData:GetGunClassValueByPropertyType(propertyType, self.gunCmdData.gunClass - 1)
      local curValue = PropertyUtils.GetBasePropertyValue(self.gunId, self.gunCmdData.level, propertyType) + self.gunCmdData:GetCurGunClassValueByPropertyType(propertyType)
      local delta = curValue - prevValue
      if 0 < delta then
        local item = ComAttributeDetailItem.New()
        local template = self.ui.mScrollListChild_Content.childItem
        local parent = self.ui.mScrollListChild_Content.transform
        item:InitByTemplate(template, parent)
        item:ShowDiff(itemIndex, propertyType, prevValue, curValue, true)
        itemIndex = itemIndex + 1
        table.insert(self.itemViewTable, item)
      end
    end
  end
end
