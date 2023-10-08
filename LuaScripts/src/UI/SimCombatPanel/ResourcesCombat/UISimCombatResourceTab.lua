UISimCombatResourceTab = class("UISimCombatResourceTab", UIBaseCtrl)
function UISimCombatResourceTab:ctor(root)
  self:SetRoot(root.transform)
  self.ui = UIUtils.GetUIBindTable(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_SimCombatProfessionaItem.gameObject, function()
    self:onClickSelf()
  end)
  setactive(self.ui.mObj_RedPoint, false)
end
function UISimCombatResourceTab:SetData(simTypeId, tabIndex, onClickCallback)
  self.simTypeId = simTypeId
  self.simTypeData = TableDataBase.listSimCombatTypeDatas:GetDataById(self.simTypeId)
  self.tabIndex = tabIndex
  self.onClickCallback = onClickCallback
  self.isUnlock = self:checkUnlock()
  self.isOpen = self:checkOpen()
end
function UISimCombatResourceTab:Refresh()
  local canPlay = self.isUnlock and self.isOpen
  setactive(self.ui.mImage_DutyIcon, canPlay)
  setactive(self.ui.mTrans_Lock, not canPlay)
  if self.simTypeData.DutyId > 0 then
    local dutyData = TableData.listGunDutyDatas:GetDataById(self.simTypeData.DutyId)
    self.ui.mImage_DutyIcon.sprite = IconUtils.GetGunTypeWhiteIcon(dutyData.icon)
  else
    setactive(self.ui.mImage_DutyIcon, false)
  end
  self.ui.mText_Name.text = self.simTypeData.label_name.str
end
function UISimCombatResourceTab:OnRelease(isDestroy)
  self.simTypeData = nil
  self.tabIndex = nil
  self.isUnlock = nil
  self.isOpen = nil
  self.onClickCallback = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UISimCombatResourceTab:Select()
  self.ui.mBtn_SimCombatProfessionaItem.interactable = false
end
function UISimCombatResourceTab:Deselect()
  self.ui.mBtn_SimCombatProfessionaItem.interactable = true
end
function UISimCombatResourceTab:SetBtnEnable(enable)
  self.ui.mBtn_SimCombatProfessionaItem.enabled = enable
end
function UISimCombatResourceTab:IsInteractable()
  return self.ui.mBtn_SimCombatProfessionaItem.interactable
end
function UISimCombatResourceTab:GetSimTypeData()
  return self.simTypeData
end
function UISimCombatResourceTab:SetLineVisible(visible)
  setactivewithcheck(self.ui.mTrans_Line, visible)
end
function UISimCombatResourceTab:IsOpen()
  return self.isOpen
end
function UISimCombatResourceTab:IsUnlock()
  return self.isUnlock
end
function UISimCombatResourceTab:GetUnlockId()
  return self.simTypeData.unlock
end
function UISimCombatResourceTab:checkUnlock()
  return self.simTypeData.unlock == 0 or AccountNetCmdHandler:CheckSystemIsUnLock(self.simTypeData.unlock)
end
function UISimCombatResourceTab:checkOpen()
  return NetCmdSimulateBattleData:IsOpenTime(self.simTypeData.id)
end
function UISimCombatResourceTab:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback(self.tabIndex)
  end
end
