require("UI.Common.UICommonLockItem")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
require("UI.WeaponPanel.UIWeaponGlobal")
require("UI.Common.UICommonItem")
UIChrWeaponPartsReplacePanel = class("UIChrWeaponPartsReplacePanel", UIBasePanel)
UIChrWeaponPartsReplacePanel.__index = UIChrWeaponPartsReplacePanel
function UIChrWeaponPartsReplacePanel:ctor(csPanel)
  UIChrWeaponPartsReplacePanel.super:ctor(csPanel)
  csPanel.Is3DPanel = true
end
function UIChrWeaponPartsReplacePanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.lockItem = nil
  self.weaponCmdData = nil
  self.curSlotIndex = 0
  self.gunWeaponModData = nil
  self.curSelectGunWeaponModData = nil
  self.curSelectPartItem = nil
  self.weaponPartsList = nil
  self.comScreenItemV2 = nil
  self.curPartItem = nil
  self.weaponPartUis = {}
  self.isOverflow = false
  self.ToggleHintStr = {}
  self.equipBtnRedPoint = nil
  self.replaceBtnRedPoint = nil
  self.polarityBtnRedPoint = nil
  self.isAdditionGroupSkillActive = false
  self.curClickItemId = 0
  self.groupSkillItems = {}
  self.groupSkillColor = {
    active = CS.GF2.UI.UITool.StringToColor("74c5e6"),
    inactive = CS.GF2.UI.UITool.StringToColor("EFEFEF")
  }
  self.chrWeaponPartsInfoItem1 = nil
  self.chrWeaponPartsInfoItem2 = nil
  self.needRefreshLeft = false
  self:InitWeaponPartList()
end
function UIChrWeaponPartsReplacePanel:OnInit(root, data)
  self.ToggleHintStr[1] = TableData.GetHintById(220072)
  self.ToggleHintStr[2] = TableData.GetHintById(220073)
  self.ui.mText_Toggle.text = self.ToggleHintStr[1]
  self.weaponCmdData = data.weaponCmdData
  self.curSlotIndex = data.curSlotIndex
  self.gunWeaponModData = self.weaponCmdData:GetWeaponPartByType(self.curSlotIndex - 1)
  self.curSelectGunWeaponModData = self.gunWeaponModData
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIBarrackWeaponModelManager:ExitAccessoryView()
    self.weaponCmdData:ResetPreviewWeaponMod()
    UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
    UIBarrackWeaponModelManager:StopOutlineEffect()
    UIManager.CloseUI(UIDef.UIChrWeaponPartsReplacePanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    self.weaponCmdData:ResetPreviewWeaponMod()
    UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
    UIBarrackWeaponModelManager:StopOutlineEffect()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_On.gameObject).onClick = function()
    self:OnClickShowAdditionWindow(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Off.gameObject).onClick = function()
    self:OnClickShowAdditionWindow(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnLvUp.gameObject).onClick = function()
    self:OnClickBtnLvUp()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnPolarity.gameObject).onClick = function()
    self:OnClickBtnPolarity()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnRepalce.gameObject).onClick = function()
    self:OnClickBtnRepalce()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnUnload.gameObject).onClick = function()
    self:OnClickBtnUnload()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnEquip.gameObject).onClick = function()
    self:OnClickBtnRepalce()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCantLvUp.gameObject).onClick = function()
    self:OnClickBtnCantLvUp()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCantPolarityConditionLv.gameObject).onClick = function()
    self:OnClickBtnCantPolarityConditionLv()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCantPolarityConditionEffect.gameObject).onClick = function()
    self:OnClickBtnCantPolarityConditionEffect()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self.ui.mToggle_Contrast.isOn = false
  end
  self:InitLockItem()
  self.ui.mToggle_Contrast.onValueChanged:AddListener(function(isOn)
    self:OnClickGFToggle(isOn)
  end)
  UIBarrackWeaponModelManager:SetAccessoryViewByWeaponIdAndSlotIndex(self.weaponCmdData.stc_id, self.curSlotIndex - 1, true)
end
function UIChrWeaponPartsReplacePanel:OnShowStart()
  self:UpdateWeaponPartsList()
  self:InitShowAdditionWindow(false)
  self:SetWeaponPartsData()
  self:UpdateSortContent()
end
function UIChrWeaponPartsReplacePanel:OnSave()
  self.savePartItem = self.curPartItem
end
function UIChrWeaponPartsReplacePanel:OnRecover()
  self.curPartItem = self.savePartItem
  self.savePartItem = nil
  self:SetWeaponPartsData()
  self:UpdateSortContent()
end
function UIChrWeaponPartsReplacePanel:OnBackFrom()
  self:SetWeaponPartsData()
  self:UpdateWeaponPartsList()
  self:UpdateSortContent()
end
function UIChrWeaponPartsReplacePanel:OnTop()
end
function UIChrWeaponPartsReplacePanel:OnShowFinish()
end
function UIChrWeaponPartsReplacePanel:OnCameraStart()
  return 0.01
end
function UIChrWeaponPartsReplacePanel:OnHide()
end
function UIChrWeaponPartsReplacePanel:OnHideFinish()
end
function UIChrWeaponPartsReplacePanel:OnClose()
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
    self.comScreenItemV2 = nil
  end
  if self.curPartItem ~= nil then
    self:SetSlotSelected(self.curPartItem, false)
    self.curPartItem = nil
  end
  if self.curSelectPartItem ~= nil then
    self.curSelectPartItem:SetItemSelect(false)
    self.curSelectPartItem = nil
  end
  self:InitShowAdditionWindow(false)
  self.weaponCmdData:ResetPreviewWeaponMod()
  self.curClickItemId = 0
  self.weaponPartsList = nil
  self.ui.mVirtualListEx_GrpList.horizontalNormalizedPosition = 0
  UIBarrackWeaponModelManager:StopOutlineEffect()
