UIQuestSubPanelBase = class("UIQuestSubPanelBase", UIBasePanel)
function UIQuestSubPanelBase:ctor(go)
end
function UIQuestSubPanelBase:Show()
  self:SetVisible(true)
end
function UIQuestSubPanelBase:OnPanelBack()
end
function UIQuestSubPanelBase:OnDialogBack()
end
function UIQuestSubPanelBase:Hide()
  self:SetVisible(false)
end
function UIQuestSubPanelBase:Release()
  self.ui = nil
end
function UIQuestSubPanelBase:Refresh()
end
function UIQuestSubPanelBase:GetTaskTypeId()
  return -1
end
function UIQuestSubPanelBase:GetAnimPageSwitchInt()
  return -1
end
