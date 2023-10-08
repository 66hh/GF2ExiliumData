UISimCombatResourceStageSlot = class("UISimCombatResourceStageSlot", UIBaseCtrl)
function UISimCombatResourceStageSlot:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_Root.gameObject, function()
    self:onClickSelf()
  end)
  self.super.SetRoot(self, root.transform)
end
function UISimCombatResourceStageSlot:SetData(simCombatTypeData, simCombatResourceData, index, onClickCallback, isOpenDay)
  self.simCombatTypeData = simCombatTypeData
  self.simCombatResourceData = simCombatResourceData
  self.index = index
  self.onClickCallback = onClickCallback
  self.isOpenDay = isOpenDay
  self.recordData = NetCmdStageRecordData:GetStageRecordById(self.simCombatResourceData.Id)
  self.stageData = TableData.listStageDatas:GetDataById(self.simCombatResourceData.id)
  local isUnlock = self:IsUnlock()
  if isUnlock then
    local isDone = NetCmdSimulateBattleData:CheckStageIsUnLock(self.stageData.id)
    if isDone then
      self.state = UISimCombatGlobal.SlotState.Cleared
    else
      self.state = UISimCombatGlobal.SlotState.NotCleared
    end
  else
    self.state = UISimCombatGlobal.SlotState.Unlock
  end
end
function UISimCombatResourceStageSlot:Refresh()
  self.ui.mText_Name.text = self.stageData.name.str
  self.ui.mText_Num.text = self.simCombatResourceData.name.str
  local isUnlock = self:IsUnlock()
  local isOpenDay = self.isOpenDay
  local canPlay = isUnlock and isOpenDay
  if canPlay then
    self.ui.mText_LV.text = TableData.GetHintById(803, self.stageData.recommanded_playerlevel)
  elseif isOpenDay then
    local prevStageIsPassed = NetCmdSimulateBattleData:PrevStageIsPassed(self.simCombatResourceData)
    local isUnlockedByCommandLevel = NetCmdSimulateBattleData:IsUnlockedByCommandLevel(self.simCombatResourceData)
    if not prevStageIsPassed and not isUnlockedByCommandLevel then
      self.ui.mText_LV.text = TableData.GetHintById(103156) .. TableData.GetHintById(103157) .. TableData.GetHintById(103158, self.simCombatResourceData.unlock_level) .. TableData.GetHintById(103159)
    elseif not prevStageIsPassed then
      self.ui.mText_LV.text = TableData.GetHintById(103156) .. TableData.GetHintById(103159)
    elseif not isUnlockedByCommandLevel then
      self.ui.mText_LV.text = TableData.GetHintById(103158, self.simCombatResourceData.unlock_level) .. TableData.GetHintById(103159)
    end
  else
    self.ui.mText_LV.text = NetCmdSimulateBattleData:GetOpenTimeText(self.simCombatTypeData.id)
  end
  self.ui.mImage_Bg.sprite = IconUtils.GetAtlasSprite(self.simCombatTypeData.bg)
  local maxPoint = NetCmdStageRatingData:GetCashPoint(self.stageData.id)
  local maxPointVisible = isUnlock and 0 < maxPoint
  if maxPointVisible then
    self.ui.mText_MaxPoint.text = maxPoint
  end
  setactivewithcheck(self.ui.mTrans_MaxPoint, maxPointVisible)
  setactivewithcheck(self.ui.mTrans_GrpNum, canPlay)
  setactivewithcheck(self.ui.mTrans_GrpLocked, not canPlay)
end
function UISimCombatResourceStageSlot:OnRelease(isDestroy)
  self.isOpenDay = nil
  self.simCombatTypeData = nil
  self.simCombatResourceData = nil
  self.viewIndex = nil
  self.index = nil
  self.onClickCallback = nil
  self.recordData = nil
  self.stageData = nil
  self.state = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UISimCombatResourceStageSlot:Select()
  self.ui.mBtn_Root.interactable = false
end
function UISimCombatResourceStageSlot:Deselect()
  self.ui.mBtn_Root.interactable = true
end
function UISimCombatResourceStageSlot:GetSimCombatResourceData()
  return self.simCombatResourceData
end
function UISimCombatResourceStageSlot:GetStageData()
  return self.stageData
end
function UISimCombatResourceStageSlot:GetRecordData()
  return self.recordData
end
function UISimCombatResourceStageSlot:GetIndex()
  return self.index
end
function UISimCombatResourceStageSlot:GetState()
  return self.state
end
function UISimCombatResourceStageSlot:IsUnlock()
  return (self.simCombatResourceData.unlock_detail == 0 or NetCmdSimulateBattleData:CheckStageIsUnLock(self.simCombatResourceData.unlock_detail)) and AccountNetCmdHandler:GetLevel() >= self.simCombatResourceData.unlock_level
end
function UISimCombatResourceStageSlot:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback(self.index, self.simCombatResourceData)
  end
end
