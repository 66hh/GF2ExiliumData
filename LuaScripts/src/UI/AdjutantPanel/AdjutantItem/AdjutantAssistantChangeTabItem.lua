require("UI.UIBaseCtrl")
AdjutantAssistantChangeTabItem = class("AdjutantAssistantChangeTabItem", UIBaseCtrl)
local self = AdjutantAssistantChangeTabItem
function AdjutantAssistantChangeTabItem:ctor()
end
function AdjutantAssistantChangeTabItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.pos = 0
end
function AdjutantAssistantChangeTabItem:SetData(index)
  self.pos = index
end
function AdjutantAssistantChangeTabItem:SetSelected(boolean)
  self.ui.mBtn_Self.interactable = not boolean
end
function AdjutantAssistantChangeTabItem:OnRelease()
  self:DestroySelf()
end
