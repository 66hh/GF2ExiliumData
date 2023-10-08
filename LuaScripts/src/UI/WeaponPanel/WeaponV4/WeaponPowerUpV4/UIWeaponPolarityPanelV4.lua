UIWeaponPolarityPanelV4 = class("UIWeaponPolarityPanelV4", UIBasePanel)
UIWeaponPolarityPanelV4.__index = UIWeaponPolarityPanelV4
function UIWeaponPolarityPanelV4:ctor(root, uiChrWeaponPowerUpPanelV4)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.weaponCmdData = nil
  self.isWeaponEnough = false
  self.chrPolarityItemList = {}
  self.curSelectChrPolarityItem = nil
  self.curSelectSlotIndex = 0
end
function UIWeaponPolarityPanelV4:OnAwake(root, data)
  self:SetRoot(root)
end
function UIWeaponPolarityPanelV4:OnInit(data)
  self.weaponCmdData = data
  self.MaxWeaponBreakTimes = self.weaponCmdData.StcData.MaxBreak
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCustom.gameObject).onClick = function()
    self:OnClickCom(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCom.gameObject).onClick = function()
    self:OnClickCom(true)
  end
  local customContainner = self.ui.mBtn_BtnCustom.transform:Find("Root/Trans_RedPoint").gameObject:GetComponent(typeof(CS.UICommonContainer))
  self.customRedpoint = customContainner.transform
  local comContainner = self.ui.mBtn_BtnCom.transform:Find("Root/Trans_RedPoint").gameObject:GetComponent(typeof(CS.UICommonContainer))
  self.comRedpoint = comContainner.transform
end
function UIWeaponPolarityPanelV4:OnShowStart()
  self:SetWeaponData()
end
function UIWeaponPolarityPanelV4:OnRecover()
end
function UIWeaponPolarityPanelV4:OnBackFrom()
  local index = UIWeaponGlobal.GetPolarityIndex()
  if index == 0 then
    return
  end
  self:RefreshPolarityFx()
  self:SetWeaponData()
end
function UIWeaponPolarityPanelV4:OnTop()
  self:SetWeaponData()
  local index = UIWeaponGlobal.GetPolarityIndex()
  if index == 0 then
    return
  end
  self:RefreshPolarityFx()
end
function UIWeaponPolarityPanelV4:OnShowFinish()
end
function UIWeaponPolarityPanelV4:OnCameraStart()
  return 0.01
end
function UIWeaponPolarityPanelV4:OnCameraBack()
end
function UIWeaponPolarityPanelV4:OnHide()
  if self.bgObjAnimator ~= nil then
    self.bgObjAnimator:SetTrigger("FadeOut")
  end
end
function UIWeaponPolarityPanelV4:OnHideFinish()
end
function UIWeaponPolarityPanelV4:OnClose()
  self.curSelectChrPolarityItem = nil
  for i = 1, #self.chrPolarityItemList do
    local chrPolarityItem = self.chrPolarityItemList[i]
    chrPolarityItem:TimerAbort()
  end
  self.chrPolarityItemList = nil
end
function UIWeaponPolarityPanelV4:OnRelease()
  self.super.OnRelease(self)
end
function UIWeaponPolarityPanelV4:InitWeaponParts()
  local slotList = self.weaponCmdData.slotList
  for i = 1, UIWeaponGlobal.WeaponMaxSlot do
    setactive(self.ui["mScrollListChild_GrpParts" .. i].gameObject, false)
  end
  self.chrPolarityItemList = {}
  for i = 1, slotList.Count do
    if i <= UIWeaponGlobal.WeaponMaxSlot then
      local partObj = self.ui["mScrollListChild_GrpParts" .. i].gameObject
      setactive(partObj, true)
      local item = ChrPolarityItem.New()
      local obj
      if partObj.transform.childCount > 0 then
        obj = partObj.transform:GetChild(0).gameObject
      end
      local weaponPartType = self.weaponCmdData:GetWeaponPartTypeBySlotIndex(i - 1)
      item:InitCtrl(partObj, weaponPartType, obj)
      item:SetBtnEnabled(true)
      table.insert(self.chrPolarityItemList, item)
    end
  end
end
function UIWeaponPolarityPanelV4:SetWeaponData()
  self:CheckSelectPolarization()
  self:UpdateWeaponParts()
  self:UpdateRedpoint()
