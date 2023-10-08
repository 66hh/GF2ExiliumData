require("UI.UIBaseCtrl")
UIDarkZoneWishTypeDescItem = class("UIDarkZoneWishTypeDescItem", UIBaseCtrl)
UIDarkZoneWishTypeDescItem.__index = UIDarkZoneWishTypeDescItem
function UIDarkZoneWishTypeDescItem:__InitCtrl()
end
function UIDarkZoneWishTypeDescItem:InitCtrl(obj, root)
  if root == nil then
    return
  end
  local obj = instantiate(obj, root)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.hitNum = 240037
end
function UIDarkZoneWishTypeDescItem:SetData(index)
  self:SetActive(true)
  self.ui.mText_Normal.text = TableData.GetHintById(self.hitNum + index)
end
function UIDarkZoneWishTypeDescItem:CancelHighLight()
  setactive(self.ui.mTrans_UP, false)
  setactive(self.ui.mTrans_Normal, true)
end
function UIDarkZoneWishTypeDescItem:SetHighLight(str)
  setactive(self.ui.mTrans_UP, true)
  setactive(self.ui.mTrans_Normal, false)
  self.ui.mText_Up.text = str
end
function UIDarkZoneWishTypeDescItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.super.OnRelease(self, true)
end
