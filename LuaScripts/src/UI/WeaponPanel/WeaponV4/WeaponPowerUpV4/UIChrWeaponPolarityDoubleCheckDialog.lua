require("UI.WeaponPanel.WeaponV4.Item.ChrWeaponPartsBlankBoardItem")
require("UI.Common.UICommonItem")
UIChrWeaponPolarityDoubleCheckDialog = class("UIChrWeaponPolarityDoubleCheckDialog", UIBasePanel)
UIChrWeaponPolarityDoubleCheckDialog.__index = UIChrWeaponPolarityDoubleCheckDialog
function UIChrWeaponPolarityDoubleCheckDialog:ctor(csPanel)
  UIChrWeaponPolarityDoubleCheckDialog.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  csPanel.Type = UIBasePanelType.Dialog
  self.weaponModTypeData = nil
  self.polarityTagDataBefore = nil
  self.polarityTagDataAfter = nil
  self.gunWeaponModData = nil
  self.weaponPartItem = nil
  self.nextGunWeaponModData = nil
  self.nextWeaponPartItem = nil
  self.isUseNew = false
  self.isOverflow = false
  self.param = {selectPolarization = nil, weaponCmdData = nil}
end
function UIChrWeaponPolarityDoubleCheckDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrWeaponPolarityDoubleCheckDialog:OnInit(root, param)
  self.param = param
  local slot = self.param.selectPolarization.Slot - 1
  self.slot = slot
  local modType = self.param.weaponCmdData:GetWeaponPartTypeBySlotIndex(slot)
  self.weaponModTypeData = TableData.listWeaponModTypeDatas:GetDataById(modType)
  self.polarityTagDataBefore = TableData.listPolarityTagDatas:GetDataById(self.param.weaponCmdData.Polarization[slot])
  self.polarityTagDataAfter = TableData.listPolarityTagDatas:GetDataById(self.param.selectPolarization.Polarization)
  self.gunWeaponModData = self.param.weaponCmdData:GetWeaponPartByType(slot)
  self:UpdatePolarity()
end
function UIChrWeaponPolarityDoubleCheckDialog:OnShowFinish()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickConfirm(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.gameObject).onClick = function()
    self:OnClickConfirm(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnConfirm.gameObject).onClick = function()
    self:OnClickConfirm(true)
  end
end
function UIChrWeaponPolarityDoubleCheckDialog:OnClose()
  if self.isUseNew then
    UIUtils.PopupPositiveHintMessage(220037)
    UIWeaponGlobal.SetPolarityIndex(self.param.selectPolarization.Slot)
  else
  end
  if self.weaponPartItem ~= nil then
    self.weaponPartItem:OnRelease(true)
    self.weaponPartItem = nil
  end
  if self.nextWeaponPartItem ~= nil then
    self.nextWeaponPartItem:OnRelease(true)
    self.nextWeaponPartItem = nil
  end
end
function UIChrWeaponPolarityDoubleCheckDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPolarityDoubleCheckDialog:UpdatePolarity()
  local beforeItem
  if self.ui.mScrollListChild_GrpBeforeItem.transform.childCount > 0 then
    beforeItem = self.ui.mScrollListChild_GrpBeforeItem.transform:GetChild(0).gameObject
  end
  self:SetPolarityBoardItem(self.ui.mScrollListChild_GrpBeforeItem, self.polarityTagDataBefore, self.weaponModTypeData, beforeItem, false)
  local afterItem
  if self.ui.mScrollListChild_GrpAfterItem.transform.childCount > 1 then
    afterItem = self.ui.mScrollListChild_GrpAfterItem.transform:GetChild(1).gameObject
  end
  self:SetPolarityBoardItem(self.ui.mScrollListChild_GrpAfterItem, self.polarityTagDataAfter, self.weaponModTypeData, afterItem)
  self:CheckOverflow()
end
function UIChrWeaponPolarityDoubleCheckDialog:SetPolarityBoardItem(parent, polarityTagData, weaponModTypeData, obj, needEffect)
  local item = ChrWeaponPartsBlankBoardItem.New()
  item:InitCtrl(parent, obj)
  item:SetWeaponPartData(polarityTagData, weaponModTypeData, needEffect)
end
function UIChrWeaponPolarityDoubleCheckDialog:CheckOverflow()
  self.isOverflow = self.param.weaponCmdData:CheckCapacityOverflow()
  setactive(self.ui.mTrans_NowEquiped.gameObject, self.isOverflow)
  setactive(self.ui.mTrans_ImgLine.gameObject, self.isOverflow)
  setactive(self.ui.mTrans_TextTip.gameObject, self.isOverflow)
  if self.isOverflow then
    self.weaponPartItem = UICommonItem.New()
    self.weaponPartItem:InitCtrl(self.ui.mScrollListChild_GrpItem)
    self.weaponPartItem:SetPartData(self.gunWeaponModData)
    setactive(self.weaponPartItem.ui.mTrans_Equipped_InGun, false)
    setactive(self.weaponPartItem.ui.mImage_Head, false)
    setactive(self.weaponPartItem.ui.mTrans_Equipped_InWeapon, false)
    self.nextGunWeaponModData = self.param.weaponCmdData:GetNextOverflowWeaponPart(self.slot)
  end
  setactive(self.ui.mTrans_MaxCost.gameObject, self.nextGunWeaponModData ~= nil)
  if self.nextGunWeaponModData ~= nil then
    self.nextWeaponPartItem = UICommonItem.New()
    self.nextWeaponPartItem:InitCtrl(self.ui.mScrollListChild_Item)
    self.nextWeaponPartItem:SetPartData(self.nextGunWeaponModData)
    setactive(self.nextWeaponPartItem.ui.mTrans_Equipped_InGun, false)
    setactive(self.nextWeaponPartItem.ui.mImage_Head, false)
    setactive(self.nextWeaponPartItem.ui.mTrans_Equipped_InWeapon, false)
  end
end
function UIChrWeaponPolarityDoubleCheckDialog:OnClickConfirm(isUseNew)
  self.isUseNew = isUseNew
  NetCmdWeaponData:SendWeaponSelectPolarization(self.param.weaponCmdData.id, self.param.selectPolarization.Slot, isUseNew, function(ret)
    self:SetInputActive(true)
    if ret == ErrorCodeSuc and self.param.weaponCmdData.SelectPolarization ~= nil then
      self.param.weaponCmdData.SelectPolarization = nil
    end
  end)
  UIWeaponGlobal.SetIsReadyToStartTutorial(true)
  UIManager.CloseUI(UIDef.UIChrWeaponPolarityDoubleCheckDialog)
end
