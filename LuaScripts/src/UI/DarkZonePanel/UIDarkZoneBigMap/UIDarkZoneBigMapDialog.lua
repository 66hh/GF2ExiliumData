require("UI.DarkZonePanel.UIDarkZoneBigMap.UIDarkZoneBigMapPanel")
require("UI.DarkZonePanel.UIDarkZoneBigMap.UIDarkZoneBigMapView")
require("UI.UIBasePanel")
UIDarkZoneBigMapDialog = class("UIDarkZoneBigMapDialog", UIBasePanel)
UIDarkZoneBigMapDialog.__index = UIDarkZoneBigMapDialog
function UIDarkZoneBigMapDialog:ctor(csPanel)
  UIDarkZoneBigMapDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneBigMapDialog:OnInit(root, data)
  UIDarkZoneBigMapDialog.super.SetRoot(UIDarkZoneBigMapDialog, root)
  self:InitBaseData()
  self.mView:InitCtrl(root, self.ui)
  self.bigMapPanel = UIDarkZoneBigMapPanel.New()
  self.bigMapPanel:InitCtrl(self.ui.mTrans_BigMap)
  self.bigMapPanel:SetMapCloseBtnActive(true)
  self:AddBtnListen()
end
function UIDarkZoneBigMapDialog:OnClose()
  self:UnRegistrationKeyboard(KeyCode.X)
  self.ui = nil
  self.mView = nil
  self.bigMapPanel:CloseFunction()
  self.bigMapPanel = nil
end
function UIDarkZoneBigMapDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIDarkZoneBigMapDialog:InitBaseData()
  self.mView = UIDarkZoneBigMapView.New()
  self.ui = {}
end
function UIDarkZoneBigMapDialog:AddBtnListen()
  self.bigMapPanel:SetData(function()
    UIManager.CloseUI(UIDef.UIDarkZoneBigMapDialog)
  end)
  self:RegistrationKeyboard(KeyCode.X, self.bigMapPanel.ui.mBtn_Location)
end