end
function UIChrWeaponPartsReplacePanel:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPartsReplacePanel:InitLockItem()
  local parent = self.ui.mScrollListChild_BtnLock.transform
  local obj
  if parent.childCount > 0 then
    obj = parent:GetChild(0)
  end
  self.lockItem = UICommonLockItem.New()
  self.lockItem:InitCtrl(parent, obj)
  self.lockItem:AddClickListener(function(isOn)
    self:OnClickLock(isOn)
  end)
end
function UIChrWeaponPartsReplacePanel:SetWeaponPartsData()
  self.equipBtnRedPoint = self.ui.mBtn_BtnEquip.gameObject.transform:Find("Root/Trans_RedPoint")
  self.replaceBtnRedPoint = self.ui.mBtn_BtnRepalce.gameObject.transform:Find("Root/Trans_RedPoint")
  self.polarityBtnRedPoint = self.ui.mBtn_BtnPolarity.gameObject.transform:Find("Root/Trans_RedPoint")
  UIBarrackWeaponModelManager:ShowCurWeaponModel(true)
  ComPropsDetailsHelper:InitComPropsDetailsItemObjNum(2)
  local tmpGunWeaponModData
  if self.curSelectGunWeaponModData ~= nil then
    tmpGunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(self.curSelectGunWeaponModData.id)
  end
  if tmpGunWeaponModData == nil then
    setactive(self.ui.mTrans_NowSelectedPartsInfo.gameObject, false)
  else
    if self.needRefreshLeft then
      setactive(self.ui.mTrans_NowSelectedPartsInfo.gameObject, true)
      setactive(self.ui.mAnimation_List.gameObject, false)
      setactive(self.ui.mAnimation_TopInfo.gameObject, false)
      local canvasGroup1 = self.ui.mAnimation_List.gameObject:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
      local canvasGroup2 = self.ui.mAnimation_TopInfo.gameObject:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
      canvasGroup1.alpha = 0
      canvasGroup2.alpha = 0
      setactive(self.ui.mAnimation_List.gameObject, true)
      setactive(self.ui.mAnimation_TopInfo.gameObject, true)
      self.ui.mAnimation_List:Play()
      self.ui.mAnimation_TopInfo:Play()
    else
      setactive(self.ui.mTrans_NowSelectedPartsInfo.gameObject, true)
    end
    self:SetCurSelectData(tmpGunWeaponModData)
  end
  setactive(self.ui.mToggle_Contrast.gameObject, self.gunWeaponModData ~= nil and self.curSelectGunWeaponModData ~= nil and self.gunWeaponModData.id ~= self.curSelectGunWeaponModData.id)
  self:SetAdditionWeaponData()
  self:UpdateCapacity()
  self:UpdateAction()
end
function UIChrWeaponPartsReplacePanel:SetCurSelectData(tmpGunWeaponModData)
  self.ui.mText_Name.text = tmpGunWeaponModData.name
  self.ui.mText_Type.text = tmpGunWeaponModData.weaponModTypeData.Name.str
  self.ui.mText_Quality.text = tmpGunWeaponModData.QualityStr
  self.ui.mImg_TypeIcon.sprite = ResSys:GetWeaponPartEffectSprite(tmpGunWeaponModData.ModEffectTypeData.icon)
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(tmpGunWeaponModData.rank, self.ui.mImg_QualityLine.color.a)
  self:SetCurSelectItemCapcity(tmpGunWeaponModData)
  if tmpGunWeaponModData.PolarityTagData ~= nil then
    setactive(self.ui.mImg_PolarityIcon.gameObject, true)
    self.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(tmpGunWeaponModData.PolarityTagData.icon .. "_S")
  else
    setactive(self.ui.mImg_PolarityIcon.gameObject, false)
  end
  self:SetModLevel(tmpGunWeaponModData)
  self.subPropList = CS.GunWeaponModData.SetWeaponPartAttr(tmpGunWeaponModData, self.ui.mScrollListChild_GrpItem.transform, self.ui.mTrans_MainAttribute.transform)
  self:UpdateLockStatue()
  self:UpdateWeaponPartsSkill()
end
function UIChrWeaponPartsReplacePanel:SetModLevel(tmpGunWeaponModData)
  CS.GunWeaponModData.SetModLevelText(self.ui.mText_NumNow, tmpGunWeaponModData, self.ui.mText_Max)
  CS.GunWeaponModData.SetModPolarityText(self.ui.mText_State, self.ui.mImg_PolarityIcon, tmpGunWeaponModData, self.ui.mCanvasGroup_Lv)
end
function UIChrWeaponPartsReplacePanel:UpdateLockStatue()
  self.lockItem:SetLock(self.curSelectGunWeaponModData.IsLocked)
