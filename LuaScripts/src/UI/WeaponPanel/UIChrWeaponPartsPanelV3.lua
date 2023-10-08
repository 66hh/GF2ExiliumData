UIChrWeaponPartsPanelV3 = class("UIChrWeaponPartsPanelV3", UIBasePanel)
UIChrWeaponPartsPanelV3.__index = UIChrWeaponPartsPanelV3
function UIChrWeaponPartsPanelV3:ctor(csPanel)
  UIChrWeaponPartsPanelV3.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  self.weaponCmdData = nil
  self.gunWeaponModData = nil
  self.curSelectGunWeaponModData = nil
  self.curPartItem = nil
  self.tmpCurSelectWeaponPartId = 0
  self.curSlotIndex = 1
  self.weaponPartUis = {}
  self.weaponPartsList = nil
  self.subPropList = {}
  self.chrWeaponPartsSkillItem = nil
  self.curSelectPartItem = nil
  self.curItemIndex = 0
  self.lockItem = nil
  self.needStopOutlineEffect = false
  self.isShowPartsList = false
  self.needShowPartList = false
  self.isWeaponPartsReplace = false
  self.needResetCameraPosToBase = false
end
function UIChrWeaponPartsPanelV3:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.comScreenItemV2 = nil
  self.gunWeaponModData = nil
  self:InitWeaponPartList()
end
function UIChrWeaponPartsPanelV3:OnInit(root, data)
  self.gunWeaponModData = data.gunWeaponModData
  self.isWeaponPartsReplace = self.gunWeaponModData == nil
  if self.gunWeaponModData == nil then
    self.weaponCmdData = NetCmdWeaponData:GetWeaponById(data.weaponStcId)
    self.curSlotIndex = data.slotIndex
    self.gunWeaponModData = self.weaponCmdData:GetWeaponPartByType(self.curSlotIndex - 1)
    self.curSelectGunWeaponModData = self.gunWeaponModData
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    if self.isWeaponPartsReplace then
      self.needResetCameraPosToBase = false
    else
      self.needResetCameraPosToBase = true
      UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    end
    self:OnBackClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    self:ShowPartList(false)
    self.needResetCameraPosToBase = true
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    self.needStopOutlineEffect = true
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnReplace.gameObject).onClick = function()
    self:OnReplaceClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBreak.gameObject).onClick = function()
    self.needStopOutlineEffect = true
    self:OnBreakClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnEquip.gameObject).onClick = function()
    self:OnEquipClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnUninstall.gameObject).onClick = function()
    self:OnUninstallClick()
  end
  self.ui.mToggle_Contrast.onValueChanged:AddListener(function(isOn)
    setactive(self.ui.mTrans_WeaponInfo, isOn)
  end)
  BarrackHelper.CameraMgr:SetWeaponRT()
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(false)
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Weapon, false)
end
function UIChrWeaponPartsPanelV3:OnShowStart()
  self:SetWeaponPartData()
end
function UIChrWeaponPartsPanelV3:OnRecover()
  self:SetWeaponPartData()
end
function UIChrWeaponPartsPanelV3:OnBackFrom()
  self:SetWeaponPartData()
end
function UIChrWeaponPartsPanelV3:OnTop()
end
function UIChrWeaponPartsPanelV3:OnShowFinish()
  self.needStopOutlineEffect = false
end
function UIChrWeaponPartsPanelV3:OnCameraStart()
  return 0.01
end
function UIChrWeaponPartsPanelV3:OnCameraBack()
end
function UIChrWeaponPartsPanelV3:OnHide()
end
function UIChrWeaponPartsPanelV3:OnHideFinish()
  if UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
    UIModelToucher.ReleaseWeaponToucher()
    UIWeaponGlobal:ReleaseWeaponModel()
    CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  elseif self.isWeaponPartsReplace then
  end
  if self.needStopOutlineEffect and self.isWeaponPartsReplace then
    UIBarrackWeaponModelManager:StopOutlineEffect()
  end
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
    self.comScreenItemV2 = nil
  end
  self:ReleaseCtrlTable(self.subPropList, true)
  self.lockItem:OnRelease(true)
  self:ResetItemState()
