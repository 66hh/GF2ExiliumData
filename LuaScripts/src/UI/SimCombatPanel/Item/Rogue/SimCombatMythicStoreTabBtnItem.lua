require("UI.UIBaseCtrl")
SimCombatMythicStoreTabBtnItem = class("SimCombatMythicStoreTabBtnItem", UIBaseCtrl)
local self = SimCombatMythicStoreTabBtnItem
function SimCombatMythicStoreTabBtnItem:ctor()
end
function SimCombatMythicStoreTabBtnItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.rogueStoreTabBtn = nil
  self.rogueStoreTabBtnType = nil
end
function SimCombatMythicStoreTabBtnItem:SetData(data)
  self.rogueStoreTabBtn = data
  self.ui.mText_Name.text = TableData.GetHintById(data.HintId)
  self.rogueStoreTabBtnType = data.BtnType
end
function SimCombatMythicStoreTabBtnItem:OnRelease()
end
