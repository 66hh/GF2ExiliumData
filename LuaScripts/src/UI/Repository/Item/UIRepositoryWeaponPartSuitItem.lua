require("UI.UIBaseCtrl")
UIRepositoryWeaponPartSuitItem = class("UIRepositoryWeaponPartSuitItem", UIBaseCtrl)
UIRepositoryWeaponPartSuitItem.__index = UIRepositoryWeaponPartSuitItem
function UIRepositoryWeaponPartSuitItem:__InitCtrl()
end
function UIRepositoryWeaponPartSuitItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self.mIsSelect = false
  self:LuaUIBindTable(obj, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickFunction()
  end
end
function UIRepositoryWeaponPartSuitItem:SetData(data)
  self.ui.mText_Name.text = data
end
function UIRepositoryWeaponPartSuitItem:SetSelectState(isSelect)
  self.mIsSelect = isSelect
  self.ui.mBtn_Self.interactable = not isSelect
end
function UIRepositoryWeaponPartSuitItem:SetClickFunction(callback)
  self.clickFunction = callback
end
function UIRepositoryWeaponPartSuitItem:OnClickFunction()
  if self.mIsSelect == true then
    return
  end
  if self.clickFunction then
    self.clickFunction()
  end
end
function UIRepositoryWeaponPartSuitItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.mIsSelect = nil
  self.clickFunction = nil
  self:DestroySelf()
end
