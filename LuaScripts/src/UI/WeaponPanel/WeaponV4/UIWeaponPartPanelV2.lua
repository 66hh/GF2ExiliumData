require("UI.WeaponPanel.WeaponV4.Item.ChrWeaponPartAttributeItemV4")
require("UI.WeaponPanel.UIWeaponGlobal")
UIWeaponPartPanelV2 = class("UIWeaponPartPanelV2", UIBasePanel)
UIWeaponPartPanelV2.__index = UIWeaponPartPanelV2
function UIWeaponPartPanelV2:ctor(root, uiChrWeaponPanelV4)
  UIWeaponPartPanelV2.super:ctor(csPanel)
  self.mUIRoot = root
  self.uiChrWeaponPanelV4 = uiChrWeaponPanelV4
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.weaponCmdData = nil
  self.groupSkillData = nil
  self.proficiencySkillData = nil
  self.weaponPartUis = {}
  self.curPartItem = nil
  self.chrWeaponPartsInfoItem = nil
  self.hasSkill = false
  self.hasAttribute = false
  self.isGroupSkillActive = false
end
function UIWeaponPartPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIWeaponPartPanelV2:OnInit(data)
  self.weaponCmdData = data
  UIUtils.GetButtonListener(self.ui.mBtn_Attribute.gameObject).onClick = function()
    self:ShowAttributeOrEffect(true)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Effect.gameObject).onClick = function()
    self:ShowAttributeOrEffect(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Set.gameObject).onClick = function()
    self:OnClickSet()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Unload.gameObject).onClick = function()
    self:OnClickUnload()
  end
end
function UIWeaponPartPanelV2:OnTabChanged(boolean)
  if boolean then
    UIBarrackWeaponModelManager:EnterPreAccessoryView()
  else
    UIBarrackWeaponModelManager:ExitPreAccessoryView()
  end
end
function UIWeaponPartPanelV2:OnShowStart()
  self:SetWeaponPartData()
end
function UIWeaponPartPanelV2:OnRecover()
  self:SetWeaponPartData()
end
function UIWeaponPartPanelV2:OnBackFrom()
  self:SetWeaponPartData()
end
function UIWeaponPartPanelV2:OnTop()
end
function UIWeaponPartPanelV2:OnShowFinish()
end
function UIWeaponPartPanelV2:OnRefresh()
  self:SetWeaponPartData()
end
function UIWeaponPartPanelV2:OnHide()
end
function UIWeaponPartPanelV2:OnHideFinish()
end
function UIWeaponPartPanelV2:Show(isShow)
  if not isShow then
    self:OnClose()
  end
  self.super.Show(self, isShow)
end
function UIWeaponPartPanelV2:OnClose()
  ComPropsDetailsHelper:Close()
  if self.curPartItem ~= nil then
    self:SetPartItemSelected(self.curPartItem, true)
  end
end
function UIWeaponPartPanelV2:OnRelease()
  self.super.OnRelease(self)
end
function UIWeaponPartPanelV2:SetWeaponPartData()
  self:UpdateWeaponCapacity()
  self:UpdateWeaponPartsList()
  self:UpdateAttribute()
  self:UpdateWeaponPartSkill()
  self:ShowAttributeOrEffect(true)
  self.uiChrWeaponPanelV4:SetEscapeEnabled(true)
end
function UIWeaponPartPanelV2:UpdateWeaponCapacity()
  self.uiChrWeaponPanelV4:UpdateWeaponCapacity()
end
function UIWeaponPartPanelV2:UpdateWeaponPartsList()
  local tmpWeaponPartsParent = self.ui.mTrans_WeaponParts
  local tmpWeaponPartsSlot = self.ui.mTrans_WeaponParts1
  local slotList = self.weaponCmdData.slotList
  for i = 0, slotList.Count - 1 do
    local item
    local partItemUI = {}
    if i + 1 > #self.weaponPartUis and i >= tmpWeaponPartsParent.childCount then
      item = instantiate(tmpWeaponPartsSlot, tmpWeaponPartsParent)
      self:LuaUIBindTable(item, partItemUI)
      table.insert(self.weaponPartUis, partItemUI)
    else
      if i + 1 > #self.weaponPartUis then
        item = tmpWeaponPartsParent:GetChild(i)
        table.insert(self.weaponPartUis, partItemUI)
      else
        item = self.weaponPartUis[i + 1].mUIRoot
      end
      self:LuaUIBindTable(item, partItemUI)
    end
    setactive(item.gameObject, true)
    local gunWeaponModData = self.weaponCmdData:GetWeaponPartByType(i)
    partItemUI.index = i + 1
    partItemUI.gunWeaponModData = gunWeaponModData
    self.weaponPartUis[i + 1] = partItemUI
    self:SetSlotData(partItemUI, gunWeaponModData, slotList[i], i + 1)
  end
  for i, v in ipairs(self.weaponPartUis) do
    UIUtils.GetButtonListener(v.mBtn_WeaponParts1.gameObject).onClick = function()
      self:OnClickPart(i)
    end
  end
  ComPropsDetailsHelper:Close()
