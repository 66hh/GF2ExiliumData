require("UI.UIBaseCtrl")
require("UI.Common.UICommonLockItem")
UIDarkZoneItemInfoItem = class("UIDarkZoneItemInfoItem", UIBaseCtrl)
UIDarkZoneItemInfoItem.__index = UIDarkZoneItemInfoItem
UIDarkZoneItemInfoItem.ui = nil
UIDarkZoneItemInfoItem.mData = nil
function UIDarkZoneItemInfoItem:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function UIDarkZoneItemInfoItem:InitCtrl(parent, UnLockPart, UnLockPartMsgReturn)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local obj = instantiate(com.childItem)
  if parent then
    CS.LuaUIUtils.SetParent(obj.gameObject, parent.gameObject, true)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self.mData = nil
  self:LuaUIBindTable(obj, self.ui)
  self:InitLockItem()
  self:InitShow(false)
  self.makeUpAttributeList = {}
  self.proficAttributeList = {}
  self.UnLockPart = UnLockPart
  self.UnLockPartMsgReturn = UnLockPartMsgReturn
  setactivewithcheck(self.ui.mTrans_Capacity, false)
end
function UIDarkZoneItemInfoItem:InitShow(bShow)
  setactive(self.ui.mTrans_TopInfo, bShow)
  setactive(self.ui.mTrans_GrpInfo, bShow)
  setactive(self.ui.mTrans_GrpWeaponPart, bShow)
  setactive(self.ui.mTrans_TexpEmpty, not bShow)
end
function UIDarkZoneItemInfoItem:Refresh(weaponPartsData)
  self.weaponPartData = weaponPartsData
  if not weaponPartsData then
    return
  end
  self:InitShow(true)
  local slotData = TableData.listWeaponModTypeDatas:GetDataById(weaponPartsData.fatherType)
  if slotData ~= nil then
    self.ui.mTxt_ItemName.text = slotData.name.str
  end
  setactive(self.ui.mTrans_TopInfo, slotData ~= nil)
  self.ui.mText_Title.text = weaponPartsData.name
  self.ui.mTxt_DetailInfo.text = ""
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(weaponPartsData.rank)
  setactive(self.ui.mTrans_Capacity, false)
  self.ui.mText_Capacity.text = tostring(weaponPartsData.Capacity)
  self.ui.mText_Lv.text = "Lv." .. weaponPartsData.level
  self.ui.mText_MaxLv.text = "/" .. weaponPartsData.maxLevel
  setactive(self.ui.mImg_PartType, true)
  self.ui.mImg_PartType.sprite = IconUtils.GetWeaponPartIconSprite(weaponPartsData.ModEffectTypeData.Icon, false)
  setactive(self.ui.mText_Flaw, true)
  if weaponPartsData.Quality == UIWeaponGlobal.WeaponModQuality.Flaw then
    self.ui.mText_Flaw.text = TableData.GetHintById(250001)
  elseif weaponPartsData.Quality == UIWeaponGlobal.WeaponModQuality.Normal then
    self.ui.mText_Flaw.text = TableData.GetHintById(250002)
  elseif weaponPartsData.Quality == UIWeaponGlobal.WeaponModQuality.Perfect then
    self.ui.mText_Flaw.text = TableData.GetHintById(250003)
  end
  setactive(self.ui.mScrollListChild_BtnLock, false)
  self.lockItem:SetLock(weaponPartsData.IsLocked)
  setactive(self.ui.mScrollChild_Attribute, true)
  CS.GunWeaponModData.SetWeaponPartAttr(weaponPartsData, self.ui.mScrollChild_Attribute.transform, self.ui.mTrans_MainAttribute.transform, 0)
  if weaponPartsData.PolarityId ~= 0 then
    setactive(self.ui.mTrans_PolarityIcon, true)
    self.ui.mImg_Polarity.sprite = IconUtils.GetElementIcon(TableData.listPolarityTagDatas:GetDataById(weaponPartsData.PolarityId).Icon .. "_s")
  else
    setactive(self.ui.mTrans_PolarityIcon, false)
  end
  local flag = false
  if weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Cover then
    local dataSuit
    if weaponPartsData.suitId ~= 0 then
      dataSuit = TableData.listModPowerDatas:GetDataById(weaponPartsData.suitId)
    end
    if dataSuit ~= nil then
      self.ui.mImg_MakeUp.sprite = IconUtils.GetWeaponPartIconSprite(dataSuit.image, false)
    end
    self.ui.mText_MakeUpName.text = weaponPartsData.ModPowerData.name.str .. " LV." .. tostring(weaponPartsData.AddLevel + weaponPartsData.PowerSkillCsData.level)
    self.ui.mText_MakeUpLv.text = string_format("1/{0}", weaponPartsData.ModPowerList[1].Key)
    self.ui.mText_MakeUpItem.text = weaponPartsData:GetModGroupSkillShowText()
    for i = 1, #self.makeUpAttributeList do
      setactive(self.makeUpAttributeList[i], false)
    end
    for i = 0, weaponPartsData.GunWeaponModPropertyListWithAddValue.Count - 1 do
      local attributeItem = self.makeUpAttributeList[i + 1]
      local data = weaponPartsData.GunWeaponModPropertyListWithAddValue[i]
      if not attributeItem then
        attributeItem = instantiate(self.ui.mText_MakeUpItem, self.ui.mTrans_GrpTop.transform)
        table.insert(self.makeUpAttributeList, attributeItem)
      end
      attributeItem.text = string_format(TableData.GetHintById(250055), data.PropData.show_name.str, data.AddLevel)
      setactive(attributeItem, true)
    end
    if 0 < weaponPartsData.BasicValue.Length + weaponPartsData.GunWeaponModPropertyListWithAddValue.Count or weaponPartsData.GroupSkillData ~= nil then
      setactive(self.ui.mTrans_MakeUp, true)
      flag = true
    else
      setactive(self.ui.mTrans_MakeUp, false)
    end
  else
    setactive(self.ui.mTrans_MakeUp, false)
  end
  if weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Ambush or weaponPartsData.ModEffectTypeData.EffectId == UIWeaponGlobal.ModEffectType.Armor then
    if weaponPartsData.ExtraCapacity ~= 0 then
      local attributeItem = self.ui.mTrans_PolarityItem
      setactive(self.ui.mTrans_PolarityItem, true)
      self.ui.mText_ProficiencyDescribe.text = string_format(TableData.GetHintById(250056), weaponPartsData.ExtraCapacity)
    else
      setactive(self.ui.mTrans_PolarityItem, false)
    end
    for i = 1, #self.proficAttributeList do
      setactive(self.proficAttributeList[i], false)
    end
    for i = 0, weaponPartsData.GunWeaponModPropertyListWithAddValue.Count - 1 do
      local attributeItem = self.proficAttributeList[i + 1]
      local data = weaponPartsData.GunWeaponModPropertyListWithAddValue[i]
      if not attributeItem then
        attributeItem = instantiate(self.ui.mTrans_PolarityItem, self.ui.mTrans_GrpPolarity.transform)
        table.insert(self.proficAttributeList, attributeItem)
      end
      setactive(attributeItem, true)
      attributeItem.transform:Find("Text_ProficiencyDescribe"):GetComponent(typeof(CS.TextFit)).text = string_format(TableData.GetHintById(250055), data.PropData.show_name.str, data.AddLevel)
    end
    if weaponPartsData.ExtraCapacity ~= 0 or 0 < weaponPartsData.GunWeaponModPropertyListWithAddValue.Count then
      setactive(self.ui.mTrans_GrpPolarity, true)
      flag = true
    else
      setactive(self.ui.mTrans_GrpPolarity, false)
    end
  else
    setactive(self.ui.mTrans_GrpPolarity, false)
  end
  setactive(self.ui.mTrans_GrpPartsSkill.gameObject, flag)