end
function UIChrWeaponPartsPanelV3:OnClose()
  if self.needResetCameraPosToBase then
    FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
  end
end
function UIChrWeaponPartsPanelV3:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPartsPanelV3:InitLockItem()
  local parent = self.ui.mScrollListChild_GrpLock.transform
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
function UIChrWeaponPartsPanelV3:InitWeaponPartList()
  function self.itemProvider()
    return self:ItemProvider()
  end
  function self.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.ui.mVirtualListEx_GrpWeaponPartsList.itemProvider = self.itemProvider
  self.ui.mVirtualListEx_GrpWeaponPartsList.itemRenderer = self.itemRenderer
end
function UIChrWeaponPartsPanelV3:ItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mScrollListChild_Content.transform, false)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIChrWeaponPartsPanelV3:ItemRenderer(index, renderDataItem)
  if self.weaponPartsList == nil then
    return
  end
  local itemData = self.weaponPartsList[index]
  local item = renderDataItem.data
  item.index = index
  item:SetPartData(itemData)
  item:SetNowEquip(false)
  if self.curSelectPartItem == nil then
    if self.curPartItem ~= nil and self.curPartItem.gunWeaponModData ~= nil then
      if self.curPartItem.gunWeaponModData.id == itemData.id then
        item:SetNowEquip(true)
        self:OnClickPart(item)
      end
    elseif index == 0 then
      self:OnClickPart(item)
    end
  elseif self.curSelectPartItem ~= nil and item.index == self.curItemIndex then
    self:OnClickPart(item)
  end
  UIUtils.GetButtonListener(item.ui.mBtn_Select.gameObject).onClick = function()
    self:OnClickPart(item)
  end
end
function UIChrWeaponPartsPanelV3:SetWeaponPartData()
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(true)
  UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(false)
  setactive(self.ui.mTrans_Left.gameObject, self.isWeaponPartsReplace)
  setactive(self.ui.mImg_WeaponPartsIcon.gameObject, not self.isWeaponPartsReplace)
  setactive(self.ui.mTrans_PartsTextInfo.gameObject, not self.isWeaponPartsReplace)
  setactive(self.ui.mTrans_PartsEpuied.gameObject, not self.isWeaponPartsReplace)
  if not self.isWeaponPartsReplace then
    self.curSelectGunWeaponModData = self.gunWeaponModData
    self.ui.mImg_WeaponPartsIcon.sprite = IconUtils.GetWeaponPartIcon(self.curSelectGunWeaponModData.icon)
    self:InitLockItem()
    self:SetCurWeaponPartData()
    self:UpdateAction()
    self.ui.mText_Name.text = self.gunWeaponModData.weaponModTypeData.weapon_mod_des.str
    setactive(self.ui.mTrans_PartsEpuied.gameObject, self.gunWeaponModData.equipWeapon ~= 0)
    return
  end
  self:InitLockItem()
  self:UpdateWeaponPartsList()
  self:SetCurWeaponPartData()
  self:UpdateSortContent()
  self:UpdateAction()
end
function UIChrWeaponPartsPanelV3:SetCurWeaponPartData()
  if self.curSelectGunWeaponModData == nil and self.curPartItem ~= nil then
    self.curSelectGunWeaponModData = self.curPartItem.gunWeaponModData
  end
  local tmpGunWeaponModData = self.curSelectGunWeaponModData
  setactive(self.ui.mTrans_WeaponPartsInfo.gameObject, tmpGunWeaponModData ~= nil)
  setactive(self.ui.mTrans_Empty.gameObject, tmpGunWeaponModData == nil)
  if tmpGunWeaponModData ~= nil then
    self.ui.mText_PartsName.text = tmpGunWeaponModData.name
    self.ui.mText_TypeName.text = tmpGunWeaponModData.weaponModTypeData.Name.str
    self.ui.mText_Lv.text = tmpGunWeaponModData.level .. "/" .. tmpGunWeaponModData.maxLevel
    self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(tmpGunWeaponModData.rank, self.ui.mImg_QualityLine.color.a)
    self.subPropList = UIWeaponGlobal.SetWeaponPartAttr(tmpGunWeaponModData, self.subPropList, self.ui.mScrollListChild_GrpPartsAttributeList)
    self:UpdateSuitInfo()
    self:UpdateCompareDetail()
  end
  setactive(self.ui.mToggle_Contrast.transform.parent.gameObject, self.curSelectPartItem ~= nil and self.curPartItem.gunWeaponModData ~= nil and self.curPartItem.gunWeaponModData.id ~= self.curSelectPartItem.partData.id)
  self:UpdateAction()
