UISimCombatProTalentSlot = class("UISimCombatProTalentSlot", UIBaseCtrl)
UISimCombatProTalentSlot.State = {
  Unlock,
  NotCleared,
  Cleared
}
local self = UISimCombatProTalentSlot
function UISimCombatProTalentSlot:ctor(root)
  self.super.ctor(self)
  self:SetRoot(root.transform)
  self.ui = UIUtils.GetUIBindTable(root)
  self.animator = self:GetRootAnimator()
  UIUtils.AddBtnClickListener(self.ui.mBtn_Root.gameObject, function()
    self:onClickSelf()
  end)
  self.state = UISimCombatProTalentSlot.State.Unlock
end
function UISimCombatProTalentSlot:SetData(simDutyData, dutyId, index, onClickCallback)
  self.simDutyData = simDutyData
  self.dutyId = dutyId
  self.index = index
  self.onClickCallback = onClickCallback
end
function UISimCombatProTalentSlot:Refresh()
  self.recordData = NetCmdStageRecordData:GetStageRecordById(self.simDutyData.Id)
  self.stageData = TableData.listStageDatas:GetDataById(self.simDutyData.id)
  self.ui.mText_Num.text = self.simDutyData.Name.str
  self.ui.mImage_GunDuty.sprite = IconUtils.GetGunTypeWhiteIcon(self.dutyId)
  local isUnlock = self:IsUnlock()
  if isUnlock then
    self.ui.mCanvasGroup_GrpLine.alpha = 1
    local isDone = NetCmdSimulateBattleData:CheckStageIsUnLock(self.stageData.id)
    if isDone then
      self.ui.mText_State.text = TableData.GetHintById(103060)
      self.state = UISimCombatProTalentSlot.State.Cleared
    else
      self.ui.mText_State.text = TableData.GetHintById(103061)
      self.state = UISimCombatProTalentSlot.State.NotCleared
    end
  else
    self.ui.mCanvasGroup_GrpLine.alpha = 0.3
    self.ui.mText_State.text = TableData.GetHintById(103062)
    self.state = UISimCombatProTalentSlot.State.Unlock
  end
  self.animator:SetBool("Unlock", isUnlock)
  setactive(self.ui.mCanvasGroup_GrpLine, self.index ~= 1)
end
function UISimCombatProTalentSlot:OnRelease()
  self.animator = nil
  self.simDutyData = nil
  self.dutyId = nil
  self.index = nil
  self.onClickCallback = nil
  self.recordData = nil
  self.stageData = nil
end
function UISimCombatProTalentSlot:Select()
  self.ui.mBtn_Root.interactable = false
end
function UISimCombatProTalentSlot:Deselect()
  self.ui.mBtn_Root.interactable = true
end
function UISimCombatProTalentSlot:GetSimDutyData()
  return self.simDutyData
end
function UISimCombatProTalentSlot:GetStageData()
  return self.stageData
end
function UISimCombatProTalentSlot:GetRecordData()
  return self.recordData
end
function UISimCombatProTalentSlot:GetSlotIndex()
  return self.index
end
function UISimCombatProTalentSlot:GetState()
  return self.state
end
function UISimCombatProTalentSlot:IsUnlock()
  return self.simDutyData.unlock_detail == 0 or NetCmdSimulateBattleData:CheckStageIsUnLock(self.simDutyData.unlock_detail) and AccountNetCmdHandler:GetLevel() >= self.simDutyData.unlock_level
end
function UISimCombatProTalentSlot:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback(self.index, self.simDutyData)
  end
end
