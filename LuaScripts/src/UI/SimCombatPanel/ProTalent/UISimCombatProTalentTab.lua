UISimCombatProTalentTab = class("UISimCombatProTalentTab", UIBaseCtrl)
function UISimCombatProTalentTab:ctor(root)
  self.super.ctor(self)
  self:SetRoot(root.transform)
  self.ui = UIUtils.GetUIBindTable(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_SimCombatProfessionaItem.gameObject, function()
    self:onClickSelf()
  end)
  setactive(self.ui.mObj_RedPoint, false)
end
function UISimCombatProTalentTab:SetData(simTypeData, tabIndex, onClickCallback, parentPanel)
  self.simTypeData = simTypeData
  self.tabIndex = tabIndex
  self.onClickCallback = onClickCallback
  self.parentPanel = parentPanel
end
function UISimCombatProTalentTab:Refresh()
  self.isUnlock = self:checkUnlock()
  self.isOpen = self:checkOpen()
  local interactable = self.isUnlock and self.isOpen
  setactive(self.ui.mImage_DutyIcon, interactable)
  setactive(self.ui.mTrans_Lock, not interactable)
  local dutyData = TableData.listGunDutyDatas:GetDataById(self.simTypeData.DutyId)
  self.ui.mImage_DutyIcon.sprite = IconUtils.GetGunTypeWhiteIcon(dutyData.icon)
  self.ui.mText_Name.text = self.simTypeData.label_name.str
end
function UISimCombatProTalentTab:OnRelease()
  self.simTypeData = nil
  self.tabIndex = nil
  self.onClickCallback = nil
  self.parentPanel = nil
  self.ui = nil
end
function UISimCombatProTalentTab:Select()
  self.ui.mBtn_SimCombatProfessionaItem.interactable = false
end
function UISimCombatProTalentTab:Deselect()
  self.ui.mBtn_SimCombatProfessionaItem.interactable = true
end
function UISimCombatProTalentTab:GetSimTypeData()
  return self.simTypeData
end
function UISimCombatProTalentTab:IsOpen()
  return self.isOpen
end
function UISimCombatProTalentTab:IsUnlock()
  return self.isUnlock
end
function UISimCombatProTalentTab:GetUnlockId()
  return self.simTypeData.unlock
end
function UISimCombatProTalentTab:checkUnlock()
  return self.simTypeData.unlock == 0 or AccountNetCmdHandler:CheckSystemIsUnLock(self.simTypeData.unlock)
end
function UISimCombatProTalentTab:checkOpen()
  local args = NetCmdSimulateBattleData.PlanData.Args
  for j = 0, args.Count - 1 do
    if self.simTypeData.id == args[j] then
      return true
    end
  end
  return false
end
function UISimCombatProTalentTab:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback(self.tabIndex)
  end
end