end
function UIWeaponPartPanelV2:UpdateAttribute()
  local attrList = {}
  local tmpWeaponCmdData = self.weaponCmdData
  local tmpAttrParent = self.ui.mTrans_Attribute.transform
  self.subPropList = CS.WeaponCmdData.SetWeaponPartsAttrWithoutWeapon(tmpWeaponCmdData, tmpAttrParent)
  self.hasAttribute = self.subPropList.Count > 0
  setactive(tmpAttrParent.gameObject, false)
  setactive(tmpAttrParent.gameObject, true)
end
function UIWeaponPartPanelV2:UpdateWeaponPartSkill()
  self.isGroupSkillActive = false
  local groupSkillItems, isGroupSkillActive = CS.WeaponCmdData.SetWeaponGroupSkillData(self.ui.mTrans_GroupSkill, self.weaponCmdData, self.isGroupSkillActive)
  local hasProficiency = self:GetWeaponPartProficiencySkill() > 0
  local hasGroup = 0 < groupSkillItems.Count
  setactive(self.ui.mTrans_ListEffect.gameObject, hasGroup or hasProficiency)
  self.isGroupSkillActive = isGroupSkillActive
  setactive(self.ui.mTrans_ImgLine.gameObject, hasProficiency and hasGroup)
  self.hasSkill = hasGroup or hasProficiency
end
function UIWeaponPartPanelV2:GetWeaponPartProficiencySkill()
  local tmpParent = self.ui.mTrans_OtherSkill.parent
  local count = CS.WeaponCmdData.SetWeaponPartProficiencySkill(self.weaponCmdData, tmpParent)
  return count
end
function UIWeaponPartPanelV2:SwitchGun(gunCmdData, isShow)
  if isShow then
    UIBarrackWeaponModelManager:EnterPreAccessoryView(false)
  end
  self.gunCmdData = gunCmdData
  self.weaponCmdData = gunCmdData.WeaponData
  self:SetWeaponPartData()
