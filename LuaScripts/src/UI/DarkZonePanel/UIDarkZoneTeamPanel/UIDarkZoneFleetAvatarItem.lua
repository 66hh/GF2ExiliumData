require("UI.UIBaseCtrl")
UIDarkZoneFleetAvatarItem = class("UIDarkZoneFleetAvatarItem", UIBaseCtrl)
UIDarkZoneFleetAvatarItem.__index = UIDarkZoneFleetAvatarItem
function UIDarkZoneFleetAvatarItem:__InitCtrl()
end
function UIDarkZoneFleetAvatarItem:InitCtrl(root)
  local obj = self:Instantiate("Darkzone/DarkzoneFleetAvatarItem.prefab", root)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:SetRoot(obj.transform)
  self.clickCallBack = nil
  UIUtils.GetButtonListener(self.ui.mBtn_Self.gameObject).onClick = function()
    self:OnClickGunCard()
  end
end
function UIDarkZoneFleetAvatarItem:SetData(Data, index)
  self.mData = Data
  self.mIndex = index
  local avatarCode = self.mData.clothCode
  self.ui.mImg_Avatar.sprite = IconUtils.GetCharacterHeadSprite(avatarCode)
  self.ui.mText_GunName.text = Data.TabGunData.name.str
  setactive(self.ui.mTrans_GrpIcon, true)
  self.ui.mText_EffectNum.text = self.mData.Power
  if index ~= nil then
    self.ui.mText_TeamIndex.text = index
    if index == 1 then
      setactive(self.ui.mTrans_IconMember, false)
      setactive(self.ui.mTrans_IconCaptain, true)
    else
      setactive(self.ui.mTrans_IconMember, true)
      setactive(self.ui.mTrans_IconCaptain, false)
    end
  else
    setactive(self.ui.mTrans_GrpIcon, false)
  end
end
function UIDarkZoneFleetAvatarItem:OnClickGunCard()
  if self.clickCallBack then
    self.clickCallBack(self)
  end
end
function UIDarkZoneFleetAvatarItem:SetClickFunction(func)
  self.clickCallBack = func
end
function UIDarkZoneFleetAvatarItem:OnRelease()
  self.mData = nil
  self.ui = nil
  self.mIndex = nil
  self.clickCallBack = nil
  self.super.OnRelease(self, true)
end