end
function UIChrWeaponPartsPanelV3:UpdateSuitInfo()
  local tmpSuitParent = self.ui.mScrollListChild_GrpSkills.transform
  local obj
  if self.chrWeaponPartsSkillItem == nil then
    self.chrWeaponPartsSkillItem = CS.UI.UIGizmos.Common.Item.ChrWeaponPartsSkillItem()
  end
  if tmpSuitParent.childCount > 0 then
    obj = tmpSuitParent:GetChild(0)
  end
  self.chrWeaponPartsSkillItem:InitCtrl(tmpSuitParent, obj)
  self.chrWeaponPartsSkillItem:SetData(self.curSelectGunWeaponModData.suitId, self.curSelectGunWeaponModData.suitCount)
end
function UIChrWeaponPartsPanelV3:UpdateCompareDetail()
  if self.gunWeaponModData then
    function self.lockCallback()
      if self.curSelectPartItem ~= nil and self.isShowPartsList then
        self.ui.mVirtualListEx_GrpWeaponPartsList:RefreshItem(self.curSelectPartItem.index)
      end
      self:UpdateLockStatue()
    end
    ComPropsDetailsHelper:InitWeaponPartsData(self.ui.mTrans_WeaponInfo.transform, self.gunWeaponModData.id, self.lockCallback, true, 0, false)
    setactive(self.ui.mTrans_WeaponInfo, self.ui.mToggle_Contrast.isOn)
  end
end
function UIChrWeaponPartsPanelV3:UpdateWeaponPartsList()
  local tmpWeaponPartsParent = self.ui.mTrans_PartsChoose
  local slotList = self.weaponCmdData.slotList
  self.weaponPartUis = {}
  for i = 0, slotList.Count - 1 do
    local item
    if i >= tmpWeaponPartsParent.childCount then
      item = instantiate(self.ui.mTrans_BtnChoose1, tmpWeaponPartsParent)
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
    UIUtils.GetButtonListener(self.weaponPartUis[i].mBtn_Choose1.gameObject).onClick = function()
      self:OnClickPartSlot(self.weaponPartUis[i])
    end
    if self.curSlotIndex == i then
      self.curPartItem = self.weaponPartUis[i]
      self:SetSlotSelected(self.curPartItem, true)
      UIBarrackWeaponModelManager:SetModelTransformBySlotIndex(self.curSlotIndex - 1, true, not self.isShowPartsList)
    end
  end
end
function UIChrWeaponPartsPanelV3:UpdateSortContent()
  local weaponPartsList = NetCmdWeaponPartsData:GetReplaceWeaponPartsListByType(self.weaponCmdData.slotList[self.curSlotIndex - 1])
  if self.comScreenItemV2 == nil then
    self.comScreenItemV2 = ComScreenItemHelper:InitWeaponPart(self.ui.mScrollListChild_GrpScreen.gameObject, weaponPartsList, function()
      self:UpdateReplaceList()
    end, nil, self.weaponCmdData:GetWeaponPartTypeBySlotIndex(self.curSlotIndex - 1))
  else
    self.comScreenItemV2.SlotId = self.weaponCmdData:GetWeaponPartTypeBySlotIndex(self.curSlotIndex - 1)
    self.comScreenItemV2:ResetScreenData()
    self.comScreenItemV2:SetList(weaponPartsList)
  end
  self:UpdateReplaceList()
