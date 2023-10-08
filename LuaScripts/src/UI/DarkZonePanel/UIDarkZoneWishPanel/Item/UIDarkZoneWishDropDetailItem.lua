require("UI.UIBaseCtrl")
UIDarkZoneWishDropDetailItem = class("UIDarkZoneWishDropDetailItem", UIBaseCtrl)
UIDarkZoneWishDropDetailItem.__index = UIDarkZoneWishDropDetailItem
function UIDarkZoneWishDropDetailItem:__InitCtrl()
end
function UIDarkZoneWishDropDetailItem:InitCtrl(gameObject, root)
  local obj = instantiate(gameObject, root)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.mData = nil
end
function UIDarkZoneWishDropDetailItem:SetData(data)
  self:SetActive(true)
  self.weaponModData = data.tbData
  local showNum = data.showNum
  local itemData = TableData.GetItemData(self.weaponModData.id, true)
  if itemData then
    self.ui.mText_Name.text = itemData.name.str
  end
  local s = ""
  s = TableData.GetHintById(250000 + self.weaponModData.quality)
  self.ui.mText_Type.text = s
  local modEffectTypeData = TableData.listModEffectTypeDatas:GetDataById(self.weaponModData.effect_id)
  self.ui.mImg_Icon.sprite = ResSys:GetWeaponPartEffectSprite(modEffectTypeData.icon)
  self.ui.mText_Up.text = showNum * 100 .. "%"
end
function UIDarkZoneWishDropDetailItem:SetDropUp(showUp)
  setactive(self.ui.mTrans_ImgUp, showUp)
end
function UIDarkZoneWishDropDetailItem:OnRelease()
  self.ui = nil
  self.mData = nil
  self.super.OnRelease(self, true)
end
