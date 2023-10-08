require("UI.UIBaseCtrl")
UIRepositoryPublicTabItem = class("UIRepositoryPublicTabItem", UIBaseCtrl)
UIRepositoryPublicTabItem.__index = UIRepositoryPublicTabItem
function UIRepositoryPublicTabItem:__InitCtrl()
end
function UIRepositoryPublicTabItem:InitCtrl(parent)
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
function UIRepositoryPublicTabItem:SetData(name)
  self.ui.mText_Name.text = name
end
function UIRepositoryPublicTabItem:SetRedPoint(enable)
  setactive(self.ui.mTrans_RedPoint, enable)
end
function UIRepositoryPublicTabItem:SetSelectState(isSelect)
  self.mIsSelect = isSelect
  self.ui.mBtn_Self.interactable = not isSelect
end
function UIRepositoryPublicTabItem:SetClickFunction(callback)
  self.clickFunction = callback
end
function UIRepositoryPublicTabItem:OnClickFunction()
  if self.mIsSelect == true then
    return
  end
  if self.clickFunction then
    self.clickFunction()
  end
end
function UIRepositoryPublicTabItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.mIsSelect = nil
  self.clickFunction = nil
  self:DestroySelf()
end