end
function UIChrWeaponPartsReplacePanel:UpdateWeaponPartsSkill()
  local modPowerData = self.curSelectGunWeaponModData.ModPowerData
  local groupSkillData = self.curSelectGunWeaponModData.GroupSkillData
  local powerSkillData = self.curSelectGunWeaponModData.PowerSkillCsData
  if nil == groupSkillData then
    setactive(self.ui.mTrans_GroupSkill.gameObject, false)
  else
    setactive(self.ui.mTrans_GroupSkill.gameObject, true)
    CS.GunWeaponModData.SetModPowerDataNameWithLevel(self.ui.mText_Skill, modPowerData, self.curSelectGunWeaponModData)
    local showText = self.curSelectGunWeaponModData:GetModGroupSkillShowText()
    self.ui.mTextFit_GroupDescribe.text = showText
    setactive(self.ui.mText_Num2.gameObject, false)
    self.ui.mImg_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(self.curSelectGunWeaponModData.ModPowerData.image, false)
  end
  local tmpParent = self.ui.mTrans_OtherPartsSkillDescribe1
  local tmpItem = self.ui.mTrans_PartsSkill1
  local count = CS.GunWeaponModData.SetWeaponPartProficiencySkill(self.curSelectGunWeaponModData, tmpParent, tmpItem)
  setactive(self.ui.mTrans_PartsSkill.gameObject, groupSkillData ~= nil or 0 ~= count)
end
function UIChrWeaponPartsReplacePanel:UpdateAction()
  local weaponPartUpgrade = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpartUpgrade)
  local weaponPartPolarity = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpartPolarity)
  setactive(self.ui.mBtn_BtnLvUp.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_BtnPolarity.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_BtnCantLvUp.gameObject, false)
  setactive(self.ui.mBtn_BtnCantPolarityConditionLv.gameObject, false)
  setactive(self.ui.mBtn_BtnCantPolarityConditionEffect.gameObject, false)
  if weaponPartUpgrade then
    setactive(self.ui.mBtn_BtnLvUp.transform.parent.gameObject, self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.level < self.curSelectGunWeaponModData.maxLevel)
  else
    setactive(self.ui.mBtn_BtnCantLvUp.gameObject, true)
  end
  if weaponPartPolarity then
    setactive(self.ui.mBtn_BtnPolarity.transform.parent.gameObject, self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.level == self.curSelectGunWeaponModData.maxLevel and self.curSelectGunWeaponModData.WeaponModData.can_polarity and self.curSelectGunWeaponModData.PolarityId == 0)
    setactive(self.ui.mBtn_BtnCantPolarityConditionEffect.gameObject, self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.level == self.curSelectGunWeaponModData.maxLevel and not self.curSelectGunWeaponModData.WeaponModData.can_polarity and self.curSelectGunWeaponModData.PolarityId == 0)
  end
  local hasRightBtnActive = false
  local tmpRightTrans = self.ui.mTrans_PartsPowerUp.transform
  for i = 0, tmpRightTrans.childCount - 1 do
    local tmpObj = tmpRightTrans:GetChild(i).gameObject
    if tmpObj.activeSelf then
      hasRightBtnActive = true
      break
    end
  end
  setactive(self.ui.mTrans_PartsPowerUp.gameObject, hasRightBtnActive)
  local curEquipGunWeaponModData = self.weaponCmdData:GetWeaponPartByType(self.curSlotIndex - 1)
  setactive(self.ui.mBtn_BtnRepalce.transform.parent.gameObject, curEquipGunWeaponModData ~= nil and self.curSelectGunWeaponModData ~= nil and curEquipGunWeaponModData.id ~= self.curSelectGunWeaponModData.id)
  setactive(self.ui.mBtn_BtnUnload.transform.parent.gameObject, curEquipGunWeaponModData ~= nil and self.curSelectGunWeaponModData ~= nil and curEquipGunWeaponModData.id == self.curSelectGunWeaponModData.id)
  setactive(self.ui.mBtn_BtnEquip.transform.parent.gameObject, curEquipGunWeaponModData == nil and self.curSelectGunWeaponModData ~= nil)
  self:UpdateBtnRedPoint()
end
function UIChrWeaponPartsReplacePanel:OnClickLock(isOn)
  if isOn == self.curSelectGunWeaponModData.IsLocked then
    return
  end
  NetCmdWeaponPartsData:ReqWeaponPartLockUnlock(self.curSelectGunWeaponModData.id, function(ret)
    if ret == ErrorCodeSuc then
      if self.curSelectPartItem ~= nil then
        setactive(self.curSelectPartItem.ui.mTrans_Lock.gameObject, self.curSelectGunWeaponModData.IsLocked)
      end
      self:UpdateLockStatue()
    end
  end)
end
function UIChrWeaponPartsReplacePanel:UpdateCapacity()
  setactive(self.ui.mTrans_VolumeTip.gameObject, false)
  local curWeaponModCapacity = self.weaponCmdData:GetAllWeaponModCapacity()
  local weaponMaxCapacity = self.weaponCmdData.Capacity
  if self.gunWeaponModData ~= nil and self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.id == self.gunWeaponModData.id or self.curSelectGunWeaponModData == nil then
    self.ui.mText_Num3.text = curWeaponModCapacity .. "/" .. weaponMaxCapacity
    return
  end
  local curSlotWeaponModCapacity = self.weaponCmdData:GetCapacityBySlotAndPolarityId(self.curSlotIndex - 1)
  local curSelectWeaponModCapacity = self.weaponCmdData:GetCapacityByGunWeaponModData(self.curSlotIndex - 1, self.curSelectGunWeaponModData)
  local targetWeaponModCapacity = curWeaponModCapacity - curSlotWeaponModCapacity + curSelectWeaponModCapacity
  self.isOverflow = weaponMaxCapacity < targetWeaponModCapacity
  setactive(self.ui.mTrans_VolumeTip.gameObject, weaponMaxCapacity < targetWeaponModCapacity)
  if weaponMaxCapacity >= targetWeaponModCapacity then
    self.ui.mText_Num3.text = targetWeaponModCapacity .. "/" .. weaponMaxCapacity
  else
    self.ui.mText_Num3.text = "<color=#FF5E41>" .. targetWeaponModCapacity .. "</color>/" .. weaponMaxCapacity
  end
