require("UI.WeaponPanel.WeaponV4.Item.ChrWeaponPartsBlankBoardItem")
UIChrWeaponPolarityFirstGetDialog = class("UIChrWeaponPolarityFirstGetDialog", UIBasePanel)
UIChrWeaponPolarityFirstGetDialog.__index = UIChrWeaponPolarityFirstGetDialog
function UIChrWeaponPolarityFirstGetDialog:ctor(csPanel)
  UIChrWeaponPolarityFirstGetDialog.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  csPanel.Type = UIBasePanelType.Dialog
  self.param = {modType = 0, polarityId = 0}
  self.weaponModTypeData = nil
  self.polarityTagData = nil
  self.fadeTimer = nil
end
function UIChrWeaponPolarityFirstGetDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrWeaponPolarityFirstGetDialog:OnInit(root, param)
  self.param = param
  self.weaponModTypeData = TableData.listWeaponModTypeDatas:GetDataById(self.param.modType)
  self.polarityTagData = TableData.listPolarityTagDatas:GetDataById(self.param.polarityId)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = nil
  local tmpTime = CSUIUtils.GetClipLengthByEndsWith(self.ui.mAnimator_Root, "FadeIn")
  if self.fadeTimer ~= nil then
    self.fadeTimer:Stop()
  end
  self.fadeTimer = TimerSys:DelayCall(tmpTime, function()
    self:InitBtn()
    self.fadeTimer = nil
  end)
  self:UpdatePolarity()
end
function UIChrWeaponPolarityFirstGetDialog:OnShowFinish()
end
function UIChrWeaponPolarityFirstGetDialog:InitBtn()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIWeaponGlobal.SetIsReadyToStartTutorial(true)
    UIManager.CloseUI(UIDef.UIChrWeaponPolarityFirstGetDialog)
  end
end
function UIChrWeaponPolarityFirstGetDialog:OnClose()
  UIUtils.PopupPositiveHintMessage(220030)
  UIWeaponGlobal.SetPolarityIndex(self.param.slotIndex)
end
function UIChrWeaponPolarityFirstGetDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPolarityFirstGetDialog:UpdatePolarity()
  local parent = self.ui.mScrollListChild_GrpItem
  local item = ChrWeaponPartsBlankBoardItem.New()
  local obj
  if parent.transform.childCount > 0 then
    obj = parent.transform:GetChild(0).gameObject
  end
  item:InitCtrl(parent, obj)
  item:SetWeaponPartData(self.polarityTagData, self.weaponModTypeData)
end