end
function UIChrWeaponPartsPanelV3:SetSlotData(partItem)
  local gunWeaponModData = partItem.gunWeaponModData
  local weaponModTypeData = partItem.weaponModTypeData
  local typeId = weaponModTypeData.id
  partItem.mText_Info.text = weaponModTypeData.Name.str
  partItem.mAnimator_Root:SetBool("Equipped", gunWeaponModData ~= nil)
  if gunWeaponModData == nil then
    partItem.mText_Name.text = TableData.GetHintById(102271)
    partItem.mImg_PartsIcon.sprite = IconUtils.GetWeaponPartIconSprite(weaponModTypeData.icon, false)
    partItem.mImg_PartsIcon1.sprite = partItem.mImg_PartsIcon.sprite
    setactive(partItem.mImg_SuitIcon.gameObject, false)
    setactive(partItem.mObj_RedPoint.transform.parent, NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, 0))
  else
    partItem.mText_Name.text = gunWeaponModData.name
    local suitData = TableData.listModPowerDatas:GetDataById(gunWeaponModData.suitId)
    partItem.mImg_PartsIcon.sprite = IconUtils.GetWeaponPartIconSprite(gunWeaponModData.icon)
    partItem.mImg_PartsIcon1.sprite = partItem.mImg_PartsIcon.sprite
    partItem.mImg_Quality.color = TableData.GetGlobalGun_Quality_Color2(gunWeaponModData.rank, partItem.mImg_Quality.color.a)
    if suitData ~= nil then
      setactive(partItem.mImg_SuitIcon.gameObject, true)
      partItem.mImg_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(suitData.image, false)
    else
      setactive(partItem.mImg_SuitIcon.gameObject, false)
    end
    setactive(partItem.mObj_RedPoint.transform.parent, NetCmdWeaponPartsData:HasHeigherNotUsedMod(typeId, gunWeaponModData.stcId))
  end
end
function UIChrWeaponPartsPanelV3:UpdateReplaceList()
  if self.comScreenItemV2 == nil then
    return
  end
  if self.curSelectPartItem ~= nil then
    self.curSelectPartItem:SetItemSelect(false)
  end
  self.weaponPartsList = self.comScreenItemV2:GetResultList()
  setactive(self.ui.mTrans_None.gameObject, self.weaponPartsList.Count <= 0)
  self.ui.mVirtualListEx_GrpWeaponPartsList.numItems = self.weaponPartsList.Count
  self.ui.mVirtualListEx_GrpWeaponPartsList:Refresh()
  self.ui.mVirtualListEx_GrpWeaponPartsList.verticalNormalizedPosition = 1
end
function UIChrWeaponPartsPanelV3:UpdateAction()
  self:UpdateLockStatue()
  if not self.isWeaponPartsReplace then
    setactive(self.ui.mBtn_BtnBreak.transform.parent.gameObject, self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.level < self.curSelectGunWeaponModData.maxLevel)
    setactive(self.ui.mTrans_Max.gameObject, self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.level == self.curSelectGunWeaponModData.maxLevel)
    setactive(self.ui.mBtn_BtnReplace.transform.parent.gameObject, false)
    setactive(self.ui.mBtn_BtnEquip.transform.parent.gameObject, false)
    setactive(self.ui.mBtn_BtnUninstall.transform.parent.gameObject, false)
    self:UpdateActionParent()
    return
  end
  local needShowReplaceBtn = self.curSelectPartItem == nil and self.curPartItem ~= nil and self.curPartItem.gunWeaponModData ~= nil or self.curSelectPartItem ~= nil and self.curPartItem ~= nil and self.curPartItem.gunWeaponModData ~= nil and self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.id ~= self.curPartItem.gunWeaponModData.id
  setactive(self.ui.mBtn_BtnReplace.transform.parent.gameObject, needShowReplaceBtn)
  setactive(self.ui.mBtn_BtnEquip.transform.parent.gameObject, self.curPartItem ~= nil and self.curPartItem.gunWeaponModData == nil and not needShowReplaceBtn and (self.curSelectPartItem ~= nil and self.curSelectPartItem.partData ~= nil or self.curSelectPartItem == nil and not self.isShowPartsList))
  setactive(self.ui.mBtn_BtnUninstall.transform.parent.gameObject, self.curPartItem ~= nil and self.curPartItem.gunWeaponModData ~= nil and self.curSelectPartItem ~= nil and self.curSelectPartItem.partData.id == self.curPartItem.gunWeaponModData.id and self.isShowPartsList or self.curSelectPartItem ~= nil and self.curPartItem ~= nil and self.curPartItem.gunWeaponModData ~= nil and self.curSelectPartItem.partData.id == self.curPartItem.gunWeaponModData.id)
  setactive(self.ui.mBtn_BtnBreak.transform.parent.gameObject, self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.level < self.curSelectGunWeaponModData.maxLevel)
  setactive(self.ui.mTrans_Max.gameObject, self.curSelectGunWeaponModData ~= nil and self.curSelectGunWeaponModData.level == self.curSelectGunWeaponModData.maxLevel)
  self:UpdateActionParent()
