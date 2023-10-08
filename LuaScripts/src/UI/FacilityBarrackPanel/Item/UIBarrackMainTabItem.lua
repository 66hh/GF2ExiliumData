require("UI.UIBaseCtrl")
UIBarrackMainTabItem = class("UIBarrackMainTabItem", UIBaseCtrl)
UIBarrackMainTabItem.__index = UIBarrackMainTabItem
function UIBarrackMainTabItem:__InitCtrl()
  self.mBtn = self:GetSelfButton()
end
function UIBarrackMainTabItem:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, false)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj.transform, self.ui)
  self:__InitCtrl()
end
function UIBarrackMainTabItem:InitObj(obj)
  self:SetRoot(obj.transform)
  self:__InitCtrl()
end
function UIBarrackMainTabItem:SetData(data)
  if data then
    self.type = data.id
    if data.id ~= 0 then
      self.ui.mImage_Icon.sprite = IconUtils.GetGunTypeIcon(data.icon .. "_W")
      self.ui.mText_Name.text = data.name.str
    else
      self.ui.mText_Name.text = TableData.GetHintById(101006)
    end
    UIUtils.SetInteractive(self.mUIRoot, true)
  else
    UIUtils.SetInteractive(self.mUIRoot, false)
  end
end
function UIBarrackMainTabItem:OnRelease()
  gfdestroy(self.mUIRoot.gameObject)
  self.super.OnRelease(self)
end
