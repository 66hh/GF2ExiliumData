require("UI.FacilityBarrackPanel.Item.GrpAttributeBaseItemV3")
require("UI.UIBasePanel")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
UIChrAttributeDetailsDialogV3 = class("UIChrAttributeDetailsDialogV3", UIBasePanel)
UIChrAttributeDetailsDialogV3.__index = UIChrAttributeDetailsDialogV3
function UIChrAttributeDetailsDialogV3:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
  self.curAttributeShowType = 0
  self.gunData = nil
  self.weaponCmdData = nil
  self.robotData = nil
  self.isLockGun = false
  self.curClickItem = nil
  self.curClickWeakness = false
  self.tabHint = {
    [1] = 102287,
    [2] = 102288
  }
  self.propList = {}
  self.propListNoZero = {}
  self.curPropList = {}
  self.propCount = 0
  self.curTabIndex = 0
  self.curTabItem = nil
  self.hasShowValue = false
end
function UIChrAttributeDetailsDialogV3:OnClickClose()
  UIManager.CloseUI(UIDef.UIChrAttributeDetailsDialogV3)
end
function UIChrAttributeDetailsDialogV3:OnClose()
  self.ui.mTrans_Content.anchoredPosition = vector2zero
  for i, v in ipairs(self.propItemTable) do
    v:OnClose()
  end
  if self.curClickWeakness then
    self:ShowWeaknessDescribeBaseFrom(false)
  end
  if self.curClickItem ~= nil then
    self.curClickItem:OnClose()
  end
  self.curClickItem = nil
  self.curTabIndex = 0
  if self.curTabItem ~= nil then
    self.curTabItem.ui.mBtn_Tab.interactable = true
  end
  self.curTabItem = nil
end
function UIChrAttributeDetailsDialogV3:OnRelease()
  self:ReleaseCtrlTable(self.propItemTable)
end
function UIChrAttributeDetailsDialogV3:OnAwake(root, data)
  self:SetRoot(root)
  self:SetPosZ()
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.propItemTable = {}
  self.weaknessDescribe = nil
end
function UIChrAttributeDetailsDialogV3:OnInit(root, data)
  self.curAttributeShowType = data.attributeShowType
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    self:OnClickClose()
  end
  if self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Gun then
    local gunId = data.gunId
    self.gunData = NetCmdTeamData:GetGunByID(gunId)
    if self.gunData == nil then
      self.isLockGun = true
      self.gunData = NetCmdTeamData:GetLockGunData(gunId)
    end
  elseif self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Weapon then
    self.weaponCmdData = data.weaponCmdData
  elseif self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Robot then
    self.robotData = data.robotData
  end
  local isBattlePass = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass
  local isBattlePassCollection = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection
  if isBattlePass or isBattlePassCollection then
    local gunId = data.gunId
    self.gunData = NetCmdTeamData:GetLockGunData(gunId, true, FacilityBarrackGlobal.IsBattlePassMaxLevel)
  end
  self:InitProp()
  self:InitTopTab()
  self:OnClickTab(1)
end
function UIChrAttributeDetailsDialogV3:ShowProp()
  self:UpdatePanel()
  setactive(self.ui.mTrans_AttributeList.gameObject, self.hasShowValue)
  setactive(self.ui.mTrans_None.gameObject, not self.hasShowValue)
end
function UIChrAttributeDetailsDialogV3:InitTopTab()
  self.tabList = {}
  for i, tabHintId in ipairs(self.tabHint) do
    local tmpParent = self.ui.mScrollListChild_TopTab.transform
    local childTrans
    if i <= tmpParent.childCount then
      childTrans = tmpParent:GetChild(i - 1)
    else
      local tmpObj = instantiate(self.ui.mScrollListChild_TopTab.childItem)
      childTrans = tmpObj.transform
      UIUtils.SetParent(tmpObj.gameObject, tmpParent.gameObject)
    end
    local item = {}
    item.ui = {}
    item.obj = childTrans.gameObject
    self:LuaUIBindTable(childTrans.gameObject, item.ui)
    table.insert(self.tabList, item)
    item.ui.mText_Name.text = TableData.GetHintById(tabHintId)
    UIUtils.GetButtonListener(item.ui.mBtn_Tab.gameObject).onClick = function()
      self:OnClickTab(i)
    end
  end
