require("UI.UIDarkMainPanelInGame.UIDarkBubbleMsgSlot")
UIDarkBubbleMsgCtrl = class("UIDarkBubbleMsgCtrl", UIBaseCtrl)
function UIDarkBubbleMsgCtrl:ctor()
  self.activeSlotTable = {}
  self.hideSlotTable = {}
end
function UIDarkBubbleMsgCtrl:SetRoot(root)
  self.slotRoot = root
end
function UIDarkBubbleMsgCtrl:Show(text, time)
  local slot = self:getBubbleMsgSlot()
  slot:SetData(text, time)
  slot:Show()
end
function UIDarkBubbleMsgCtrl:Hide()
  for i, slot in ipairs(self.activeSlotTable) do
    slot:FinishHide()
  end
end
function UIDarkBubbleMsgCtrl:Release()
  self:ReleaseCtrlTable(self.activeSlotTable)
  self:ReleaseCtrlTable(self.hideSlotTable)
  self.activeSlotTable = nil
  self.hideSlotTable = nil
end
function UIDarkBubbleMsgCtrl:getBubbleMsgSlot()
  local hideCount = #self.hideSlotTable
  if hideCount == 0 then
    local activeCount = #self.activeSlotTable
    if activeCount == 0 then
      local root = self.slotRoot
      local slot = UIDarkBubbleMsgSlot.New()
      slot:SetRoot(root)
      slot:AddHideEndListener(function(selfSlot)
        self:onSlotHide(selfSlot)
      end)
      local index = hideCount + 1
      slot:SetIndex(index)
      table.insert(self.hideSlotTable, index, slot)
    else
      self:Hide()
    end
  end
  if #self.hideSlotTable == 0 then
    gferror("数量不足")
    return
  end
  local slot = table.remove(self.hideSlotTable, #self.hideSlotTable)
  table.insert(self.activeSlotTable, slot)
  return slot
end
function UIDarkBubbleMsgCtrl:onSlotHide(slot)
  table.remove(self.activeSlotTable, slot:GetIndex())
  table.insert(self.hideSlotTable, slot)
end
