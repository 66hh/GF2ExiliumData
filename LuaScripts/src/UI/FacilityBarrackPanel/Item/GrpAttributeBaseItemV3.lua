require("UI.FacilityBarrackPanel.Item.ChrAttributeBaseInfoItemV3")
GrpAttributeBaseItemV3 = class("GrpAttributeBaseItemV3", UIBaseCtrl)
GrpAttributeBaseItemV3.__index = GrpAttributeBaseItemV3
function GrpAttributeBaseItemV3:ctor()
  self.curAttributeShowType = 0
  self.gunData = nil
  self.weaponCmdData = nil
  self.mLanguagePropertyData = nil
  self.sysName = ""
  self.listParent = nil
  self.scrollRectObj = nil
  self.value = 0
  self.tmpValue = 0
  self.valueFrom = {}
  self.callback = nil
end
function GrpAttributeBaseItemV3:InitCtrl(parent, obj, scrollRectObj)
  local itemPrefab = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj
  if obj == nil then
    instObj = instantiate(itemPrefab.childItem)
  else
    instObj = obj
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  self.listParent = self.ui.mScrollListChild_Content.transform
  self.scrollRectObj = scrollRectObj
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
  UIUtils.GetButtonListener(self.ui.mBtn_AttributeNum.gameObject).onClick = function()
    if self.callback ~= nil then
      self.callback()
    end
    self:ShowBaseFrom(not self.ui.mTrans_BaseFrom.gameObject.activeSelf)
    ComScreenItemHelper:AdaptiveCenterItemInViewPort(self.mUIRoot.gameObject, self.scrollRectObj)
  end
end
function GrpAttributeBaseItemV3:SetNilProp()
  self:CloseAllItem()
  self.curAttributeShowType = 0
  self.mLanguagePropertyData = nil
  self.value = 0
  setactive(self.mUIRoot, false)
end
function GrpAttributeBaseItemV3:SetGunProp(gunCmdData, data, value)
  if self:CheckShowProp(data, value) then
    setactive(self.mUIRoot, true)
    self.curAttributeShowType = FacilityBarrackGlobal.AttributeShowType.Gun
    self.gunData = gunCmdData
    self:SetProp(data, value)
    self:SetGunValueFrom()
  else
    self.curAttributeShowType = 0
    self.mLanguagePropertyData = nil
    self.value = 0
    setactive(self.mUIRoot, false)
  end
  return self.mUIRoot.gameObject.activeSelf
end
function GrpAttributeBaseItemV3:SetWeaponProp(weaponCmdData, data, value)
  if self:CheckShowProp(data, value) then
    setactive(self.mUIRoot, true)
    self.curAttributeShowType = FacilityBarrackGlobal.AttributeShowType.Weapon
    self.weaponCmdData = weaponCmdData
    self:SetProp(data, value)
    self:SetWeaponValueFrom()
  else
    self.curAttributeShowType = 0
    self.mLanguagePropertyData = nil
    self.value = 0
    setactive(self.mUIRoot, false)
  end
  return self.mUIRoot.gameObject.activeSelf
end
function GrpAttributeBaseItemV3:SetRobotProp(robotCmdData, data, value)
  if self:CheckShowProp(data, value) then
    setactive(self.mUIRoot, true)
    self.curAttributeShowType = FacilityBarrackGlobal.AttributeShowType.Robot
    self.robotCmdData = robotCmdData
    if self.sysName == "" then
      self.sysName = data.sys_name
    end
    if value == nil or value == 0 then
      value = self.robotCmdData:GetRobotBaseValue(self.sysName, false) or 0
    end
    self:SetProp(data, value)
    self:SetRobotValueFrom()
  else
    self.curAttributeShowType = 0
    self.mLanguagePropertyData = nil
    self.value = 0
    setactive(self.mUIRoot, false)
  end
  return self.mUIRoot.gameObject.activeSelf
end
function GrpAttributeBaseItemV3:SetProp(data, value)
  self.mLanguagePropertyData = data
  self.sysName = self.mLanguagePropertyData.sys_name
  self.value = value
  self.ui.mText_Attribute.text = data.show_name.str
  local strValue = 0
  if self.mLanguagePropertyData.show_type == 2 then
    strValue = FacilityBarrackGlobal.PercentValue(value, 2)
  else
    local formatted_num = string.format("%.2f", value)
    strValue = formatted_num
  end
  if self.sysName == "max_ap" then
    strValue = PropertyHelper.CastGunMaxAp(value)
    local formatted_num = string.format("%.0f", strValue)
    strValue = formatted_num
  end
  self.ui.mText_Num.text = strValue
  self.ui.mImg_Icon.sprite = IconUtils.GetAttributeIcon(self.mLanguagePropertyData.icon)
end
function GrpAttributeBaseItemV3:SetGunValueFrom()
  self.ui.mText_BaseTitle.text = self.mLanguagePropertyData.barrack_show_description
  self.valueFrom = {}
  self.tmpValue = 0
  self:GetGunValue()
  self:GetWeaponValue()
  self:GetTalentValue()
  self:GetTalentKeyValue()
  self:GetWeaponPartsValue()
  self:CheckShowContent()
end
function GrpAttributeBaseItemV3:SetWeaponValueFrom()
  self.ui.mText_BaseTitle.text = self.mLanguagePropertyData.barrack_show_description
  self.valueFrom = {}
  self.tmpValue = 0
  self:GetWeaponValue()
  self:GetWeaponPartsValue()
  self:CheckShowContent()