end
function UIWeaponPartPanelV2:SetSlotData(partItem, gunWeaponModData, typeId, slotId)
  setactive(partItem.mTrans_Equiped.gameObject, gunWeaponModData ~= nil)
  setactive(partItem.mTrans_Quality.gameObject, gunWeaponModData ~= nil)
  setactive(partItem.mImg_PartsIconE.gameObject, gunWeaponModData ~= nil)
  setactive(partItem.mImg_PartsIcon.gameObject, gunWeaponModData == nil)
  setactive(partItem.mImg_PolarityIcon.gameObject, false)
  setactive(partItem.mImg_PolarityIconGlow.gameObject, false)
  partItem.mCanvasGroup_PolarityIcon.alpha = 0.3
  if gunWeaponModData == nil then
    local slotData = TableData.listWeaponModTypeDatas:GetDataById(typeId)
    partItem.mImg_PartsIcon.sprite = IconUtils.GetWeaponPartIconSprite(slotData.icon, false)
    setactive(partItem.mObj_RedPoint.parent, NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, 0, slotId, self.weaponCmdData.id))
    setactive(partItem.mImg_SkillIcon.gameObject, false)
    setactive(partItem.mImg_TypeIcon.gameObject, false)
    local modFixData = TableData.listModFixDatas:GetDataById(slotId)
    if modFixData.suggest_effect_type ~= 0 then
      setactive(partItem.mImg_TypeIcon.gameObject, true)
      local modEffectTypeData = TableData.listModEffectTypeDatas:GetDataById(modFixData.suggest_effect_type)
      partItem.mImg_TypeIcon.sprite = ResSys:GetWeaponPartEffectSprite(modEffectTypeData.icon)
      UIUtils.SetAlpha(partItem.mImg_TypeIcon, 0.19)
    end
    if self.weaponCmdData.Polarization[slotId - 1] ~= 0 then
      setactive(partItem.mImg_PolarityIcon.gameObject, true)
      local polarityId = self.weaponCmdData.Polarization[slotId - 1]
      local polarityTagData = TableData.listPolarityTagDatas:GetDataById(polarityId)
      partItem.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(polarityTagData.icon .. "_S")
      UIUtils.SetAlpha(partItem.mImg_PolarityIcon, 0.4)
    else
      setactive(partItem.mImg_PolarityIcon.gameObject, false)
    end
  else
    partItem.mImg_TypeIcon.sprite = ResSys:GetWeaponPartEffectSprite(gunWeaponModData.ModEffectTypeData.icon)
    setactive(partItem.mImg_TypeIcon.gameObject, true)
    UIUtils.SetAlpha(partItem.mImg_TypeIcon, 1)
    partItem.mImg_PartsIconE.sprite = IconUtils.GetWeaponPartIconSprite(gunWeaponModData.icon)
    partItem.mImg_Quality.color = TableData.GetGlobalGun_Quality_Color2(gunWeaponModData.rank, partItem.mImg_Quality.color.a)
    partItem.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(gunWeaponModData.rank, partItem.mImg_QualityLine.color.a)
    CS.GunWeaponModData.SetModLevelText(partItem.mText_Num, gunWeaponModData, nil, false)
    local groupSkillData = gunWeaponModData.GroupSkillData
    if nil == groupSkillData then
      setactive(partItem.mImg_SkillIcon.gameObject, false)
    else
      setactive(partItem.mImg_SkillIcon.gameObject, true)
      partItem.mImg_SkillIcon.sprite = IconUtils.GetWeaponPartIconSprite(gunWeaponModData.ModPowerData.image, false)
    end
    setactive(partItem.mObj_RedPoint.parent, NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, gunWeaponModData.stcId, slotId, self.weaponCmdData.id) or gunWeaponModData:CanGunWeaponModPolarity())
    if gunWeaponModData ~= nil and gunWeaponModData.PolarityTagData ~= nil then
      setactive(partItem.mImg_PolarityIcon.gameObject, true)
      partItem.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(gunWeaponModData.PolarityTagData.icon .. "_S")
      UIUtils.SetAlpha(partItem.mImg_PolarityIcon, 1)
      local polarityId = self.weaponCmdData.Polarization[slotId - 1]
      setactive(partItem.mImg_PolarityIconGlow.gameObject, gunWeaponModData.PolarityTagData.polarity_id == polarityId)
      partItem.mImg_PolarityIconGlow.sprite = IconUtils.GetElementIcon(gunWeaponModData.PolarityTagData.icon .. "_S")
      partItem.mCanvasGroup_PolarityIcon.alpha = 1
    else
      setactive(partItem.mImg_PolarityIcon.gameObject, false)
    end
  end
end
function UIWeaponPartPanelV2:OnClickPart(slotIndex)
  self.curSlotIndex = slotIndex
  local gunWeaponModData = self.weaponCmdData:GetWeaponPartByType(slotIndex - 1)
  if gunWeaponModData == nil then
    self:OnClickReplace()
    return
  end
  self.chrWeaponPartsInfoItem = ComPropsDetailsHelper:InitWeaponPartsDataV2(self.ui.mScrollListChild_GrpNowSel.transform, gunWeaponModData.id)
  self.chrWeaponPartsInfoItem:SetBlockUIRoot(self.ui.mTrans_WeaponParts.gameObject, nil, function()
    self:OnClickBlock()
  end)
  local parentRect = self.ui.mScrollListChild_GrpNowSel.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
  local itemRect = self.chrWeaponPartsInfoItem.GameObject:GetComponent("RectTransform")
  local deltaRectX = (parentRect.rect.width - itemRect.rect.width) / (UIWeaponGlobal.WeaponMaxSlot - 1)
  local targetX = deltaRectX * (slotIndex - 1)
  itemRect.anchoredPosition = Vector2(targetX, itemRect.anchoredPosition.y)
  self.chrWeaponPartsInfoItem:SetReplaceBtnClick(function()
    self:OnClickReplace()
  end)
  self.chrWeaponPartsInfoItem:SetLvUpBtnClick(function()
    self:OnClickLvUp()
  end)
  self.chrWeaponPartsInfoItem:SetPolarityBtnClick(function()
    self:OnClickPolarity()
  end)
  if self.curPartItem ~= nil then
    self:SetPartItemSelected(self.curPartItem, true)
  end
  self.curPartItem = self.weaponPartUis[slotIndex]
  self:SetPartItemSelected(self.curPartItem, false)
