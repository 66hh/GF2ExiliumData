require("UI.UAVPanel.UIUAVUnlockPartsDialogView")
require("UI.UIBasePanel")
UIUAVUnlockPartsDialog = class("UIUAVUnlockPartsDialog", UIBasePanel)
UIUAVUnlockPartsDialog.__index = UIUAVUnlockPartsDialog
function UIUAVUnlockPartsDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIUAVUnlockPartsDialog:OnAwake(root, data)
  self:SetRoot(root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
end
function UIUAVUnlockPartsDialog:OnInit(root, data)
end
function UIUAVUnlockPartsDialog:OnShowStart()
  self.IsPanelOpen = true
end
function UIUAVUnlockPartsDialog:OnHide()
  self.IsPanelOpen = false
end
function UIUAVUnlockPartsDialog:OnClickClose()
  UIManager.CloseUI(UIDef.UIUAVUnlockPartsDialog)
end
function UIUAVUnlockPartsDialog:OnRelease()
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
end
function UIUAVUnlockPartsDialog:InitBaseData()
  self.mview = UIUAVUnlockPartsDialogView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
end
function UIUAVUnlockPartsDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
end
