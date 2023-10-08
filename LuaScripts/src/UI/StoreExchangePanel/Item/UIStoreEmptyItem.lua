require("UI.UIBaseCtrl")
UIStoreEmptyItem = class("UIStoreEmptyItem", UIBaseCtrl)
UIStoreEmptyItem.__index = UIStoreEmptyItem
function UIStoreEmptyItem:__InitCtrl()
end
function UIStoreEmptyItem:InitCtrl(parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComItemAddItemV2.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
end
