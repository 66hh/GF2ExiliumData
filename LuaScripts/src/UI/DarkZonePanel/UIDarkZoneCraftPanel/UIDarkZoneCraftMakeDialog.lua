require("UI.DarkZonePanel.UIDarkZoneCraftPanel.UIDarkZoneCraftMakeDialogView")
require("UI.UIBasePanel")
UIDarkZoneCraftMakeDialog = class("UIDarkZoneCraftMakeDialog", UIBasePanel)
UIDarkZoneCraftMakeDialog.__index = UIDarkZoneCraftMakeDialog
function UIDarkZoneCraftMakeDialog:ctor(csPanel)
  UIDarkZoneCraftMakeDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneCraftMakeDialog:OnInit(root, data)
  UIDarkZoneCraftMakeDialog.super.SetRoot(UIDarkZoneCraftMakeDialog, root)
  self:InitBaseData()
  self.mData = data
  self.mView:InitCtrl(root, self.ui)
end
function UIDarkZoneCraftMakeDialog:OnShowFinish()
  self.ui.mBtn_Close.interactable = false
  self:DelayCall(4, function()
    self:CloseFunction()
  end)
end
function UIDarkZoneCraftMakeDialog:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneCraftMakeDialog)
  UIManager.OpenUI(UIDef.UICommonReceivePanel)
end
function UIDarkZoneCraftMakeDialog:OnClose()
  self.ui = nil
  self.mView = nil
  self:ReleaseTimers()
end
function UIDarkZoneCraftMakeDialog:InitBaseData()
  self.mView = UIDarkZoneCraftMakeDialogView.New()
  self.ui = {}
end
function UIDarkZoneCraftMakeDialog:AddBtnListener()
  self.ui.mBtn_Close.onClick:AddListener(function()
    self:CloseFunction()
  end)
end