end
function UIWeaponPartPanelV2:SetPartItemSelected(partItem, boolean)
  partItem.mBtn_WeaponParts1.interactable = boolean
end
function UIWeaponPartPanelV2:ShowAttributeOrEffect(boolean)
  self.ui.mBtn_Attribute.interactable = not boolean
  setactive(self.ui.mTrans_ListAttribute.gameObject, boolean)
  self.ui.mBtn_Effect.interactable = boolean
  setactive(self.ui.mTrans_ListEffect.gameObject, not boolean)
  local targetBoolean
  if boolean then
    self.ui.mText_None.text = TableData.GetHintById(250059)
    targetBoolean = self.hasAttribute
  else
    self.ui.mText_None.text = TableData.GetHintById(250060)
    targetBoolean = self.hasSkill
  end
  if targetBoolean then
    setactive(self.ui.mText_None.gameObject, false)
  else
    setactive(self.ui.mText_None.gameObject, true)
    setactive(self.ui.mTrans_ListEffect.gameObject, false)
  end
end
function UIWeaponPartPanelV2:OnClickBlock()
  ComPropsDetailsHelper:ShowOrHide(false)
  if self.curPartItem ~= nil then
    self:SetPartItemSelected(self.curPartItem, true)
  end
end
function UIWeaponPartPanelV2:OnClickReplace()
  self:OnClickBlock()
  local param = {
    weaponCmdData = self.weaponCmdData,
    curSlotIndex = self.curSlotIndex
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPartsReplacePanel, param)
end
function UIWeaponPartPanelV2:OnClickLvUp()
  self:OnClickBlock()
  local param = {
    [1] = self.curPartItem.gunWeaponModData,
    [2] = UIWeaponGlobal.WeaponPartPanelTab.Enhance
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPartsPowerUpPanelV4, param)
end
function UIWeaponPartPanelV2:OnClickPolarity()
  self:OnClickLvUp()
end
function UIWeaponPartPanelV2:OnClickSet()
  if not self:CheckHasHeigherNotUsedMod() then
    if self:CheckCapacity() then
      UIUtils.PopupPositiveHintMessage(102281)
      return
    end
    UIUtils.PopupHintMessage(102280)
    return
  end
  self.curAddModSlotIndex = 1
  self:SetMask(true)
  self:SetModBySlotIndex(self.curAddModSlotIndex)
end
function UIWeaponPartPanelV2:CheckCapacity()
  local realCapacity = self.weaponCmdData.RealCapacity
  local allCapacity = self.weaponCmdData:GetAllWeaponModCapacity()
  return realCapacity - allCapacity <= 0
end
function UIWeaponPartPanelV2:CheckHasHeigherNotUsedMod()
  local slotList = self.weaponCmdData.slotList
  return true
end
function UIWeaponPartPanelV2:SetModBySlotIndex(slotIndex)
  local slotList = self.weaponCmdData.slotList
  if slotIndex >= slotList.Count + 1 then
    self:ClickSetEnd()
    return
  end
  local gunWeaponModData = self.weaponCmdData:GetWeaponPartByType(slotIndex - 1)
  local weaponPartsList = self.weaponCmdData:GetCanUseHeigherNotUsedMod(slotIndex)
  if not self:CheckHasHeigherNotUsedMod() and weaponPartsList.Count > 0 then
    self.curAddModSlotIndex = self.curAddModSlotIndex + 1
    self:SetModBySlotIndex(self.curAddModSlotIndex)
    return
  end
  local weaponModId = self:GetModBySlotIndex(slotIndex)
  if weaponModId ~= 0 then
    self:SendWeaponPartBelong(weaponModId, self.weaponCmdData.id, slotIndex)
    return
  end
  if self.curAddModSlotIndex == slotList.Count then
    self:ClickSetEnd()
  else
    self.curAddModSlotIndex = self.curAddModSlotIndex + 1
    self:SetModBySlotIndex(self.curAddModSlotIndex)
  end
end
function UIWeaponPartPanelV2:ClickSetEnd()
  self.weaponCmdData = NetCmdWeaponData:GetWeaponById(self.weaponCmdData.id)
  self.uiChrWeaponPanelV4:SetWeaponCmdData(self.weaponCmdData.id)
  self:SetWeaponPartData()
  UIUtils.PopupHintMessage(102277)
  self.uiChrWeaponPanelV4:UpdateRedPoint()
  self.uiChrWeaponPanelV4:UpdateWeaponModel(true)
  UIBarrackWeaponModelManager:EnterPreAccessoryView(false)
  UIBarrackWeaponModelManager:PlayWeaponSwitchEffect()
  self:SetMask(false)