end
function UIChrWeaponPartsPanelV3:UpdateActionParent()
  local actionActive = self.ui.mBtn_BtnReplace.transform.parent.gameObject.activeSelf or self.ui.mBtn_BtnUninstall.transform.parent.gameObject.activeSelf or self.ui.mBtn_BtnEquip.transform.parent.gameObject.activeSelf or self.ui.mBtn_BtnBreak.transform.parent.gameObject.activeSelf
  setactive(self.ui.mTrans_Action.gameObject, actionActive)
end
function UIChrWeaponPartsPanelV3:OnClickPartSlot(partItemUI)
  if self.isShowPartsList and partItemUI ~= nil and self.curPartItem ~= nil and partItemUI.index == self.curPartItem.index then
    return
  end
  setactive(self.ui.mMonoScrollerFadeManager_Content.gameObject, false)
  setactive(self.ui.mMonoScrollerFadeManager_Content.gameObject, true)
  if self.needStopOutlineEffect or self.curSlotIndex ~= partItemUI.index then
    UIBarrackWeaponModelManager:StopOutlineEffect()
  end
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
  self.curSlotIndex = partItemUI.index
  if partItemUI ~= nil and partItemUI.gunWeaponModData ~= nil then
    self.curSelectGunWeaponModData = partItemUI.gunWeaponModData
  end
  if self.curPartItem ~= nil then
    self:SetSlotSelected(self.curPartItem, false)
  end
  self.curPartItem = partItemUI
  self:ShowPartList(true)
  self:SetSlotSelected(self.curPartItem, true)
  self.gunWeaponModData = self.curPartItem.gunWeaponModData
  if self.curSelectPartItem ~= nil then
    self.curSelectPartItem:SetItemSelect(false)
    self.curSelectPartItem = nil
  end
  self.curSelectGunWeaponModData = partItemUI.gunWeaponModData
  self.ui.mToggle_Contrast.isOn = false
  self:UpdateSortContent()
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
  UIBarrackWeaponModelManager:SetModelTransformBySlotIndex(self.curSlotIndex - 1, true, not self.isShowPartsList)
  self:ShowWeaponPartOutline()
end
function UIChrWeaponPartsPanelV3:ShowWeaponPartOutline(weaponCmdData)
  UIBarrackWeaponModelManager:OnShowWeaponPartBySlotIndex(self.curSlotIndex - 1, weaponCmdData)
  UIBarrackWeaponModelManager:StartOutlineEffect()
end
function UIChrWeaponPartsPanelV3:OnClickPart(item)
  if not self.isShowPartsList then
    return
  end
  self.curSelectGunWeaponModData = item.partData
  if self.curSelectPartItem ~= nil then
    self.curSelectPartItem:SetItemSelect(false)
  end
  self.curSelectPartItem = item
  self.curItemIndex = self.curSelectPartItem.index
  self.curSelectPartItem:SetItemSelect(true)
  local previewWeaponCmdData = self.weaponCmdData:GetPreviewPart(self.curSelectGunWeaponModData.id, self.curSlotIndex - 1)
  UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(previewWeaponCmdData)
  self:SetCurWeaponPartData()
  self:ShowWeaponPartOutline(previewWeaponCmdData)
  self:UpdateLockStatue()
