require("UI.SimCombatPanel.UISimCombatDutyOpenDateDialogView")
UISimCombatDutyOpenDateDialog = class("UISimCombatDutyOpenDateDialog", UIBasePanel)
local self = UISimCombatDutyOpenDateDialog
function UISimCombatDutyOpenDateDialog:ctor(csPanel)
  UISimCombatDutyOpenDateDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UISimCombatDutyOpenDateDialog:OnInit(root, data)
  self:SetRoot(root)
  self:InitBaseData()
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
end
function UISimCombatDutyOpenDateDialog:OnShowStart()
  self = UISimCombatDutyOpenDateDialog
  self.IsPanelOpen = true
end
function UISimCombatDutyOpenDateDialog:OnHide()
  self = UISimCombatDutyOpenDateDialog
  self.IsPanelOpen = false
end
function UISimCombatDutyOpenDateDialog:OnCloseUISimCombatDutyOpenDateDialog()
  UIManager.CloseUI(UIDef.UISimCombatDutyOpenDateDialog)
end
function UISimCombatDutyOpenDateDialog:OnRelease()
  self.ui = nil
  self.mview = nil
  self.IsPanelOpen = nil
end
function UISimCombatDutyOpenDateDialog:InitBaseData()
  self.mview = UISimCombatDutyOpenDateDialogView.New()
  self.ui = {}
  self.IsPanelOpen = false
end
function UISimCombatDutyOpenDateDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_CloseBg.gameObject).onClick = function()
    self:OnCloseUISimCombatDutyOpenDateDialog()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnCloseUISimCombatDutyOpenDateDialog()
  end
end
