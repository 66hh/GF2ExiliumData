require("UI.DarkZonePanel.UIDarkZoneMessageDialog.UIDarkZoneMessageDialogView")
require("UI.UIBasePanel")
UIDarkZoneMessageDialog = class("UIDarkZoneMessageDialog", UIBasePanel)
UIDarkZoneMessageDialog.__index = UIDarkZoneMessageDialog
function UIDarkZoneMessageDialog:ctor(csPanel)
  UIDarkZoneMessageDialog.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneMessageDialog:OnInit(root, data)
  UIDarkZoneMessageDialog.super.SetRoot(UIDarkZoneMessageDialog, root)
  self:InitBaseData()
  self.mData = data
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  self:SetData()
end
function UIDarkZoneMessageDialog:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneMessageDialog)
end
function UIDarkZoneMessageDialog:OnClose()
  self.ui = nil
  self.mview = nil
end
function UIDarkZoneMessageDialog:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneMessageDialog:InitBaseData()
  self.mview = UIDarkZoneMessageDialogView.New()
  self.ui = {}
end
function UIDarkZoneMessageDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCancel.gameObject).onClick = function()
    if self.CancleCallBack ~= nil then
      self.CancleCallBack()
    end
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if self.ConfirmCallBack ~= nil then
      self.ConfirmCallBack()
    end
    self:CloseFunction()
  end
  self.Text_Cancle = self.ui.mBtn_BtnCancel.gameObject.transform:Find("Root/GrpText/Text_Name"):GetComponent("Text")
  self.Text_Confirm = self.ui.mBtn_Confirm.gameObject.transform:Find("Root/GrpText/Text_Name"):GetComponent("Text")
end
function UIDarkZoneMessageDialog:SetData()
  setactive(self.ui.mBtn_Confirm.gameObject.transform.parent, false)
  setactive(self.ui.mBtn_BtnCancel.gameObject.transform.parent, false)
  self.CancleCallBack = self.mData.CancleCallBack
  self.ConfirmCallBack = self.mData.ConfirmCallBack
  self.GotoCallBack = self.mData.GotoCallBack
  self.CancleText = self.mData.CancleText
  self.ConfirmText = self.mData.ConfirmText
  self.Content = self.mData.Content
  self.Title = self.mData.Title
  if self.CancleText ~= nil then
    setactive(self.ui.mBtn_BtnCancel.gameObject.transform.parent, true)
    self.Text_Cancle.text = self.CancleText
  end
  if self.ConfirmText ~= nil then
    setactive(self.ui.mBtn_Confirm.gameObject.transform.parent, true)
    self.Text_Confirm.text = self.ConfirmText
  end
  if self.Content ~= nil then
    self.ui.mText_Content.text = self.Content
  end
  if self.Title ~= nil then
    self.ui.mText_Title.text = self.Title
  end
end