end
function UIWeaponPartPanelV2:SetMask(boolean)
  self.uiChrWeaponPanelV4:ShowMask(boolean)
  self.ui.mBtn_Set.enabled = not boolean
  self.ui.mBtn_Unload.enabled = not boolean
end
function UIWeaponPartPanelV2:SendWeaponPartBelong(weaponModId, weaponId, slotIndex)
  local gunWeaponModData = self.weaponCmdData:GetWeaponPartByType(slotIndex - 1)
  if gunWeaponModData ~= nil and gunWeaponModData.id == weaponModId then
    self.curAddModSlotIndex = self.curAddModSlotIndex + 1
    self:SetModBySlotIndex(self.curAddModSlotIndex)
    return
  end
  NetCmdWeaponPartsData:ReqWeaponPartBelong(weaponModId, weaponId, slotIndex, function(ret)
    if ret == ErrorCodeSuc then
      self.curAddModSlotIndex = self.curAddModSlotIndex + 1
      self:SetModBySlotIndex(self.curAddModSlotIndex)
    end
  end)
end
function UIWeaponPartPanelV2:GetModBySlotIndex(slotIndex)
  local getFirstMod = function()
    local weaponPartsList = self.weaponCmdData:GetCanUseHeigherNotUsedMod(slotIndex)
    if weaponPartsList.Count == 0 then
      return 0
    end
    local polarityId = 0
    if self.weaponCmdData.Polarization ~= nil then
      polarityId = self.weaponCmdData.Polarization[slotIndex - 1]
    end
    weaponPartsList = NetCmdWeaponPartsData:SortGunWeaponModDataWithCheckCapacity(weaponPartsList, polarityId)
    if weaponPartsList.Count > 0 then
      local gunWeaponModData = weaponPartsList[0]
      return gunWeaponModData.id
    end
    return 0
  end
  local getFirstGroupMod = function()
    local weaponPartsList = self.weaponCmdData:GetCanUseHeigherNotUsedMod(slotIndex)
    if weaponPartsList.Count == 0 then
      return 0
    end
    local modPowerDataId = 0
    if self.weaponCmdData.AllPowerMods ~= nil and 0 < self.weaponCmdData.AllPowerMods.Count then
      local tmpGunWeaponModData = self.weaponCmdData.AllPowerMods[0]
      if tmpGunWeaponModData ~= nil and tmpGunWeaponModData.ModPowerData ~= nil then
        modPowerDataId = tmpGunWeaponModData.ModPowerData.id
      end
    end
    local polarityId = 0
    if self.weaponCmdData.Polarization ~= nil then
      polarityId = self.weaponCmdData.Polarization[slotIndex - 1]
    end
    weaponPartsList = NetCmdWeaponPartsData:SortGunWeaponModDataByModPowerDataId(weaponPartsList, modPowerDataId, polarityId)
    if weaponPartsList.Count > 0 then
      local gunWeaponModData = weaponPartsList[0]
      return gunWeaponModData.id
    end
    return 0
  end
  return getFirstGroupMod()
end
function UIWeaponPartPanelV2:OnClickUnload()
  if self.weaponCmdData.PartsCount > 0 then
    NetCmdWeaponPartsData:ReqWeaponPartBelong(0, self.weaponCmdData.id, 0, function(ret)
      if ret == ErrorCodeSuc then
        self.weaponCmdData = NetCmdWeaponData:GetWeaponById(self.weaponCmdData.id)
        self.uiChrWeaponPanelV4:SetWeaponCmdData(self.weaponCmdData.id)
        self:SetWeaponPartData()
        UIUtils.PopupHintMessage(102276)
        self.uiChrWeaponPanelV4:UpdateRedPoint()
        self.uiChrWeaponPanelV4:UpdateWeaponModel(true)
        UIBarrackWeaponModelManager:EnterPreAccessoryView(false)
        UIBarrackWeaponModelManager:PlayWeaponSwitchEffect()
      end
    end)
  else
    UIUtils.PopupHintMessage(102285)
  end
end
function UIWeaponPartPanelV2:OnChangeWeapon(weaponCmdData, isShow)
  self.weaponCmdData = weaponCmdData
  if isShow then
    self:SetWeaponPartData()
  end
end