end
function UIChrWeaponPartsPanelV3:OnBackClick()
  if self.isShowPartsList then
    self:ResetItemState(false)
    if not UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
      UIBarrackWeaponModelManager:GetBarrckWeaponModelByData(self.weaponCmdData)
    end
    self:SetCurWeaponPartData()
    self:ShowPartList(false)
  else
    if self.isWeaponPartsReplace then
      UIBarrackWeaponModelManager:ResetRootTransformValue()
      UIBarrackWeaponModelManager:StopOutlineEffect()
    end
    UIManager.CloseUI(UIDef.UIChrWeaponPartsPanelV3)
  end
end
function UIChrWeaponPartsPanelV3:ResetItemState(needReleaseCurPartItem)
  if needReleaseCurPartItem == nil then
    needReleaseCurPartItem = true
  end
  self.needResetCameraPosToBase = false
  if self.curSelectPartItem ~= nil then
    self.curSelectPartItem:SetItemSelect(false)
  end
  self.curSelectPartItem = nil
  self.curSelectGunWeaponModData = nil
  setactive(self.ui.mTrans_WeaponPartsInfo.gameObject, false)
  setactive(self.ui.mTrans_Empty.gameObject, true)
  setactive(self.ui.mBtn_BtnEquip.transform.parent.gameObject, true)
  if self.curPartItem ~= nil and needReleaseCurPartItem then
    self:SetSlotSelected(self.curPartItem, false)
    self.curPartItem = nil
  else
  end
  self.ui.mToggle_Contrast.isOn = false
end
function UIChrWeaponPartsPanelV3:OnReplaceClick()
  local partListObj = self.ui.mTrans_PartsList.gameObject
  if not self.isShowPartsList then
    self:ShowPartList(true)
    return
  end
  if self.curSelectGunWeaponModData.equipWeapon > 0 then
    local weaponData = NetCmdWeaponData:GetWeaponById(self.curSelectGunWeaponModData.equipWeapon)
    local weaponName = weaponData.Name
    local rankColor = TableDataBase.GlobalConfigData.GunQualityColor2[weaponData.Rank - 1]
    local colorName = string_format("<color=#{0}>{1}</color>", rankColor, weaponName)
    MessageBoxPanel.ShowDoubleType(string_format(TableData.GetHintById(102216), colorName), function()
      self:ReplaceWeaponPart()
    end)
  else
    self:ReplaceWeaponPart()
  end
end
function UIChrWeaponPartsPanelV3:ReplaceWeaponPart()
  if self.curSelectGunWeaponModData ~= nil then
    local index = self.curSlotIndex
    local onReplaceWeaponPart = function()
      NetCmdWeaponPartsData:ReqWeaponPartBelong(self.curSelectGunWeaponModData.id, self.weaponCmdData.id, index, function(ret)
        if ret == ErrorCodeSuc then
          self.gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(self.curSelectGunWeaponModData.id)
          self.weaponCmdData = NetCmdWeaponData:GetWeaponById(self.weaponCmdData.id)
          self:SetWeaponPartData()
          self.curSelectGunWeaponModData = nil
          UIUtils.PopupPositiveHintMessage(102242)
        end
      end)
    end
    local equipWeapon = self.curSelectGunWeaponModData.equipWeapon
    if 0 < equipWeapon then
      local weaponData = NetCmdWeaponData:GetWeaponById(equipWeapon)
      local weaponName = weaponData.Name
      local rankColor = TableDataBase.GlobalConfigData.GunQualityColor2[weaponData.Rank - 1]
      local colorName = string_format("<color=#{0}>{1}</color>", rankColor, weaponName)
      MessageBoxPanel.ShowDoubleType(string_format(TableData.GetHintById(102216), colorName), function()
        onReplaceWeaponPart()
      end)
    else
      onReplaceWeaponPart()
    end
  end
