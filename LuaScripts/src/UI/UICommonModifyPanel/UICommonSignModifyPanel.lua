require("UI.UICommonModifyPanel.UICommonSignModifyPanelView")
require("UI.UIBasePanel")
UICommonSignModifyPanel = class("UICommonSignModifyPanel", UIBasePanel)
UICommonSignModifyPanel.__index = UICommonSignModifyPanel
UICommonSignModifyPanel.confirmCallback = nil
UICommonSignModifyPanel.maxLength = 0
function UICommonSignModifyPanel:ctor(csPanel)
  UICommonSignModifyPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonSignModifyPanel.Close()
  self = UICommonSignModifyPanel
  UIManager.CloseUI(UIDef.UICommonSignModifyPanel)
end
function UICommonSignModifyPanel:OnRelease()
  self = UICommonSignModifyPanel
end
function UICommonSignModifyPanel:OnInit(root, data)
  self = UICommonSignModifyPanel
  UICommonSignModifyPanel.super.SetRoot(UICommonSignModifyPanel, root)
  UICommonSignModifyPanel.mView = UICommonSignModifyPanelView.New()
  UICommonSignModifyPanel.mView:InitCtrl(root)
  self.confirmCallback = data[1]
  self.defaultStr = data[2]
  self.maxLength = TableData.GlobalSystemData.MottoLimit
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    UICommonSignModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_CloseBg.gameObject).onClick = function()
    UICommonSignModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Cancel.gameObject).onClick = function()
    UICommonSignModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Confirm.gameObject).onClick = function()
    UICommonSignModifyPanel:OnConfirmName()
  end
  setactive(self.mView.mTrans_TextLimit, false)
  self.mView.mText_InputField.text = self.defaultStr
  self.mView.mText_InputField.characterLimit = self.maxLength
  self.mView.mText_InputField.onValueChanged:AddListener(function()
    UICommonSignModifyPanel:OnValueChange()
  end)
  UICommonSignModifyPanel:OnValueChange()
end
function UICommonSignModifyPanel:OnConfirmName()
  local strName = self.mView.mText_InputField.text
  if strName ~= "" then
  end
  if self.confirmCallback ~= nil then
    self.confirmCallback(strName)
  end
end
function UICommonSignModifyPanel:OnValueChange()
  local str = self.mView.mText_InputField.text
  self.mView.mText_Num.text = utf8.len(str)
  self.mView.mText_AllNum.text = "/" .. self.maxLength
  setactive(self.mView.mTrans_TextLimit, 0 < #str)
end