end
function UIChrWeaponPartsReplacePanel:SetAdditionWeaponData()
  self:UpdateAdditionAttribute()
  self:UpdateAdditionWeaponPartSkill()
end
function UIChrWeaponPartsReplacePanel:UpdateAdditionAttribute()
  local tmpScrollListChild = self.ui.mScrollListChild_GrpItem1
  local tmpAttrParent = tmpScrollListChild.transform
  local tmpWeaponCmdData = self.weaponCmdData
  self.subPropList = CS.WeaponCmdData.SetWeaponPartsAttrWithoutWeapon(tmpWeaponCmdData, tmpAttrParent)
  if self.subPropList.Count >= 1 then
    self.subPropList[self.subPropList.Count - 1]:ShowLine(false)
  end
  if self.subPropList.Count % 2 == 0 and self.subPropList.Count >= 2 then
    self.subPropList[self.subPropList.Count - 2]:ShowLine(false)
  end
end
function UIChrWeaponPartsReplacePanel:UpdateAdditionWeaponPartSkill()
  local groupSkillItems, isAdditionGroupSkillActive = CS.WeaponCmdData.SetWeaponGroupSkillData(self.ui.mTrans_AdditionGroupSkill, self.weaponCmdData, self.isAdditionGroupSkillActive)
  local hasProficiencySkill = self:GetAdditionWeaponPartProficiencySkill()
  local hasGroupSkill = groupSkillItems.Count > 0
  setactive(self.ui.mTrans_AdditionPartsSkill.gameObject, hasGroupSkill or hasProficiencySkill)
  self.isAdditionGroupSkillActive = isAdditionGroupSkillActive
  if self.isAdditionGroupSkillActive then
    self.ui.mTrans_AdditionGroupSkill.transform:SetSiblingIndex(1)
  else
    self.ui.mTrans_AdditionGroupSkill.transform:SetSiblingIndex(2)
  end
end
function UIChrWeaponPartsReplacePanel:GetAdditionWeaponPartProficiencySkill()
  local tmpProficiencySkillItem = self.ui.mTrans_OtherSkill
  local tmpParent = tmpProficiencySkillItem.parent
  local proficiencySkillDatas = self.weaponCmdData:GetWeaponPartProficiencySkill()
  local weaponDataGunWeaponModPropertyListWithAddValue = self.weaponCmdData.GunWeaponModPropertyListWithAddValue
  local weaponDataExtraCapacityMods = self.weaponCmdData.ExtraCapacityMods
  local length = weaponDataGunWeaponModPropertyListWithAddValue.Count + proficiencySkillDatas.Count + weaponDataExtraCapacityMods.Count
  for i = 0, tmpParent.childCount - 1 do
    tmpParent:GetChild(i).gameObject:SetActive(false)
  end
  if length == 0 then
    setactive(tmpParent.gameObject, false)
  else
    setactive(tmpParent.gameObject, true)
    local index = 0
    local hint2 = TableData.GetHintById(250056)
    for i = 0, weaponDataExtraCapacityMods.Count - 1 do
      local gunWeaponModData = weaponDataExtraCapacityMods[i]
      local item
      if index < tmpParent.childCount then
        item = tmpParent:GetChild(index)
      else
        item = instantiate(tmpProficiencySkillItem, tmpParent, false)
      end
      setactive(item.gameObject, true)
      local text = string_format(hint2, gunWeaponModData.ExtraCapacity)
      CS.GunWeaponModData.SetProficiencySkill(item, text)
      index = index + 1
    end
    local hint1 = TableData.GetHintById(250055)
    for i = 0, weaponDataGunWeaponModPropertyListWithAddValue.Count - 1 do
      local gunWeaponModProperty = weaponDataGunWeaponModPropertyListWithAddValue[i]
      local item
      if index < tmpParent.childCount then
        item = tmpParent:GetChild(index)
      else
        item = instantiate(tmpProficiencySkillItem, tmpParent, false)
      end
      setactive(item.gameObject, true)
      local text = string_format(hint1, gunWeaponModProperty.PropData.show_name.str)
      CS.GunWeaponModData.SetProficiencySkill(item, text, gunWeaponModProperty.AddLevel)
      index = index + 1
    end
    for i = 0, proficiencySkillDatas.Count - 1 do
      local proficiencySkillData = proficiencySkillDatas[i]
      local item
      if index < tmpParent.childCount then
        item = tmpParent:GetChild(index)
      else
        item = instantiate(tmpProficiencySkillItem, tmpParent, false)
      end
      setactive(item.gameObject, true)
      CS.GunWeaponModData.SetProficiencySkill(item, proficiencySkillData.description.str, proficiencySkillData.level)
      index = index + 1
    end
  end
  return 0 < length
