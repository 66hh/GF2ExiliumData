require("UI.UIBaseCtrl")
DZCraftDialogLeftTabItem = class("DZCraftDialogLeftTabItem", UIBaseCtrl)
DZCraftDialogLeftTabItem.__index = DZCraftDialogLeftTabItem
function DZCraftDialogLeftTabItem:__InitCtrl()
end
function DZCraftDialogLeftTabItem:InitCtrl(root)
  local com = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(obj, true)
end
function DZCraftDialogLeftTabItem:SetData(Data, func, needShowNew)
  self.mData = Data
  self.clickFunc = func
  self.ui.mText_Title.text = self.mData.name.str
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponPartIconSprite(self.mData.icon)
  setactive(self.ui.mTrans_New, needShowNew == true)
  self.ui.mBtn_Self.onClick:AddListener(function()
    self:ClickFunction()
  end)
end
function DZCraftDialogLeftTabItem:ClickFunction()
  if self.clickFunc then
    self.clickFunc(self)
  end
end
function DZCraftDialogLeftTabItem:OnClose()
  self.super.DestroySelf(self)
  self.ui = nil
  self.mData = nil
  self.clickFunc = nil
end