end
function UIDarkZoneItemInfoItem:InitLockItem()
  local parent = self.ui.mScrollListChild_BtnLock.transform
  local obj
  if parent.childCount > 0 then
    obj = parent:GetChild(0)
  end
  self.lockItem = self.lockItem or UICommonLockItem.New()
  self.lockItem:InitCtrl(parent, obj)
  self.lockItem:AddClickListener(function(isOn)
    self:OnClickLock(isOn)
  end)
end
function UIDarkZoneItemInfoItem:OnClickLock(isOn)
  if not self.weaponPartData then
    return
  end
  if isOn == self.weaponPartData.IsLocked then
    return
  end
  if not self.weaponPartData.IsLocked and self.UnLockPart then
    self.UnLockPart(self.weaponPartData.id)
  end
  NetCmdWeaponPartsData:ReqWeaponPartLockUnlock(self.weaponPartData.id, function(ret)
    if ret == ErrorCodeSuc then
      if isOn then
        UIUtils.PopupPositiveHintMessage(220007)
      else
        UIUtils.PopupPositiveHintMessage(220008)
      end
      self.lockItem:SetLock(isOn)
      if self.UnLockPartMsgReturn then
        self.UnLockPartMsgReturn(isOn, self.weaponPartData.id)
      end
    end
  end)
end
function UIDarkZoneItemInfoItem:OnRelease()
  for i = 1, #self.makeUpAttributeList do
    if self.makeUpAttributeList[i] then
      gfdestroy(self.makeUpAttributeList[i])
    end
  end
  for i = 1, #self.proficAttributeList do
    if self.proficAttributeList[i] then
      gfdestroy(self.proficAttributeList[i])
    end
  end
  if self.lockItem then
    self.lockItem:OnRelease(true)
  end
  self.lockItem = nil
  self.makeUpAttributeList = nil
  self.proficAttributeList = nil
  self.weaponPartData = nil
  self.UnLockPart = nil
  self.UnLockPartMsgReturn = nil
  self.super.OnRelease(self, true)
end