end
function GrpAttributeBaseItemV3:SetRobotValueFrom()
  self.ui.mText_BaseTitle.text = self.mLanguagePropertyData.barrack_show_description
  self.valueFrom = {}
  self.tmpValue = 0
  self:GetRobotValue()
  self:CheckShowContent()
end
function GrpAttributeBaseItemV3:GetRobotValue()
  local baseItem = ChrAttributeBaseInfoItemV3.New()
  baseItem:InitCtrl(self.listParent, self:GetTmpObj(1))
  local value = self.robotCmdData:GetRobotBaseValue(self.sysName, false)
  baseItem:SetProp(self.mLanguagePropertyData, value, 160032)
  table.insert(self.valueFrom, baseItem)
  self.tmpValue = self.tmpValue + value
end
function GrpAttributeBaseItemV3:GetTmpObj(index)
  local tmpObj
  if index <= self.listParent.childCount then
    tmpObj = self.listParent:GetChild(index - 1)
  end
  return tmpObj
end
function GrpAttributeBaseItemV3:GetGunValue()
  local baseItem = ChrAttributeBaseInfoItemV3.New()
  baseItem:InitCtrl(self.listParent, self:GetTmpObj(1))
  local value = 0
  value = self.gunData:GetGunBasePropertyDecimalValueWithPercent(self.sysName, 2)
  value = value + self.gunData:GetGunClassPropertyDecimalValueWithPercent(self.sysName, 2)
  baseItem:SetProp(self.mLanguagePropertyData, value, 160032)
  table.insert(self.valueFrom, baseItem)
  self.tmpValue = self.tmpValue + value
end
function GrpAttributeBaseItemV3:GetWeaponValue()
  local baseItem = ChrAttributeBaseInfoItemV3.New()
  baseItem:InitCtrl(self.listParent, self:GetTmpObj(2))
  local value = 0
  if self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Gun then
    value = self.gunData:GetWeaponDecimalValueWithPercent(self.sysName)
  elseif self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Weapon then
    value = self.weaponCmdData:GetWeaponDecimalValueByName(self.sysName, 2, false)
  end
  baseItem:SetProp(self.mLanguagePropertyData, value, 160034)
  table.insert(self.valueFrom, baseItem)
  self.tmpValue = self.tmpValue + value
end
function GrpAttributeBaseItemV3:GetTalentValue()
  local baseItem = ChrAttributeBaseInfoItemV3.New()
  baseItem:InitCtrl(self.listParent, self:GetTmpObj(3))
  local value = 0
  value = self.gunData:GetGunTalentDecimalPropertyValueWithPercent(self.sysName)
  baseItem:SetProp(self.mLanguagePropertyData, value, 160033)
  table.insert(self.valueFrom, baseItem)
  self.tmpValue = self.tmpValue + value
end
function GrpAttributeBaseItemV3:GetTalentKeyValue()
  local baseItem = ChrAttributeBaseInfoItemV3.New()
  baseItem:InitCtrl(self.listParent, self:GetTmpObj(4))
  local value = 0
  value = self.gunData:GetGunTalentKeyDecimalPropertyValueWithPercent(self.sysName)
  baseItem:SetProp(self.mLanguagePropertyData, value, 160041)
  table.insert(self.valueFrom, baseItem)
  self.tmpValue = self.tmpValue + value
end
function GrpAttributeBaseItemV3:GetWeaponPartsValue()
  local baseItem = ChrAttributeBaseInfoItemV3.New()
  baseItem:InitCtrl(self.listParent, self:GetTmpObj(5))
  local value = 0
  if self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Gun then
    value = self.gunData:GetWeaponPartsDecimalValueWithPercent(self.sysName)
  elseif self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Weapon then
    value = self.weaponCmdData:GetWeaponPartsDecimalValueWithPercent(self.sysName)
  end
  baseItem:SetProp(self.mLanguagePropertyData, value, 160035)
  table.insert(self.valueFrom, baseItem)
  self.tmpValue = self.tmpValue + value
end
function GrpAttributeBaseItemV3:AddCallback(callback)
  self.callback = callback
end
function GrpAttributeBaseItemV3:CheckShowProp(data, value)
  if data.barrack_show == 0 then
    return false
  end
  return true
end
function GrpAttributeBaseItemV3:CheckShowContent()
  setactive(self.ui.mScrollListChild_Content.gameObject, self.tmpValue > 0)
  setactive(self.ui.mTrans_ImgLine.gameObject, self.tmpValue > 0)
end
function GrpAttributeBaseItemV3:CloseAllItem()
  if self.listParent ~= nil then
    for i = 0, self.listParent.childCount - 1 do
      local child = self.listParent:GetChild(i)
      setactive(child.gameObject, false)
    end
  end
end
function GrpAttributeBaseItemV3:OnClose()
  self:ShowBaseFrom(false)
end
function GrpAttributeBaseItemV3:ShowBaseFrom(boolean)
  setactive(self.ui.mTrans_ImgSel.gameObject, boolean)
  setactive(self.ui.mTrans_BaseFrom.gameObject, boolean)
end
function GrpAttributeBaseItemV3:OnRelease()
  self.super.OnRelease(self)
end