end
function UIChrWeaponPartsPanelV3:OnBreakClick()
  local gunWeaponModData
  if self.curSelectPartItem ~= nil then
    gunWeaponModData = self.curSelectPartItem.partData
  elseif self.curPartItem ~= nil then
    gunWeaponModData = self.curPartItem.gunWeaponModData
  else
    gunWeaponModData = self.curSelectGunWeaponModData
  end
  if gunWeaponModData.level >= gunWeaponModData.maxLevel then
    UIUtils.PopupHintMessage(30020)
    return
  end
  local param = {gunWeaponModData = gunWeaponModData, needResetCameraPosToBase = false}
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPartsPowerUpPanelV3, param)
end
function UIChrWeaponPartsPanelV3:OnClickLock(isOn)
  if isOn == self.curSelectGunWeaponModData.IsLocked then
    return
  end
  NetCmdWeaponPartsData:ReqWeaponPartLockUnlock(self.curSelectGunWeaponModData.id, function(ret)
    if ret == ErrorCodeSuc then
      if self.curSelectPartItem ~= nil and self.isShowPartsList then
        self.ui.mVirtualListEx_GrpWeaponPartsList:RefreshItem(self.curSelectPartItem.index)
      end
      self:UpdateLockStatue()
    end
  end)
end
function UIChrWeaponPartsPanelV3:UpdateLockStatue()
  if self.curSelectGunWeaponModData ~= nil and self.lockItem ~= nil then
    self.lockItem:SetLock(self.curSelectGunWeaponModData.IsLocked)
  end
end
function UIChrWeaponPartsPanelV3:OnUninstallClick()
  if self.curSelectGunWeaponModData ~= nil then
    local index = self.curSlotIndex
    local uninstallClick = function()
      NetCmdWeaponPartsData:ReqWeaponPartBelong(0, self.weaponCmdData.id, index, function(ret)
        if ret == ErrorCodeSuc then
          self.gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(self.curSelectGunWeaponModData.id)
          self.weaponCmdData = NetCmdWeaponData:GetWeaponById(self.weaponCmdData.id)
          self:SetWeaponPartData()
          self.curSelectGunWeaponModData = nil
        end
      end)
    end
    uninstallClick()
  end
end
function UIChrWeaponPartsPanelV3:OnEquipClick()
  local partListObj = self.ui.mTrans_PartsList.gameObject
  if self.isShowPartsList then
    self:ReplaceWeaponPart()
  else
    self:ShowPartList(true)
    setactive(self.ui.mBtn_BtnEquip.transform.parent.gameObject, false)
  end
end
function UIChrWeaponPartsPanelV3:ShowPartList(active)
  if active == nil then
    active = false
  end
  self.ui.mAnimator_Left:SetBool("List", active)
  local needUpdateAction = self.isShowPartsList ~= active
  self.isShowPartsList = active
  for i, partItem in ipairs(self.weaponPartUis) do
    partItem.mAnimator_Root:SetBool("Text", not active)
  end
  if active then
    self:UpdateSortContent()
    self:ScrollToCurItem()
  else
    if self.curSelectPartItem ~= nil then
      self.curSelectPartItem:SetItemSelect(false)
    end
    self.curSelectPartItem = nil
    UIBarrackWeaponModelManager:SetModelTransformBySlotIndex(self.curSlotIndex - 1, true, true)
    self.needStopOutlineEffect = true
    UIBarrackWeaponModelManager:StopOutlineEffect()
  end
  if needUpdateAction then
    self:UpdateAction()
  end
end
function UIChrWeaponPartsPanelV3:ScrollToCurItem()
  if self.curPartItem ~= nil and self.curPartItem.gunWeaponModData ~= nil then
  else
    return
  end
  for i = 0, self.weaponPartsList.Count - 1 do
    local itemData = self.weaponPartsList[i]
    if self.curPartItem.gunWeaponModData.id == itemData.id then
      self.ui.mVirtualListEx_GrpWeaponPartsList:DelayScrollToPosByIndex(i)
    end
  end
end
function UIChrWeaponPartsPanelV3:SetSlotSelected(partItemUI, enabled)
  setactive(partItemUI.mTrans_ImgSel.gameObject, enabled)
end
