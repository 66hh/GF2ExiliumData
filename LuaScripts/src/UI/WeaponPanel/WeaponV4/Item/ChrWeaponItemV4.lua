require("UI.UIBaseCtrl")
ChrWeaponItemV4 = class("ChrWeaponItemV4", UIBaseCtrl)
ChrWeaponItemV4.__index = ChrWeaponItemV4
function ChrWeaponItemV4:ctor()
  self.weaponCmdData = nil
  self.defultPartSlotColor = Color(0.47843137254901963, 0.48627450980392156, 0.4980392156862745, 1)
  self.isSelect = false
end
function ChrWeaponItemV4:InitCtrl(parent, obj)
  local instObj
  if obj == nil then
    local itemPrefab = parent.gameObject:GetComponent(typeof(CS.ScrollListChild))
    instObj = instantiate(itemPrefab.childItem)
  else
    instObj = obj
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ChrWeaponItemV4:SetWeaponData(weaponCmdData, callback)
  self.weaponCmdData = weaponCmdData
  local isUnlockWeaponPart = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart)
  setactive(self.ui.mTrans_WeaponPartsEquipe.gameObject, self.weaponCmdData.slotList.Count > 0 and isUnlockWeaponPart)
  self.ui.mImg_WeaponIcon.sprite = IconUtils.GetWeaponNormalSprite(self.weaponCmdData.StcData.res_code)
  self.ui.mImg_WeaponQualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_WeaponQualityLine.color.a)
  self.ui.mImg_Quality.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_Quality.color.a)
  local breakNum = self.weaponCmdData.BreakTimes
  local maxBreakNum = self.weaponCmdData.MaxBreakTime
  local isGunEquipped = 0 < self.weaponCmdData.gun_id
  setactive(self.ui.mTrans_ChrEquiped, isGunEquipped)
  if isGunEquipped then
    local gunData = TableData.listGunDatas:GetDataById(self.weaponCmdData.gun_id)
    if gunData then
      self.ui.mImg_ChrHead.sprite = IconUtils.GetCharacterHeadSpriteWithClothByGunId(IconUtils.cCharacterAvatarType_Avatar, gunData.id)
    end
  end
  setactive(self.ui.mTrans_BreakNum.gameObject, 0 < breakNum)
  if 0 < breakNum then
    UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_BreakNum, breakNum, maxBreakNum)
  else
    UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_BreakNum, 1, maxBreakNum)
  end
  self.ui.mText_LevelNum.text = GlobalConfig.SetLvText(weaponCmdData.Level)
  UIUtils.GetButtonListener(self.ui.mBtn_ChrWeaponItemV3.gameObject).onClick = function()
    if callback then
      callback(self)
    end
  end
  self:UpdateSlot()
  self:UpdateRedPoint()
end
function ChrWeaponItemV4:UpdateSlot()
  local slotTrans = self.ui.mTrans_WeaponPartsEquipe
  local slotList = self.weaponCmdData.slotList
  for i = 0, slotTrans.childCount - 1 do
    setactive(slotTrans:GetChild(i).gameObject, i < slotList.Count)
  end
  for i = 0, slotList.Count - 1 do
    local item = slotTrans:GetChild(i):Find("Img_QualityColor"):GetComponent(typeof(CS.UnityEngine.UI.Image))
    local data = self.weaponCmdData:GetWeaponPartByType(i)
    if data then
      setactive(item.gameObject, true)
      item.color = TableData.GetGlobalGun_Quality_Color2(data.rank, item.color.a)
    else
      setactive(item.gameObject, false)
      item.color = self.defultPartSlotColor
    end
  end
end
function ChrWeaponItemV4:UpdateRedPoint()
  if self.mGunCmdData ~= nil then
    local redPoint = NetCmdWeaponData:UpdateWeaponCanChangeRedPoint(self.mGunCmdData.WeaponId, self.mGunCmdData.GunId)
    redPoint = redPoint + NetCmdWeaponData:UpdateWeaponCanBreakRedPoint(self.mGunCmdData.WeaponId)
    if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart) then
      redPoint = redPoint + NetCmdTeamData:UpdateWeaponModRedPoint(self.mGunCmdData)
    end
    self.redPointCount = redPoint
    setactive(self.ui.mObj_RedPoint.gameObject, self.needRedPoint and 0 < redPoint)
    setactive(self.ui.mObj_RedPoint.parent.gameObject, self.needRedPoint and 0 < redPoint)
  end
end
function ChrWeaponItemV4:SetNowEquip(boolean)
  setactive(self.ui.mTrans_ChooseIcon.gameObject, boolean)
  setactive(self.ui.mTrans_ChoosenLine.gameObject, boolean)
end
function ChrWeaponItemV4:SetItemSelect(boolean)
  setactive(self.ui.mTrans_SelNow.gameObject, boolean)
  self.isSelect = boolean
  self:SetBtnInteractable(not boolean)
end
function ChrWeaponItemV4:SetGunEquipped(boolean)
  setactive(self.ui.mTrans_ChrEquiped, boolean)
end
function ChrWeaponItemV4:IsSelect()
  return self.isSelect
end
function ChrWeaponItemV4:SetBtnInteractable(boolean)
  self.ui.mBtn_ChrWeaponItemV3.interactable = boolean
end
