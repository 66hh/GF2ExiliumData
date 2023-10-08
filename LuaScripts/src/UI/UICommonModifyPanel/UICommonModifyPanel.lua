require("UI.UIBasePanel")
require("UI.UICommonModifyPanel.UICommonModifyPanelView")
UICommonModifyPanel = class("UICommonModifyPanel", UIBasePanel)
UICommonModifyPanel.__index = UICommonModifyPanel
UICommonModifyPanel.confirmCallback = nil
function UICommonModifyPanel:ctor(csPanel)
  UICommonModifyPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICommonModifyPanel.Close()
  self = UICommonModifyPanel
  UIManager.CloseUI(UIDef.UICommonModifyPanel)
end
function UICommonModifyPanel:OnRelease()
  self = UICommonModifyPanel
  UICommonModifyPanel.confirmCallback = nil
  UICommonModifyPanel.checkCallback = nil
  UICommonModifyPanel.defaultStr = ""
end
function UICommonModifyPanel:OnInit(root, data)
  self = UICommonModifyPanel
  self.confirmCallback = data[1]
  self.defaultStr = data[2]
  self.checkCallback = data[3]
  UICommonModifyPanel.super.SetRoot(UICommonModifyPanel, root)
  UICommonModifyPanel.mView = UICommonModifyPanelView.New()
  UICommonModifyPanel.mView:InitCtrl(root)
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function()
    UICommonModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_CloseBg.gameObject).onClick = function()
    UICommonModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Cancel.gameObject).onClick = function()
    UICommonModifyPanel.Close()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_Confirm.gameObject).onClick = function()
    UICommonModifyPanel:OnConfirmName()
  end
  setactive(self.mView.mTrans_TextLimit, false)
  self.mView.mText_InputField.text = self.defaultStr
  self.mView.mText_Placeholder.text = self.defaultStr
  self.mView.mText_InputField.onValueChanged:AddListener(function()
    UICommonModifyPanel:OnValueChange()
  end)
  self:OnValueChange()
end
function UICommonModifyPanel:OnConfirmName()
  local strName = self.mView.mText_InputField.text
  if self.checkCallback and not self.checkCallback() then
    return
  end
  if strName ~= "" and not UIUtils.CheckInputIsLegal(strName) then
    UIUtils.PopupHintMessage(60049)
    return
  end
  if self.confirmCallback ~= nil then
    self.confirmCallback(strName)
  end
  self.Close()
end
function UICommonModifyPanel:OnValueChange()
  local str = self.mView.mText_InputField.text
  self.mView.mText_Num.text = utf8.len(str)
  self.mView.mText_AllNum.text = "/" .. 7
  setactive(self.mView.mTrans_TextLimit, 0 < #str)
end