end
function UIChrAttributeDetailsDialogV3:OnClickTab(index)
  self.curTabIndex = index
  if self.curTabItem ~= nil then
    self.curTabItem.ui.mBtn_Tab.interactable = true
  end
  if self.curClickItem ~= nil then
    self.curClickItem:OnClose()
  end
  self.curTabItem = self.tabList[index]
  self.curTabItem.ui.mBtn_Tab.interactable = false
  self:GetCurPropList()
  self:ShowProp()
  if self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Gun and index == 1 then
    local weakTags = string.split(self.gunData.TabGunData.weak_tag, ",")
    self:UpdateWeaknessDescribe(weakTags)
  else
    self:ShowWeaknessDescribe(false)
  end
end
function UIChrAttributeDetailsDialogV3:GetCurPropList()
  if self.curTabIndex == 1 then
    self.curPropList = self.propList
  else
    self.curPropList = self.propListNoZero
  end
end
function UIChrAttributeDetailsDialogV3:InitProp()
  self:GetBarrackShowPropList()
  self.propItemTable = {}
  for i = 1, self.propCount do
    do
      local item = GrpAttributeBaseItemV3.New()
      local obj
      if i < self.ui.mScrollListChild_Content.transform.childCount then
        obj = self.ui.mScrollListChild_Content.transform:GetChild(i)
      end
      item:InitCtrl(self.ui.mScrollListChild_Content.gameObject, obj, self.ui.mTrans_AttributeList.gameObject)
      table.insert(self.propItemTable, item)
      item:AddCallback(function()
        self:OnClickItem(item)
      end)
    end
  end
  self.weaknessDescribe = {}
  self:LuaUIBindTable(self.ui.mTrans_WeaknessDescribe, self.weaknessDescribe)
end
function UIChrAttributeDetailsDialogV3:UpdatePanel()
  self:UpdateWeaknessDescribe()
  for i, v in ipairs(self.propItemTable) do
    v:SetNilProp()
  end
  self.hasShowValue = false
  if self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Gun and self.gunData then
    self.hasShowValue = self:UpdateGunProp()
  elseif self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Weapon and self.weaponCmdData then
    self.hasShowValue = self:UpdateWeaponProp()
  elseif self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Robot and self.robotData then
    self.hasShowValue = self:UpdateRobotProp()
  end
end
function UIChrAttributeDetailsDialogV3:UpdateGunProp()
  local showValueCount = 0
  for i, prop in ipairs(self.curPropList) do
    local value = self:GetTotalPropValueByName(prop.sys_name)
    local item = self.propItemTable[i]
    local isActive = item:SetGunProp(self.gunData, prop, value)
    if isActive then
      showValueCount = showValueCount + 1
    end
  end
  local weakTags = string.split(self.gunData.TabGunData.weak_tag, ",")
  self:UpdateWeaknessDescribe(weakTags)
  return 0 < showValueCount
end
function UIChrAttributeDetailsDialogV3:UpdateWeaponProp()
  local showValueCount = 0
  for i, prop in ipairs(self.curPropList) do
    local value = self:GetTotalPropValueByName(prop.sys_name)
    local item = self.propItemTable[i]
    local isActive = item:SetWeaponProp(self.weaponCmdData, prop, value)
    if isActive then
      showValueCount = showValueCount + 1
    end
  end
  return 0 < showValueCount
end
function UIChrAttributeDetailsDialogV3:UpdateRobotProp()
  local showValueCount = 0
  for i, prop in ipairs(self.curPropList) do
    local value = self:GetTotalPropValueByName(prop.sys_name)
    local item = self.propItemTable[i]
    local isActive = item:SetRobotProp(self.robotData, prop, value)
    if isActive then
      showValueCount = showValueCount + 1
    end
  end
  return 0 < showValueCount
