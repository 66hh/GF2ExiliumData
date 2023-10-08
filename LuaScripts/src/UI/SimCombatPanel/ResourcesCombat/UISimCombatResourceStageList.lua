require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourceStageSlot")
UISimCombatResourceStageList = class("UISimCombatResourceStageList", UIBaseCtrl)
function UISimCombatResourceStageList:ctor(root)
  self.super.ctor(self)
  self:SetRoot(root.transform)
  self.ui = UIUtils.GetUIBindTable(root)
  function self.ui.mVirtualList_Stage.itemProvider()
    return self:stageSlotProvider()
  end
  function self.ui.mVirtualList_Stage.itemRenderer(index, renderData)
    self:stageSlotRenderer(index, renderData)
  end
  self.ui.mVirtualList_Stage:SetConstraintCount(1)
end
function UISimCombatResourceStageList:SetData(simTypeId, jumpSlotResourceId, isOpenDay, fromState)
  self.simTypeId = simTypeId
  self.isOpenDay = isOpenDay
  self.slotTable = self:initAllSlot()
  self.curSlotIndex = -1
  local targetSlotIndex = self:getSlotIndex(jumpSlotResourceId) or self:AutoSelectLastActiveSlot(fromState)
  self:onClickSlot(targetSlotIndex)
end
function UISimCombatResourceStageList:Refresh()
  if self.slotTable == nil then
    return
  end
  self.ui.mVirtualList_Stage:KillAllFade(false)
  self.ui.mVirtualList_Stage.OnRectTransformDimensionsChangeEnabled = true
  self.ui.mVirtualList_Stage.numItems = #self.slotTable
  self.ui.mVirtualList_Stage:Refresh()
end
function UISimCombatResourceStageList:OnClose()
  self.ui.mVirtualList_Stage.OnRectTransformDimensionsChangeEnabled = false
  self:ReleaseCtrlTable(self.slotTable, false)
  self.slotTable = nil
  self.curSlotIndex = nil
  self.isOpenDay = nil
end
function UISimCombatResourceStageList:OnRelease()
  self.simTypeId = nil
  self.curSlotIndex = nil
  self:ReleaseCtrlTable(self.slotTable, false)
  self.slotTable = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UISimCombatResourceStageList:AddSelectSlotListener(callback)
  self.onClickSlotCallback = callback
end
function UISimCombatResourceStageList:AutoSelectLastActiveSlot(fromState)
  local lastActiveSlotIndex = 1
  if fromState == UISimCombatGlobal.FromState.OnBack or fromState == UISimCombatGlobal.FromState.OnTop then
    lastActiveSlotIndex = self:getLastActiveSlotIndex()
  elseif fromState == UISimCombatGlobal.FromState.OnRecover and self.simTypeId == 17 then
    lastActiveSlotIndex = self:getLastActiveSlotIndexByCache()
  else
    lastActiveSlotIndex = self:getLastActiveSlotIndex()
  end
  self:onClickSlot(lastActiveSlotIndex)
  self:scrollToCurSlotIndex()
end
function UISimCombatResourceStageList:JumpTo(simCombatResourceId)
  local jumpSlotIndex = self:getSlotIndex(simCombatResourceId)
  self:onClickSlot(jumpSlotIndex)
end
function UISimCombatResourceStageList:SetVisible(visible)
  self.super.SetVisible(self, visible)
  if visible then
    self:scrollToCurSlotIndex()
  end
end
function UISimCombatResourceStageList:onClickSlot(slotIndex)
  if not slotIndex or self.curSlotIndex == slotIndex then
    return
  end
  if slotIndex <= 0 or slotIndex > #self.slotTable then
    return
  end
  local prevSlotIndex = self.curSlotIndex
  self.curSlotIndex = slotIndex
  self:onSwitchedSelectSlotAfter(prevSlotIndex, self.curSlotIndex)
