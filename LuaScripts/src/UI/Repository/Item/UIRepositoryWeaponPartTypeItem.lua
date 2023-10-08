require("UI.UIBaseCtrl")
UIRepositoryWeaponPartTypeItem = class("UIRepositoryWeaponPartTypeItem", UIBaseCtrl)
UIRepositoryWeaponPartTypeItem.__index = UIRepositoryWeaponPartTypeItem
function UIRepositoryWeaponPartTypeItem:__InitCtrl()
end
function UIRepositoryWeaponPartTypeItem:InitCtrl(parent)
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
function UIRepositoryWeaponPartTypeItem:SetData(name)
  self.ui.mText_Normal.text = name
  self.ui.mText_Select.text = name
end
function UIRepositoryWeaponPartTypeItem:SetSelectState(isSelect)
  self.mIsSelect = isSelect
  self.ui.mBtn_Self.interactable = not isSelect
end
function UIRepositoryWeaponPartTypeItem:SetClickFunction(callback)
  self.clickFunction = callback
end
function UIRepositoryWeaponPartTypeItem:OnClickFunction()
  if self.mIsSelect == true then
    return
  end
  if self.clickFunction then
    self.clickFunction()
  end
  self:SetSelectState(true)
end
function UIRepositoryWeaponPartTypeItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.mIsSelect = nil
  self.clickFunction = nil
  self:DestroySelf()
end
