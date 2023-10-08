require("UI.UIBaseCtrl")
require("UI.DarkZonePanel.UIDarkZoneWishPanel.Item.UIDarkZoneWishDropDetailItem")
UIDarkZoneWishDropItem = class("UIDarkZoneWishDropItem", UIBaseCtrl)
UIDarkZoneWishDropItem.__index = UIDarkZoneWishDropItem
function UIDarkZoneWishDropItem:__InitCtrl()
end
function UIDarkZoneWishDropItem:InitCtrl(root)
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
  self.typeHighLight = {}
  self.effectIDHighLight = {}
  self.qualityHighLight = {}
end
function UIDarkZoneWishDropItem:SetUpData(typeHighLight, effectIDHighLight, qualityHighLight)
  self.typeHighLight = typeHighLight
  self.effectIDHighLight = effectIDHighLight
  self.qualityHighLight = qualityHighLight
end
function UIDarkZoneWishDropItem:SetData(rank, data)
  self.ui.mImg_Qualitycolor.color = TableData.GetGlobalGun_Quality_Color2(rank)
  self.ui.mText_Name.text = "品质（程序写的）" .. rank
  for i, v in ipairs(data) do
    if self.typeDescItemList[i] == nil then
      self.typeDescItemList[i] = UIDarkZoneWishDropDetailItem.New()
      self.typeDescItemList[i]:InitCtrl(self.ui.mTrans_DropInfoItem.gameObject, self.ui.mTrans_DropInfo)
    end
    local item = self.typeDescItemList[i]
    item:SetDropUp(false)
    item:SetData(v)
    if self.typeHighLight[item.weaponModData.aspect_id] then
      item:SetDropUp(true)
    end
    if self.effectIDHighLight[item.weaponModData.effect_id] then
      item:SetDropUp(true)
    end
    if self.qualityHighLight[item.weaponModData.quality] then
      item:SetDropUp(true)
    end
  end
end
function UIDarkZoneWishDropItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self:ReleaseCtrlTable(self.typeDescItemList, true)
  self.super.OnRelease(self, true)
end
