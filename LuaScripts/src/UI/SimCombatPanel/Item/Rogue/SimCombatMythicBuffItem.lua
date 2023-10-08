require("UI.UIBaseCtrl")
SimCombatMythicBuffItem = class("SimCombatMythicBuffItem", UIBaseCtrl)
local self = SimCombatMythicBuffItem
function SimCombatMythicBuffItem:ctor()
end
function SimCombatMythicBuffItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.rogueBuffData = nil
end
function SimCombatMythicBuffItem:SetData(rogueBuffData)
  self.rogueBuffData = rogueBuffData
  self.ui.mImg_Icon.sprite = IconUtils.GetRogueBuffIcon(self.rogueBuffData.IconPath)
  self.ui.mImg_QualityColor.color = TableData.GetGlobalGun_Quality_Color2(self.rogueBuffData.Quality)
end
function SimCombatMythicBuffItem:SetSelect(boolean)
  self.ui.mBtn_Self.interactable = not boolean
end
function SimCombatMythicBuffItem:OnRelease()
end