end
function UIChrAttributeDetailsDialogV3:GetBarrackShowPropList()
  if self.propList ~= nil and #self.propList > 0 then
    return
  end
  self.propList = {}
  self.propListNoZero = {}
  self.propCount = 0
  for i = 0, TableData.listLanguagePropertyDatas.Count - 1 do
    local propData = TableData.listLanguagePropertyDatas[i]
    if propData and propData.barrack_show ~= 0 then
      self.propCount = self.propCount + 1
      if not propData.no_zero_show then
        table.insert(self.propList, propData)
      else
        table.insert(self.propListNoZero, propData)
      end
    end
  end
  table.sort(self.propList, function(a, b)
    return a.barrack_show < b.barrack_show
  end)
  table.sort(self.propListNoZero, function(a, b)
    return a.barrack_show < b.barrack_show
  end)
end
function UIChrAttributeDetailsDialogV3:GetTotalPropValueByName(name)
  if self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Gun then
    return self.gunData:GetGunPropertyDecimalValueWithPercentByType(name)
  elseif self.curAttributeShowType == FacilityBarrackGlobal.AttributeShowType.Weapon then
    return self.weaponCmdData:GetWeaponDecimalValueByName(name)
  end
end
function UIChrAttributeDetailsDialogV3:OnClickItem(item)
  if self.curClickItem ~= nil and self.curClickItem.mLanguagePropertyData ~= nil and self.curClickItem.mLanguagePropertyData.id ~= item.mLanguagePropertyData.id then
    self.curClickItem:OnClose()
  end
  if self.curClickWeakness then
    self:ShowWeaknessDescribeBaseFrom(false)
  end
  self.curClickItem = item
end
function UIChrAttributeDetailsDialogV3:ShowWeaknessDescribe(boolean)
  setactive(self.ui.mTrans_WeaknessDescribe.gameObject, boolean)
end
function UIChrAttributeDetailsDialogV3:UpdateWeaknessDescribe(elementlist)
  if elementlist == nil or #elementlist == 0 then
    self:ShowWeaknessDescribe(false)
    return
  else
    local tmpParentTrans = self.weaknessDescribe.mTrans_Element
    local tmpItem = self.weaknessDescribe.mTrans_Weakness1
    for i = 0, #elementlist - 1 do
      local item
      if i < tmpParentTrans.childCount then
        item = tmpParentTrans:GetChild(i)
      else
        item = instantiate(tmpItem, tmpParentTrans, false)
      end
      local itemLua = {}
      self:LuaUIBindTable(item, itemLua)
      local languageElementData = TableData.listLanguageElementDatas:GetDataById(tonumber(elementlist[i + 1]))
      if languageElementData ~= nil then
        itemLua.mImg_Element.sprite = IconUtils.GetElementIcon(languageElementData.icon .. "_S")
        itemLua.mText_Element.text = languageElementData.name.str
      end
    end
    self:OnClickWeaknessBtn()
    self:ShowWeaknessDescribe(true)
  end
end
function UIChrAttributeDetailsDialogV3:OnClickWeaknessBtn()
  UIUtils.GetButtonListener(self.weaknessDescribe.mBtn_AttributeNum.gameObject).onClick = function()
    if self.curClickItem ~= nil then
      self.curClickItem:OnClose()
      self.curClickItem = nil
    end
    self:ShowWeaknessDescribeBaseFrom(not self.weaknessDescribe.mTrans_BaseFrom.gameObject.activeSelf)
  end
end
function UIChrAttributeDetailsDialogV3:ShowWeaknessDescribeBaseFrom(boolean)
  setactive(self.weaknessDescribe.mTrans_BaseFrom.gameObject, boolean)
  self.curClickWeakness = boolean
  ComScreenItemHelper:AdaptiveCenterItemInViewPort(self.weaknessDescribe.mUIRoot.gameObject, self.ui.mTrans_AttributeList.gameObject)
end