end
function UISimCombatResourceStageList:initAllSlot()
  local simResourceDataList = NetCmdSimulateBattleData:GetSimResourceDataList(self.simTypeId)
  if simResourceDataList == nil then
    return
  end
  local tempSlotTable = {}
  local simTypeData = TableDataBase.listSimCombatTypeDatas:GetDataById(self.simTypeId)
  for i = 0, simResourceDataList.Count - 1 do
    local stageSlot = UISimCombatResourceStageSlot.New()
    stageSlot:SetData(simTypeData, simResourceDataList[i], i + 1, function(slotIndex)
      self:onClickSlot(slotIndex)
    end, self.isOpenDay)
    table.insert(tempSlotTable, stageSlot)
  end
  return tempSlotTable
end
function UISimCombatResourceStageList:onSwitchedSelectSlotAfter(prevSlotIndex, curSlotIndex)
  local slot = self:getCurSlot()
  local simResourceData = slot:GetSimCombatResourceData()
  self.ui.mVirtualList_Stage:RefreshItemByIndex(prevSlotIndex - 1)
  self.ui.mVirtualList_Stage:RefreshItemByIndex(curSlotIndex - 1)
  if self.onClickSlotCallback then
    self.onClickSlotCallback(simResourceData, self.isOpenDay)
  end
end
function UISimCombatResourceStageList:scrollToCurSlotIndex()
  self:scrollTo(self.curSlotIndex)
end
function UISimCombatResourceStageList:scrollTo(index)
  if not index then
    return
  end
  local targetIndex = index - 2
  if targetIndex < 0 then
    targetIndex = 0
  end
  TimerSys:DelayFrameCall(2, function(data)
    self.ui.mVirtualList_Stage:DelayScrollToPosByIndex(targetIndex, false)
  end)
end
function UISimCombatResourceStageList:getPreSlot(index)
  local targetIndex = index - 1
  if targetIndex < 1 or targetIndex > #self.slotTable then
    return nil
  end
  return self.slotTable[targetIndex]
end
function UISimCombatResourceStageList:checkStageRecordPass(stageId)
  local stageRecord = NetCmdStageRecordData:GetStageRecordById(stageId, false)
  if stageRecord ~= nil and stageRecord.first_pass_time > 0 then
    return true
  end
  return false
end
function UISimCombatResourceStageList:getCurSlot()
  return self.slotTable[self.curSlotIndex]
end
function UISimCombatResourceStageList:getLastActiveSlotIndexByCache()
  for i = #self.slotTable, 1, -1 do
    local slot = self.slotTable[i]
    if slot.simCombatResourceData.Id == UISimCombatGlobal.CachedSlotStageId then
      return i
    end
  end
  return 1
end
function UISimCombatResourceStageList:getLastActiveSlotIndex()
  for i = #self.slotTable, 1, -1 do
    local slot = self.slotTable[i]
    if slot:GetState() == UISimCombatGlobal.SlotState.NotCleared then
      return i
    end
  end
  return 1
end
function UISimCombatResourceStageList:getSlotIndex(simCombatResourceId)
  if not simCombatResourceId then
    return nil
  end
  if simCombatResourceId == 0 then
    for i = #self.slotTable, 1, -1 do
      local slot = self.slotTable[i]
      if slot:GetState() == UISimCombatGlobal.SlotState.NotCleared then
        return i
      end
    end
  else
    for i, slot in pairs(self.slotTable) do
      if slot:GetSimCombatResourceData().id == simCombatResourceId then
        return i
      end
    end
  end
  return nil
end
function UISimCombatResourceStageList:stageSlotProvider()
  local stageSlotTemplate = self.ui.mScrollListChild_StageSlot.childItem
  local stageSlotTrans = UIUtils.InstantiateByTemplate(stageSlotTemplate, self.ui.mScrollListChild_StageSlot.transform)
  stageSlotTrans.position = vectorone * 1000
  local renderDataItem = RenderDataItem()
  renderDataItem.renderItem = stageSlotTrans.gameObject
  renderDataItem.data = nil
  return renderDataItem
end
function UISimCombatResourceStageList:stageSlotRenderer(index, renderData)
  local slot = self.slotTable[index + 1]
  local go = renderData.renderItem
  slot:SetRoot(go.transform)
  if slot:GetIndex() == self.curSlotIndex then
    slot:Select()
  else
    slot:Deselect()
  end
  slot:Refresh()
end