end
function UIChrWeaponPartsReplacePanel:UpdateWeaponPartsList()
  local tmpWeaponPartsParent = self.ui.mTrans_BottomBar
  local slotList = self.weaponCmdData.slotList
  self.weaponPartUis = {}
  for i = 0, slotList.Count - 1 do
    local item
    if i >= tmpWeaponPartsParent.childCount then
      item = instantiate(self.ui.mTrans_PartsRepalceTab1, tmpWeaponPartsParent)
    else
      item = tmpWeaponPartsParent:GetChild(i)
    end
    local partItemUI = {}
    self:LuaUIBindTable(item, partItemUI)
    table.insert(self.weaponPartUis, partItemUI)
    local gunWeaponModData = self.weaponCmdData:GetWeaponPartByType(i)
    local typeId = slotList[i]
    local weaponModTypeData = TableData.listWeaponModTypeDatas:GetDataById(typeId)
    partItemUI.index = i + 1
    partItemUI.gunWeaponModData = gunWeaponModData
    partItemUI.weaponModTypeData = weaponModTypeData
    self:SetSlotData(partItemUI)
  end
  for i = 1, #self.weaponPartUis do
    UIUtils.GetButtonListener(self.weaponPartUis[i].mBtn_Root.gameObject).onClick = function()
      self:OnClickPartSlot(self.weaponPartUis[i])
    end
    if self.curSlotIndex == i then
      self.curPartItem = self.weaponPartUis[i]
      self:SetSlotSelected(self.curPartItem, true)
      UIBarrackWeaponModelManager:SetAccessoryViewByWeaponIdAndSlotIndex(self.weaponCmdData.stc_id, self.curSlotIndex - 1, true)
      self:ShowWeaponPartOutline()
    end
  end
end
function UIChrWeaponPartsReplacePanel:UpdateSortContent()
  local weaponPartsList = NetCmdWeaponPartsData:GetReplaceWeaponPartsListByType(self.weaponCmdData.slotList[self.curSlotIndex - 1], 0, self.curSlotIndex)
  if self.comScreenItemV2 == nil then
    self.comScreenItemV2 = ComScreenItemHelper:InitWeaponPart(self.ui.mScrollListChild_GrpScreen.gameObject, weaponPartsList, function()
      self.comScreenItemV2:DoSort()
      self:UpdateReplaceList()
    end, nil, self.weaponCmdData:GetWeaponPartTypeBySlotIndex(self.curSlotIndex - 1))
    self.comScreenItemV2.IsDown = false
    self.comScreenItemV2:SwitchPreset(1)
  else
    self.comScreenItemV2.SlotId = self.weaponCmdData:GetWeaponPartTypeBySlotIndex(self.curSlotIndex - 1)
    self.comScreenItemV2:ResetScreenData()
    self.comScreenItemV2:SetList(weaponPartsList)
  end
  setactive(self.ui.mTrans_PartsList.gameObject, true)
  self.comScreenItemV2:DoFilter()
  self:UpdateReplaceList()
  local modFixData = TableData.listModFixDatas:GetDataById(self.curSlotIndex)
  local tmpHintTable = {}
  for i = 0, modFixData.effect_type.Count - 1 do
    local effectId = modFixData.effect_type[i]
    local effectTypeData = TableData.listModEffectTypeDatas:GetDataById(effectId)
    table.insert(tmpHintTable, effectTypeData.Name.str)
  end
  local hintStr = string_format(TableData.GetHintById(250018), table.unpack(tmpHintTable))
  self.ui.mText_Tip.text = hintStr
end
function UIChrWeaponPartsReplacePanel:UpdateReplaceList()
  if self.comScreenItemV2 == nil then
    return
  end
  self.weaponPartsList = self.comScreenItemV2:GetResultList()
  if self.gunWeaponModData ~= nil then
    for i = 0, self.weaponPartsList.Count - 1 do
      local gunWeaponModData = self.weaponPartsList[i]
      if gunWeaponModData.id == self.gunWeaponModData.id then
        self.weaponPartsList:RemoveAt(i)
        self.weaponPartsList:Insert(0, gunWeaponModData)
      end
    end
  end
  local weaponPartsList = NetCmdWeaponPartsData:GetReplaceWeaponPartsListByType(self.weaponCmdData.slotList[self.curSlotIndex - 1], 0, self.curSlotIndex)
  setactive(self.ui.mScrollListChild_GrpScreen.transform.parent.gameObject, 0 < weaponPartsList.Count)
  setactive(self.ui.mTrans_NoParts.gameObject, self.weaponPartsList.Count == 0)
  self.ui.mAnimator_GrpPartsAdditionWindow.enabled = 0 < self.weaponPartsList.Count
  setactive(self.ui.mBtn_On.gameObject, 0 < self.weaponPartsList.Count)
  setactive(self.ui.mTrans_PartsAdditionInfo.gameObject, false)
  setactive(self.ui.mBtn_Off.gameObject, 0 < self.weaponPartsList.Count)
  local itemDataList = LuaUtils.ConvertToItemIdList(self.weaponPartsList)
  self.ui.mVirtualListEx_GrpList:SetItemIdList(itemDataList)
  self.ui.mVirtualListEx_GrpList.numItems = self.weaponPartsList.Count
  self.ui.mVirtualListEx_GrpList:Refresh()
  if self.ui.mToggle_Contrast.isOn and self.weaponPartsList.Count == 0 then
    self.ui.mToggle_Contrast.isOn = false
  end
end
function UIChrWeaponPartsReplacePanel:SetSlotData(partItem)
  local gunWeaponModData = partItem.gunWeaponModData
  local weaponModTypeData = partItem.weaponModTypeData
  local typeId = weaponModTypeData.id
  partItem.mImg_Icon.sprite = IconUtils.GetWeaponPartIconSprite(weaponModTypeData.icon, false)
  partItem.mAnimator_Root:SetBool("Equip", gunWeaponModData ~= nil)
  if gunWeaponModData == nil then
    setactive(partItem.mObj_RedPoint.transform.parent, NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, 0, partItem.index, self.weaponCmdData.id))
  else
    setactive(partItem.mObj_RedPoint.transform.parent, NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, gunWeaponModData.stcId, partItem.index, self.weaponCmdData.id))
  end
