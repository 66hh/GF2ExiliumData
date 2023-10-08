require("UI.UIBaseCtrl")
UIDarkZoneWishDescribeItem = class("UIDarkZoneWishDescribeItem", UIBaseCtrl)
UIDarkZoneWishDescribeItem.__index = UIDarkZoneWishDescribeItem
function UIDarkZoneWishDescribeItem:__InitCtrl()
end
function UIDarkZoneWishDescribeItem:InitCtrl(root)
  if root == nil then
    return
  end
  local itemPrefab = root:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(itemPrefab.childItem, root)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
end
function UIDarkZoneWishDescribeItem:SetData(id)
  self:SetActive(true)
  self.mData = TableData.listDarkzoneWishDatas:GetDataById(id)
  self.ui.mText_Name.text = self.mData.name.str
  self.ui.mTextFit_Description.text = self.mData.des.str
end
function UIDarkZoneWishDescribeItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.super.OnRelease(self, true)
end
