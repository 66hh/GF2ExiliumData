require("UI.UIBaseCtrl")
UIDarkZoneWishDetailItem = class("UIDarkZoneWishDetailItem", UIBaseCtrl)
UIDarkZoneWishDetailItem.__index = UIDarkZoneWishDetailItem
function UIDarkZoneWishDetailItem:__InitCtrl()
end
function UIDarkZoneWishDetailItem:InitCtrl(root)
  if root == nil then
    return
  end
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem)
  CS.LuaUIUtils.SetParent(obj.gameObject, root.gameObject, true)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
  self.typeDescItemList = {}
  for i = 1, 4 do
    self.typeDescItemList[i] = UIDarkZoneWishTypeDescItem.New()
    local item = self.typeDescItemList[i]
    item:InitCtrl(self.ui.mTrans_InfoItem, self.ui.mTrans_Info)
    item:SetData(i)
    item:CancelHighLight()
  end
end
function UIDarkZoneWishDetailItem:SetData(id)
  self.mData = TableData.listDarkzoneWishDatas:GetDataById(id)
end
function UIDarkZoneWishDetailItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.super.OnRelease(self, true)
end