end
function UIChrWeaponPartsReplacePanel:OnClickPartSlot(partItemUI)
  if partItemUI == nil or partItemUI.index == self.curPartItem.index then
    return
  end
  self.curSelectGunWeaponModData = nil
  self.curClickItemId = 0
  self.comScreenItemV2:ResetMultipleFilter()
  self.weaponCmdData:ResetPreviewWeaponMod()
  setactive(self.ui.mMonoScrollerFadeManager_Content.gameObject, false)
  setactive(self.ui.mMonoScrollerFadeManager_Content.gameObject, true)
  if self.needStopOutlineEffect or self.curSlotIndex ~= partItemUI.index then
    UIBarrackWeaponModelManager:StopOutlineEffect()
  end
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
  self.curSlotIndex = partItemUI.index
  if self.curPartItem ~= nil then
    self:SetSlotSelected(self.curPartItem, false)
  end
  self.curPartItem = partItemUI
  self:SetSlotSelected(self.curPartItem, true)
  self.gunWeaponModData = self.curPartItem.gunWeaponModData
  if self.curSelectPartItem ~= nil then
    self.curSelectPartItem = nil
  end
  self.ui.mToggle_Contrast.isOn = false
  self:UpdateSortContent()
  self.needRefreshLeft = not self.ui.mTrans_NowSelectedPartsInfo.gameObject.activeSelf and 0 < self.weaponPartsList.Count
  setactive(self.ui.mTrans_NowSelectedPartsInfo.gameObject, 0 < self.weaponPartsList.Count)
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
  UIBarrackWeaponModelManager:SetAccessoryViewByWeaponIdAndSlotIndex(self.weaponCmdData.stc_id, self.curSlotIndex - 1, true)
  self:ShowWeaponPartOutline()
  self:SetAdditionWeaponData()
  self.ui.mVirtualListEx_GrpList.horizontalNormalizedPosition = 0
  self:UpdateCapacity()
end
function UIChrWeaponPartsReplacePanel:ShowWeaponPartOutline(weaponCmdData)
  UIBarrackWeaponModelManager:OnShowWeaponPartBySlotIndex(self.curSlotIndex - 1, weaponCmdData)
  UIBarrackWeaponModelManager:StartOutlineEffect()
end
function UIChrWeaponPartsReplacePanel:SetSlotSelected(partItemUI, enabled)
  partItemUI.mBtn_Root.interactable = not enabled
  local gunWeaponModData = partItemUI.gunWeaponModData
  partItemUI.mAnimator_Root:SetBool("Equip", gunWeaponModData ~= nil or partItemUI.index == self.curSlotIndex)
end
function UIChrWeaponPartsReplacePanel:InitWeaponPartList()
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVirtualListEx_GrpList:SetConstraintCount(1)
  self.ui.mVirtualListEx_GrpList.itemProvider = self.itemProvider
  self.ui.mVirtualListEx_GrpList.itemRenderer = self.itemRenderer
end
function UIChrWeaponPartsReplacePanel:ItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform, false)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIChrWeaponPartsReplacePanel:ItemRenderer(index, renderDataItem)
  if self.weaponPartsList == nil then
    return
  end
  local itemData = self.weaponPartsList[index]
  local item = renderDataItem.data
  item.index = index
  item:SetPartData(itemData)
  self:SetItemCapcity(item, itemData)
  item:SetNowEquip(false)
  item:SetSelect(false)
  if item ~= nil and self.curPartItem ~= nil and self.curPartItem.gunWeaponModData ~= nil and item.partData.id == self.curPartItem.gunWeaponModData.id then
    item:SetNowEquip(true)
    item:SetSelect(true)
    setactive(item.ui.mTrans_Equipped_InGun, false)
    setactive(item.ui.mImage_Head, false)
    setactive(item.ui.mTrans_Equipped_InWeapon, false)
  end
  if self.curClickItemId ~= 0 then
    if item.partData.id == self.curClickItemId then
      self:OnClickPart(item)
    end
  elseif self.curSelectPartItem == nil then
    self:OnClickPart(item)
  elseif index == 0 then
    self:OnClickPart(item)
  end
  setactive(item.ui.mTrans_RedPoint, self.weaponCmdData:IsHeigherMod(itemData, self.curSlotIndex - 1))
  UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
    self:OnClickPart(item)
  end
end
function UIChrWeaponPartsReplacePanel:OnClickPart(item)
  self.curSelectGunWeaponModData = item.partData
  self.weaponCmdData:ResetPreviewWeaponMod()
  if self.curSelectPartItem ~= nil then
    self.curSelectPartItem:SetItemSelect(false)
  end
  self.curSelectPartItem = item
  self.curClickItemId = self.curSelectPartItem.partData.id
  self.curSelectPartItem:SetItemSelect(true)
  local previewWeaponCmdData = self.weaponCmdData:GetPreviewPart(self.curSelectGunWeaponModData.id, self.curSlotIndex - 1)
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(previewWeaponCmdData)
  self.weaponCmdData:PreviewWeaponMod(self.curSelectGunWeaponModData.id, self.curSlotIndex - 1)
  self:SetWeaponPartsData()
  self:ShowWeaponPartOutline(previewWeaponCmdData)
  self:UpdateLockStatue()
  if self.gunWeaponModData ~= nil and self.curSelectGunWeaponModData.id == self.gunWeaponModData.id and self.ui.mToggle_Contrast.isOn then
    self.ui.mToggle_Contrast.isOn = false
  end
  if self.ui.mToggle_Contrast.isOn then
    self.chrWeaponPartsInfoItem1 = ComPropsDetailsHelper:InitWeaponPartsDataV2(self.ui.mScrollListChild_GrpNowSel.transform, self.curSelectGunWeaponModData.id, 0, function()
      self:ComPropsDetailsLockItemCallback()
    end)
    self.chrWeaponPartsInfoItem2 = ComPropsDetailsHelper:InitWeaponPartsDataV2(self.ui.mScrollListChild_GrpSetted.transform, self.gunWeaponModData.id, 1, function()
      self:ComPropsDetailsLockItemCallback()
    end)
  end
  self:UpdateCapacity()
