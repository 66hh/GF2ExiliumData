require("UI.UIBaseCtrl")
SimCombatMythicStoreTabContentItem = class("SimCombatMythicStoreTabContentItem", UIBaseCtrl)
local self = SimCombatMythicStoreTabContentItem
function SimCombatMythicStoreTabContentItem:ctor()
end
function SimCombatMythicStoreTabContentItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  self.rogueShopTypeDescData = nil
end
function SimCombatMythicStoreTabContentItem:SetData(rogueShopTypeDescData)
  self.rogueShopTypeDescData = rogueShopTypeDescData
  self.ui.mText_Name.text = rogueShopTypeDescData.Name
  self.ui.mText_RandomNum.text = UIUtils.GetRandomNum3()
end
function SimCombatMythicStoreTabContentItem:OnRelease()
  self:DestroySelf()
end
