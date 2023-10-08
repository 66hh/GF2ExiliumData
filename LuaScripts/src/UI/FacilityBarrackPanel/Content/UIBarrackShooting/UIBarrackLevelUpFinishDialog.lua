require("UI.FacilityBarrackPanel.Item.ComAttributeDetailItem")
UIBarrackLevelUpFinishDialog = class("UIBarrackLevelUpFinishDialog", UIBasePanel)
function UIBarrackLevelUpFinishDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
end
function UIBarrackLevelUpFinishDialog:OnAwake(root, gunId)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Close.gameObject, function()
    self:onClickClose()
  end)
  self.itemViewTable = {}
end
function UIBarrackLevelUpFinishDialog:OnInit(root, data)
  self.gunId = data.GunId
  self.onCloseCallback = data.OnCloseCallback
  self.gunCmdData = NetCmdTeamData:GetGunByID(self.gunId)
end
function UIBarrackLevelUpFinishDialog:OnShowStart()
  self.ui.mBtn_Close.interactable = false
  TimerSys:DelayCall(0.5, function()
    self.ui.mBtn_Close.interactable = true
  end)
  self:refreshGunInfo()
  self:refreshAllProperty()
end
function UIBarrackLevelUpFinishDialog:OnCameraStart()
  return 0.01
end
function UIBarrackLevelUpFinishDialog:OnCameraBack()
  local isFullLevel = self.gunCmdData.IsFullLevel
  if isFullLevel then
    return BarrackHelper.CameraMgr:GetDuration(BarrackCameraOperate.SettlementToOverview)
  else
    return BarrackHelper.CameraMgr:GetAlmostEndDuration(BarrackCameraOperate.SettlementToUpgrade)
  end
end
function UIBarrackLevelUpFinishDialog:OnClose()
  if self.onCloseCallback then
    self.onCloseCallback()
  end
  self.onCloseCallback = nil
  self:ReleaseCtrlTable(self.itemViewTable, true)
  self.gunId = nil
  self.gunCmdData = nil
end
function UIBarrackLevelUpFinishDialog:OnRelease()
  self.ui = nil
  self.itemViewTable = nil
  self.super.OnRelease(self)
end
function UIBarrackLevelUpFinishDialog:onClickClose()
  local isFullLevel = self.gunCmdData.IsFullLevel
  if isFullLevel then
    UIManager.CloseUI(UIDef.UIBarrackTrainingPanel)
  else
    UIManager.CloseUI(self.mCSPanel)
  end
  if self.onCloseCallback then
    self.onCloseCallback()
  end
  self.onCloseCallback = nil
end
function UIBarrackLevelUpFinishDialog:refreshGunInfo()
  self.ui.mText_ChrName.text = self.gunCmdData.gunData.name.str
  self.ui.mText_NumBefore.text = self.gunCmdData.OldLevel
  self.ui.mText_NumNow.text = self.gunCmdData.level
end
function UIBarrackLevelUpFinishDialog:refreshAllProperty()
  local itemIndex = 1
  for i = DevelopProperty.None.value__ + 1, DevelopProperty.AllEnd.value__ - 1 do
    local propertyType = DevelopProperty.__CastFrom(i)
    if propertyType then
      local prevValue = PropertyUtils.GetBasePropertyValue(self.gunId, self.gunCmdData.OldLevel, propertyType)
      local curValue = PropertyUtils.GetBasePropertyValue(self.gunId, self.gunCmdData.level, propertyType)
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