end
function UIChrWeaponPartsReplacePanel:ScrollToCurItem()
  if self.curSelectGunWeaponModData ~= nil then
  else
    return
  end
  for i = 0, self.weaponPartsList.Count - 1 do
    local itemData = self.weaponPartsList[i]
    if self.curSelectGunWeaponModData.id == itemData.id then
      self.ui.mVirtualListEx_GrpList:DelayScrollToPosByIndex(i)
    end
  end
end
function UIChrWeaponPartsReplacePanel:SetItemCapcity(item, itemData)
  setactive(item.ui.mTrans_WeaponPartVolume.gameObject, false)
  return
end
function UIChrWeaponPartsReplacePanel:SetCurSelectItemCapcity(tmpGunWeaponModData)
  return
end
function UIChrWeaponPartsReplacePanel:SetEscapeBind(btn)
  if btn == nil then
    btn = self.ui.mBtn_BtnBack
  end
  self:UnRegistrationKeyboard(KeyCode.Escape)
  self:RegistrationKeyboard(KeyCode.Escape, btn)
end
function UIChrWeaponPartsReplacePanel:OnClickGFToggle(isOn)
  if isOn then
    setactive(self.ui.mTrans_Compare.gameObject, true)
    self.ui.mText_Toggle.text = self.ToggleHintStr[2]
    self.chrWeaponPartsInfoItem1 = ComPropsDetailsHelper:InitWeaponPartsDataV2(self.ui.mScrollListChild_GrpNowSel.transform, self.curSelectGunWeaponModData.id, 0, function()
      self:ComPropsDetailsLockItemCallback()
    end)
    self.chrWeaponPartsInfoItem2 = ComPropsDetailsHelper:InitWeaponPartsDataV2(self.ui.mScrollListChild_GrpSetted.transform, self.gunWeaponModData.id, 1, function()
      self:ComPropsDetailsLockItemCallback()
    end)
    self:SetEscapeBind(self.ui.mBtn_Close)
  else
    self.ui.mText_Toggle.text = self.ToggleHintStr[1]
    if self.chrWeaponPartsInfoItem1 ~= nil then
      self.chrWeaponPartsInfoItem1:ShowOrHide(false, true, function()
        setactive(self.ui.mTrans_Compare.gameObject, false)
      end)
    end
    if self.chrWeaponPartsInfoItem2 ~= nil then
      self.chrWeaponPartsInfoItem2:ShowOrHide(false, true)
    end
    self:SetEscapeBind()
  end
end
function UIChrWeaponPartsReplacePanel:ComPropsDetailsLockItemCallback()
  if self.curSelectPartItem ~= nil then
    local gunWeaponModData = self.weaponPartsList[self.curSelectPartItem.index]
    gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(gunWeaponModData.id)
    setactive(self.curSelectPartItem.ui.mTrans_Lock.gameObject, gunWeaponModData.IsLocked)
  end
  local gunWeaponModData = self.weaponPartsList[1]
  gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(gunWeaponModData.id)
  self.ui.mVirtualListEx_GrpList:RefreshItem(0)
end
function UIChrWeaponPartsReplacePanel:OnClickShowAdditionWindow(boolean)
  if boolean then
    self.ui.mAnimator_GrpPartsAdditionWindow:ResetTrigger("Fadeout")
    self.ui.mAnimator_GrpPartsAdditionWindow:SetTrigger("FadeIn")
  else
    self.ui.mAnimator_GrpPartsAdditionWindow:ResetTrigger("FadeIn")
    self.ui.mAnimator_GrpPartsAdditionWindow:SetTrigger("Fadeout")
  end
end
function UIChrWeaponPartsReplacePanel:InitShowAdditionWindow(boolean)
  setactive(self.ui.mBtn_On.gameObject, not boolean)
  setactive(self.ui.mTrans_PartsAdditionInfo.gameObject, boolean)
  setactive(self.ui.mBtn_Off.gameObject, boolean)
end
function UIChrWeaponPartsReplacePanel:OnClickBtnLvUp()
  self.ui.mToggle_Contrast.isOn = false
  local param = {
    [1] = self.curSelectGunWeaponModData,
    [2] = UIWeaponGlobal.WeaponPartPanelTab.Enhance
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPartsPowerUpPanelV4, param)
end
function UIChrWeaponPartsReplacePanel:OnClickBtnPolarity()
  self:OnClickBtnLvUp()
end
function UIChrWeaponPartsReplacePanel:SendWeaponPartBelong(weaponModId, weaponId, slotIndex, hintId)
  NetCmdWeaponPartsData:ReqWeaponPartBelong(weaponModId, weaponId, slotIndex, function(ret)
    if ret == ErrorCodeSuc then
      self.gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(weaponModId)
      self.curSelectGunWeaponModData = self.gunWeaponModData
      self.weaponCmdData = NetCmdWeaponData:GetWeaponById(weaponId)
      self:SetWeaponPartsData()
      self.ui.mToggle_Contrast.isOn = false
      self:UpdateWeaponPartsList()
      self.comScreenItemV2:DoSort()
      self:UpdateReplaceList()
      self.curClickItemId = 0
      UIUtils.PopupPositiveHintMessage(hintId)
    end
  end)
