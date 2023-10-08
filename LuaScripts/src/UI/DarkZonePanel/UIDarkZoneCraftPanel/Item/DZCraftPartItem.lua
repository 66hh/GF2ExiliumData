require("UI.UIBaseCtrl")
DZCraftPartItem = class("DZCraftPartItem", UIBaseCtrl)
DZCraftPartItem.__index = DZCraftPartItem
function DZCraftPartItem:__InitCtrl()
end
function DZCraftPartItem:InitCtrl(root)
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
function DZCraftPartItem:SetData(Data)
  self.mData = TableData.listWeaponModTypeDatas:GetDataById(Data)
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponPartIconSprite(self.mData.icon)
end
function DZCraftPartItem:OnClose()
  self:DestroySelf()
  self.mData = nil
  self.ui = nil
end