end
function UIWeaponPolarityPanelV4:UpdateWeaponParts()
  self:UpdateCapacity()
  if self.chrPolarityItemList == nil or #self.chrPolarityItemList == 0 then
    self:InitWeaponParts()
  end
  for i = 1, #self.chrPolarityItemList do
    local chrPolarityItem = self.chrPolarityItemList[i]
    chrPolarityItem:SetBtnInteractable(true)
    local weaponPart = self.weaponCmdData:GetWeaponPartByType(i - 1)
    local polarityTagData = self.weaponCmdData:GetPolarityTagDataByIndex(i - 1)
    chrPolarityItem:SetWeaponPartData(polarityTagData, weaponPart)
    chrPolarityItem:OnButtonClick(function()
      self:OnClickPolarityItem(i)
    end)
  end
  if self.curSelectChrPolarityItem == nil then
    self:OnClickPolarityItem(1)
  else
    self:OnClickPolarityItem(self.curSelectSlotIndex)
  end
end
function UIWeaponPolarityPanelV4:UpdateCapacity()
  if self.weaponCmdData.Capacity == 0 then
    setactive(self.ui.mTrans_PartsVolume.gameObject, false)
    return
  end
  setactive(self.ui.mTrans_PartsVolume.gameObject, true)
  self.ui.mText_Num.text = self.weaponCmdData:GetAllWeaponModCapacity() .. "/" .. self.weaponCmdData.Capacity
end
function UIWeaponPolarityPanelV4:RefreshPolarityFx()
  local index = UIWeaponGlobal.GetPolarityIndex()
  if index == 0 then
    return
  end
  self.chrPolarityItemList[index]:ShowPolarityFx()
  UIWeaponGlobal.SetPolarityIndex(0)
end
function UIWeaponPolarityPanelV4:UpdateRedpoint()
  local redPoint = self.weaponCmdData:GetWeaponPolarityRedPoint()
  local random = self.weaponCmdData:CheckCost(self.weaponCmdData.StcData.polarity_cost_random)
  local custom = self.weaponCmdData:CheckCost(self.weaponCmdData.StcData.polarity_cost_custom)
  setactive(self.comRedpoint.gameObject, random and 0 < redPoint)
  setactive(self.customRedpoint.gameObject, custom and 0 < redPoint)
end
function UIWeaponPolarityPanelV4:SwitchGun(gunCmdData, isShow)
  self.weaponCmdData = gunCmdData.WeaponData
  self:SetWeaponData()
end
function UIWeaponPolarityPanelV4:OnClickPolarityItem(index)
  if self.curSelectChrPolarityItem ~= nil then
    self.curSelectChrPolarityItem:SetBtnInteractable(true)
  end
  self.curSelectSlotIndex = index
  self.curSelectChrPolarityItem = self.chrPolarityItemList[index]
  self.curSelectChrPolarityItem:SetBtnInteractable(false)
end
function UIWeaponPolarityPanelV4:OnClickCom(isRandom)
  local hint
  if isRandom then
    hint = 220047
  else
    hint = 220046
  end
  local gunWeaponModData = self.curSelectChrPolarityItem.gunWeaponModData
  local polarityTagData = self.curSelectChrPolarityItem.polarityTagData
  local weaponPartType = self.weaponCmdData:GetWeaponPartTypeBySlotIndex(self.curSelectSlotIndex - 1)
  local weaponModTypeData = TableData.listWeaponModTypeDatas:GetDataById(weaponPartType)
  local title = TableData.GetHintById(hint)
  local param = {
    title = title,
    weaponCmdData = self.weaponCmdData,
    slotIndex = self.curSelectSlotIndex,
    isRandom = isRandom,
    gunWeaponModData = gunWeaponModData,
    polarityTagData = polarityTagData,
    weaponModTypeData = weaponModTypeData
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponCustomPolarityDialog, param)
end
function UIWeaponPolarityPanelV4:CheckSelectPolarization()
  if self.weaponCmdData.SelectPolarization == nil then
    return
  end
  local param = {
    weaponCmdData = self.weaponCmdData,
    selectPolarization = self.weaponCmdData.SelectPolarization
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPolarityDoubleCheckDialog, param)
end