end
function UIChrWeaponPartsReplacePanel:OnClickBtnRepalce()
  if self.isOverflow then
    local curEquipGunWeaponModData = self.weaponCmdData:GetWeaponPartByType(self.curSlotIndex - 1)
    if curEquipGunWeaponModData == nil then
      PopupMessageManager.PopupString(TableData.GetHintById(250063))
    else
      PopupMessageManager.PopupString(TableData.GetHintById(250053))
    end
    return
  end
  local index = self.curSlotIndex
  local curEquipGunWeaponModData = self.weaponCmdData:GetWeaponPartByType(self.curSlotIndex - 1)
  local hintId
  if curEquipGunWeaponModData == nil then
    hintId = 250010
  else
    hintId = 250012
  end
  local onReplaceWeaponPart = function()
    self:SendWeaponPartBelong(self.curSelectGunWeaponModData.id, self.weaponCmdData.id, index, hintId)
    self.curPartItem.gunWeaponModData = self.curSelectGunWeaponModData
    self.ui.mVirtualListEx_GrpList.horizontalNormalizedPosition = 0
  end
  local equipWeapon = self.curSelectGunWeaponModData.equipWeapon
  if 0 < equipWeapon then
    local weaponData = NetCmdWeaponData:GetWeaponById(equipWeapon)
    local weaponName = weaponData.Name
    local rankColor = TableDataBase.GlobalConfigData.GunQualityColor2[weaponData.Rank - 1]
    local colorName = string_format("<color=#{0}>{1}</color>", rankColor, weaponName)
    local contentText = string_format(TableData.GetHintById(102216), colorName)
    if weaponData.gun_id ~= 0 then
      local GunCmdData = NetCmdTeamData:GetGunByStcId(weaponData.gun_id)
      local rankGunColor = TableDataBase.GlobalConfigData.GunQualityColor2[GunCmdData.rank - 1]
      local colorGunName = string_format("<color=#{0}>{1}</color>", rankGunColor, GunCmdData.gunData.Name.str)
      contentText = string_format(TableData.GetHintById(250020), colorGunName, colorName)
    end
    local param = {
      contentText = contentText,
      customData = weaponData,
      isDouble = true,
      confirmCallback = onReplaceWeaponPart,
      dialogType = 1
    }
    UIManager.OpenUIByParam(UIDef.UIComDoubleCheckDialog, param)
  else
    onReplaceWeaponPart()
  end
end
function UIChrWeaponPartsReplacePanel:OnClickBtnUnload()
  if self.curSelectGunWeaponModData ~= nil then
    local index = self.curSlotIndex
    local uninstallClick = function()
      self:SendWeaponPartBelong(0, self.weaponCmdData.id, index, 250011)
      self.curPartItem.gunWeaponModData = nil
    end
    local uninstallList = self.weaponCmdData:UninstallWeaponPart(index - 1)
    if uninstallList ~= nil and uninstallList.Count > 0 then
      local param = {
        contentText = TableData.GetHintById(220076),
        customData = uninstallList,
        isDouble = true,
        confirmCallback = uninstallClick,
        dialogType = 2
      }
      UIManager.OpenUIByParam(UIDef.UIComDoubleCheckDialog, param)
    else
      uninstallClick()
    end
  end
end
function UIChrWeaponPartsReplacePanel:OnClickBtnCantLvUp()
  local unlockData = AccountNetCmdHandler:GetUnlockDataBySystemId(SystemList.GundetailWeaponpartUpgrade)
  local str = UIUtils.CheckUnlockPopupStr(unlockData)
  PopupMessageManager.PopupString(str)
end
function UIChrWeaponPartsReplacePanel:OnClickBtnCantPolarityConditionLv()
  local unlockData = AccountNetCmdHandler:GetUnlockDataBySystemId(SystemList.GundetailWeaponpartPolarity)
  local str = UIUtils.CheckUnlockPopupStr(unlockData)
  PopupMessageManager.PopupString(str)
end
function UIChrWeaponPartsReplacePanel:OnClickBtnCantPolarityConditionEffect()
  local hint = TableData.GetHintById(250058)
  CS.PopupMessageManager.PopupString(hint)
end
function UIChrWeaponPartsReplacePanel:UpdateBtnRedPoint()
  local isEquipBtnActive = self.ui.mBtn_BtnEquip.transform.parent.gameObject.activeSelf
  local isReplaceBtnActive = self.ui.mBtn_BtnRepalce.transform.parent.gameObject.activeSelf
  local islvUpBtnActive = self.ui.mBtn_BtnLvUp.transform.parent.gameObject.activeSelf
  local ispolarityBtnActive = self.ui.mBtn_BtnPolarity.transform.parent.gameObject.activeSelf
  local gunWeaponModData = self.curPartItem.gunWeaponModData
  local typeId = self.curPartItem.weaponModTypeData.id
  setactive(self.equipBtnRedPoint.gameObject, isEquipBtnActive and NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, 0, self.curSlotIndex, self.weaponCmdData.id))
  local tmpStcId = 0
  if gunWeaponModData ~= nil then
    tmpStcId = gunWeaponModData.stcId
  end
  setactive(self.replaceBtnRedPoint.gameObject, isReplaceBtnActive and NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, tmpStcId, self.curSlotIndex, self.weaponCmdData.id))
  setactive(self.polarityBtnRedPoint.gameObject, ispolarityBtnActive and gunWeaponModData ~= nil and gunWeaponModData:CanGunWeaponModPolarity())
end
