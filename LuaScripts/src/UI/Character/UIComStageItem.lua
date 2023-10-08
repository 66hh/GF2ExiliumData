UIComStageItem = class("UIComStageItem", UIBaseCtrl)
UIComStageItem.__index = UIComStageItem
function UIComStageItem:ctor()
  UIComStageItem.super.ctor(self)
  self.Trans_Off = nil
  self.Trans_On = nil
end
function UIComStageItem:InitCtrl(parent, useScrollListChild, obj)
  if obj ~= nil then
    self.prefab = obj
  elseif useScrollListChild then
    local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
    self.prefab = instantiate(itemPrefab.childItem)
  else
    self.prefab = ResSys:GetUIGizmos("UICommonFramework/ComStageItem.prefab")
  end
  if parent then
    CS.LuaUIUtils.SetParent(self.prefab.gameObject, parent.gameObject, true)
  end
  self:SetRoot(self.prefab.transform)
  self.Trans_Off = self.mUIRoot:Find("Trans_Off")
  self.Trans_On = self.mUIRoot:Find("Trans_On")
  self:SetActive(false)
end
function UIComStageItem:SetActive(enabled)
  setactive(self.Trans_On, enabled)
end
function UIComStageItem:Release()
  ResourceManager:DestroyInstance(self.prefab.gameObject)
end
