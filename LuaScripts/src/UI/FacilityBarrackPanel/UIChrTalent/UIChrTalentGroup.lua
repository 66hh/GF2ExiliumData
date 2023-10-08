require("UI.FacilityBarrackPanel.UIChrTalent.UIChrTalentSlot")
UIChrTalentGroup = class("UIChrTalentGroup", UIBaseCtrl)
function UIChrTalentGroup:ctor(slotGoTable)
  self.slotTable = self:initAllSlot(slotGoTable)
end
function UIChrTalentGroup:Init(gunTalentId, treeId, groupIndex)
  self.gunTalentId = gunTalentId
  self.treeId = treeId
  self.groupIndex = groupIndex
  self.treeData = TableData.listSquadTalentTreeDatas:GetDataById(self.treeId)
  local groupIdList = self.treeData.OpenPoijnt
  if groupIdList.Count == 1 then
    local midIndex = 2
    if midIndex <= #self.slotTable then
      local slot = self.slotTable[midIndex]
      slot:InitData(self.gunTalentId, self.treeId, groupIdList[0], self.groupIndex, midIndex)
    end
  elseif groupIdList.Count == 3 then
    for i = 0, groupIdList.Count - 1 do
      local slot = self.slotTable[i + 1]
      if i == 0 then
        slot:InitData(self.gunTalentId, self.treeId, groupIdList[1], self.groupIndex, i + 1)
      elseif i == 1 then
        slot:InitData(self.gunTalentId, self.treeId, groupIdList[0], self.groupIndex, i + 1)
      elseif i == 2 then
        slot:InitData(self.gunTalentId, self.treeId, groupIdList[2], self.groupIndex, i + 1)
      end
    end
  else
    gferror("UIChrTalentGroup 点数量错误:" .. groupIdList.Count)
  end
  self.isVisible = false
end
function UIChrTalentGroup:OnShow()
  for i = 1, #self.slotTable do
    local slot = self.slotTable[i]
    slot:OnShow()
  end
end
function UIChrTalentGroup:Refresh()
  for i = 1, #self.slotTable do
    local slot = self.slotTable[i]
    slot:Refresh()
  end
end
function UIChrTalentGroup:OnHide()
  for i = 1, #self.slotTable do
    local slot = self.slotTable[i]
    slot:OnHide()
  end
end
function UIChrTalentGroup:OnRelease(isDestroy)
  self.gunTalentId = nil
  self.groupIndex = nil
  self.treeId = nil
  self:ReleaseCtrlTable(self.slotTable, isDestroy)
  self.slotTable = nil
  self.isVisible = nil
  self.super.OnRelease(self, isDestroy)
end
function UIChrTalentGroup:AddSlotClickListener(slotClickCallback)
  self.slotClickCallback = slotClickCallback
end
function UIChrTalentGroup:GetGunTalentId()
  return self.gunTalentId
end
function UIChrTalentGroup:GetTreeData()
  return self.treeData
end
function UIChrTalentGroup:GetSlotByIndex(index)
  return self.slotTable[index]
end
function UIChrTalentGroup:GetAllSlotTable()
  return self.slotTable
end
function UIChrTalentGroup:SetAllSlotAlpha(value)
  for i, slot in pairs(self.slotTable) do
    slot:SetAlpha(value)
  end
end
function UIChrTalentGroup:SetVisible(visible)
  if self.isVisible == visible then
    return
  end
  for i, slot in pairs(self.slotTable) do
    slot:SetVisible(visible)
  end
  self.isVisible = visible
end
function UIChrTalentGroup:IsVisible()
  return self.isVisible
end
function UIChrTalentGroup:onClickSlot(newGroupIndex, newSlotIndex)
  if self.slotClickCallback then
    self.slotClickCallback(newGroupIndex, newSlotIndex)
  end
end
function UIChrTalentGroup:initAllSlot(slotGoTable)
  local slotTable = {}
  for i = 1, #slotGoTable do
    local slot = UIChrTalentSlot.New(slotGoTable[i], function(newGroupIndex, newSlotIndex)
      self:onClickSlot(newGroupIndex, newSlotIndex)
    end)
    table.insert(slotTable, slot)
  end
  return slotTable
end
