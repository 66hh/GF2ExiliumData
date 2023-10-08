require("UI.UIBaseCtrl")
UIDarkZoneWishSelectItem = class("UIDarkZoneWishSelectItem", UIBaseCtrl)
UIDarkZoneWishSelectItem.__index = UIDarkZoneWishSelectItem
function UIDarkZoneWishSelectItem:__InitCtrl()
end
function UIDarkZoneWishSelectItem:InitCtrl(root)
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
  self.itemData = nil
  self.clickFunction = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    if self.clickFunction then
      self.clickFunction()
    end
  end
end
function UIDarkZoneWishSelectItem:SetData(data)
  self.mData = data
  local id = self.mData.id
  self.itemData = TableData.GetItemData(self.mData.id)
  self.ui.mImage_Icon.sprite = IconUtils.GetItemIconSprite(id)
  self.ui.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.rank)
  self.ui.mImage_Rank2.color = TableData.GetGlobalGun_Quality_Color2(self.itemData.rank, self.ui.mImage_Rank2.color.a)
  self.itemOwn = 0
  self.itemOwn = DarkZoneNetRepositoryData:GetItemNum(id)
  self.ui.mText_Num.text = self.itemOwn
end
function UIDarkZoneWishSelectItem:SetClickFunction(func)
  self.clickFunction = func
end
function UIDarkZoneWishSelectItem:SetSelect(isChoose)
  self.isChoose = isChoose
  setactive(self.ui.mTrans_Choose, isChoose)
  setactive(self.ui.mTrans_Select, isChoose)
end
function UIDarkZoneWishSelectItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.itemData = nil
  self.isChoose = nil
  self.clickFunction = nil
  self.super.OnRelease(self, true)
end
