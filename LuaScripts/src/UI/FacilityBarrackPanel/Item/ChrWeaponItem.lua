require("UI.WeaponPanel.UIWeaponGlobal")
ChrWeaponItem = class("ChrWeaponItem", UIBaseCtrl)
ChrWeaponItem.__index = ChrWeaponItem
function ChrWeaponItem:ctor()
  self.weaponCmdData = nil
  self.mGunCmdData = nil
  self.defultPartSlotColor = Color(0.47843137254901963, 0.48627450980392156, 0.4980392156862745, 1)
  self.redPointCount = 0
end
function ChrWeaponItem:InitCtrl(parent, obj)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj ~= nil then
    instObj = obj
  else
    instObj = instantiate(itemPrefab.childItem)
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(instObj.transform)
end
function ChrWeaponItem:SetData(gunCmdData, callback, isDefault, needRedPoint)
  if isDefault == nil then
  end
  self.needRedPoint = needRedPoint == nil and true or needRedPoint
  self.mGunCmdData = gunCmdData
  self.weaponCmdData = gunCmdData.WeaponData
  local isUnlockWeapon = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeapon)
  local isUnlockWeaponPart = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart)
  setactive(self.ui.mTrans_WeaponPartsEquipe.gameObject, self.weaponCmdData.slotList.Count > 0 and isUnlockWeaponPart)
  setactive(self.ui.mTrans_Locked.gameObject, not isUnlockWeapon)
  setactive(self.ui.mTrans_Unlock.gameObject, isUnlockWeapon)
  self.ui.mText_LevelNum.text = self.weaponCmdData.Level
  self.ui.mImg_WeaponQualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_WeaponQualityLine.color.a)
  self.ui.mImg_QualityColor.color = TableData.GetGlobalGun_Quality_Color2(self.weaponCmdData.Rank, self.ui.mImg_QualityColor.color.a)
  self.ui.mImg_WeaponIcon.sprite = IconUtils.GetWeaponNormalSprite(self.weaponCmdData.StcData.res_code)
  self.ui.mBtn_ChrWeaponItemV3.enabled = callback ~= nil
  UIUtils.GetButtonListener(self.ui.mBtn_ChrWeaponItemV3.gameObject).onClick = function()
    if not isUnlockWeapon then
      local unlockData = AccountNetCmdHandler:GetUnlockDataBySystemId(SystemList.GundetailWeapon)
      local str = UIUtils.CheckUnlockPopupStr(unlockData)
      PopupMessageManager.PopupString(str)
      MessageSys:SendMessage(GuideEvent.OnTabSwitchFail, nil)
      return
    end
    if callback ~= nil then
      callback()
    end
  end
  if not isDefault then
    self:UpdateStar()
    self:UpdateSlot()
    self:UpdateRedPoint()
  end
end
function ChrWeaponItem:UpdateStar()
  setactive(self.ui.mTrans_BreakNum.gameObject, true)
  UIWeaponGlobal.SetBreakTimesImg(self.ui.mImg_BreakNum, self.weaponCmdData.BreakTimes, self.weaponCmdData.MaxBreakTime)
end
function ChrWeaponItem:UpdateSlot()
  local slotTrans = self.ui.mTrans_WeaponPartsEquipe
  local slotList = self.weaponCmdData.slotList
  for i = 0, slotTrans.childCount - 1 do
    setactive(slotTrans:GetChild(i).gameObject, i < slotList.Count)
  end
  for i = 0, slotList.Count - 1 do
    local item = slotTrans:GetChild(i):Find("Img_QualityColor"):GetComponent("Image")
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
function ChrWeaponItem:UpdateRedPoint()
  if self.mGunCmdData ~= nil then
    local redPoint = 0
    if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeapon) then
      redPoint = redPoint + NetCmdWeaponData:UpdateWeaponCanChangeRedPoint(self.mGunCmdData.WeaponId, self.mGunCmdData.GunId)
      redPoint = redPoint + self.weaponCmdData:GetWeaponLevelUpBreakPolarityRedPoint()
    end
    if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart) then
      redPoint = redPoint + NetCmdTeamData:UpdateWeaponModRedPoint(self.mGunCmdData)
    end
    self.redPointCount = redPoint
    setactive(self.ui.mObj_RedPoint.gameObject, self.needRedPoint and 0 < redPoint)
    setactive(self.ui.mObj_RedPoint.parent.gameObject, self.needRedPoint and 0 < redPoint)
  end
end
function ChrWeaponItem:OnClose()
end
function ChrWeaponItem:OnRelease()
  self.super.OnRelease(self)
end
