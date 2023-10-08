require("UI.UIBaseCtrl")
DZCarryItem = class("DZCarryItem", UIBaseCtrl)
DZCarryItem.__index = DZCarryItem
function DZCarryItem:__InitCtrl()
end
function DZCarryItem:InitCtrl(root, prefab)
  local obj = instantiate(prefab)
  if root then
    CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  end
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  setactive(obj, true)
end
function DZCarryItem:SetBackGround(Num)
  self.ui.mImg_Icon.sprite = ResSys:GetUIResAIconSprite("Darkzone" .. "/" .. "icon_Darkzone_Equip_" .. Num .. ".png")
end
function DZCarryItem:SetData(Data, Num)
  setactive(self.ui.mTrans_Empty, false)
  self.GrpEquipItem = UICommonItem.New()
  self.GrpEquipItem:InitCtrl(self.ui.mTrans_Item)
  self.GrpEquipItem:SetItemByStcData(Data, Num)
end
