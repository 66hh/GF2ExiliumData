require("UI.UIBaseCtrl")
DZNewStoreAttributeItem = class("DZNewStoreAttributeItem", UIBaseCtrl)
DZNewStoreAttributeItem.__index = DZNewStoreAttributeItem
function DZNewStoreAttributeItem:__InitCtrl()
end
function DZNewStoreAttributeItem:InitCtrl(root, prefab)
  local obj = instantiate(prefab)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(obj, true)
end
function DZNewStoreAttributeItem:SetData(str)
  self.ui.mText_Name.text = str
end
