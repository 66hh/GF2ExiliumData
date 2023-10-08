ChrWeaponListItemV3 = class("ChrWeaponListItemV3", UIBaseCtrl)
ChrWeaponListItemV3.__index = ChrWeaponListItemV3
function ChrWeaponListItemV3:ctor()
  self.gunCmdData = nil
  self.weaponCmdData = nil
  self.gunEquipWeaponCmdData = nil
  self.isLockWeapon = false
  self.isSelected = false
  self.redPointCount = 0
end
function ChrWeaponListItemV3:InitCtrl(parent)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(itemPrefab.childItem)
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(instObj.transform)
end
function ChrWeaponListItemV3:SetData(weaponStcId, gunId, callback)
  self.weaponCmdData = NetCmdWeaponData:GetWeaponById(weaponStcId)
  self.gunCmdData = NetCmdTeamData:GetGunByStcId(gunId)
  self.gunEquipWeaponCmdData = NetCmdWeaponData:GetWeaponById(self.gunCmdData.id)
  if self.gunCmdData == nil then
    self.gunCmdData = NetCmdTeamData:GetLockGunByStcId(gunId)
  end
  self.isLockWeapon = self.weaponCmdData == nil
  if self.isLockWeapon then
    self.weaponCmdData = NetCmdWeaponData:GetWeaponByStcId(weaponStcId)
  end
  self.ui.mText_Name.text = self.weaponCmdData.Name
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank)
  self.ui.mImg_Icon.sprite = IconUtils.GetWeaponNormalSprite(self.weaponCmdData.StcData.res_code)
  self.ui.mBtn_ChrWeaponListItemV3.enabled = callback ~= nil
  UIUtils.GetButtonListener(self.ui.mBtn_ChrWeaponListItemV3.gameObject).onClick = function()
    if callback ~= nil then
      callback()
    end
  end
  setactive(self.ui.mTrans_Locked.gameObject, self.isLockWeapon)
  if not self.isLockWeapon then
    self:UpdateStar()
    self:UpdateRedPoint()
    self.isSelected = not self.isLockWeapon and self.gunCmdData ~= nil and self.gunCmdData.WeaponData.stc_id == self.weaponCmdData.stc_id
    setactive(self.ui.mTrans_ChooseIcon.gameObject, self.isSelected)
  else
    setactive(self.ui.mObj_RedPoint.gameObject, false)
    setactive(self.ui.mTrans_BreakNum, false)
    setactive(self.ui.mTrans_ChooseIcon.gameObject, false)
    self.isSelected = false
  end
end
function ChrWeaponListItemV3:UpdateStar()
  local canShowBreakTimes = self.weaponCmdData ~= nil and self.weaponCmdData.BreakTimes ~= 0 and self.weaponCmdData.Rank >= 4 and not self.weaponCmdData.IsLocked
  setactive(self.ui.mTrans_BreakNum, canShowBreakTimes)
  if canShowBreakTimes then
    self.ui.mImg_BreakNum.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. self.weaponCmdData.BreakTimes .. "_S")
  end
end
function ChrWeaponListItemV3:UpdateRedPoint()
  setactive(self.ui.mObj_RedPoint.gameObject, false)
  setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, false)
  self.redPointCount = 0
  if self.gunCmdData ~= nil then
    local redPoint = self.weaponCmdData.Rank > self.gunEquipWeaponCmdData.Rank and 1 or 0
    local breakRedPoint = 0 < self.weaponCmdData.WeaponduplicateNum and self.weaponCmdData.BreakTimes < self.weaponCmdData.StcData.MaxBreak and self.weaponCmdData.Rank >= 4 and 1 or 0
    redPoint = redPoint + breakRedPoint
    setactive(self.ui.mObj_RedPoint.gameObject, 0 < redPoint)
    setactive(self.ui.mObj_RedPoint.transform.parent.gameObject, 0 < redPoint)
    self.redPointCount = redPoint
  end
end
function ChrWeaponListItemV3:SetSelect(boolean)
  self.isSelected = boolean
  UIUtils.SetInteractive(self.mUIRoot, not boolean)
end
function ChrWeaponListItemV3:OnClose()
end
function ChrWeaponListItemV3:OnRelease()
  self.super.OnRelease(self)
end
