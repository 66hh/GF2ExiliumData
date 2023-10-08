require("UI.UIBasePanel")
UIChangeAutographPanel = class("UIChangeAutographPanel", UIBasePanel)
UIChangeAutographPanel.__index = UIChangeAutographPanel
UIChangeAutographPanel.mView = nil
UIChangeAutographPanel.mData = nil
function UIChangeAutographPanel:ctor()
  UIChangeAutographPanel.super.ctor(self)
end
function UIChangeAutographPanel.Open()
  UIChangeAutographPanel.OpenUI(UIDef.UIChangeAutographPanel)
end
function UIChangeAutographPanel.Close()
  UIManager.CloseUI(UIDef.UIChangeAutographPanel)
end
function UIChangeAutographPanel.Init(root, data)
  self = UIChangeAutographPanel
  UIChangeAutographPanel.super.SetRoot(UIChangeAutographPanel, root)
  self.mData = data
end
function UIChangeAutographPanel.OnInit()
  self = UIChangeAutographPanel
  UIChangeAutographPanel.mView = UIChangeAutographPanelView.New()
  UIChangeAutographPanel.mView:InitCtrl(self.mUIRoot)
  UIUtils.GetListener(self.mView.mBtn_CancelBtn.gameObject).onClick = function()
    UIChangeAutographPanel:OnClose()
  end
  UIUtils.GetListener(self.mView.mBtn_ComfirmBtn.gameObject).onClick = function()
    UIChangeAutographPanel:OnClickChangeSign()
  end
  self.mView.mInput_Sign.onValueChanged:AddListener(function()
    UIChangeAutographPanel:OnValueChanged()
  end)
  local roleInfo = AccountNetCmdHandler:GetRoleInfoData()
  if roleInfo ~= nil then
    self.mView.mInput_Sign.text = roleInfo.PlayerMotto
  end
  self:UpdatePanel()
end
function UIChangeAutographPanel.OnShow()
  self = UIChangeAutographPanel
end
function UIChangeAutographPanel.OnRelease()
  self = UIChangeAutographPanel
  UIChangeAutographPanel.mData = nil
end
function UIChangeAutographPanel:UpdatePanel()
end
function UIChangeAutographPanel:OnClose()
  self:Close()
end
function UIChangeAutographPanel:OnClickChangeSign()
  local wordNum = UIUtils.GetStringWordNum(self.mView.mInput_Sign.text)
  if wordNum == 0 then
    UIGuildGlobal:PopupHintMessage(7005)
    return
  end
  if wordNum > TableData:GetMottoLimit() then
    UIGuildGlobal:PopupHintMessage(7003)
    return
  end
  AccountNetCmdHandler:SendReqModPlayerMotto(self.mView.mInput_Sign.text, function(ret)
    UIChangeAutographPanel:OnCallback(ret)
  end)
end
function UIChangeAutographPanel:OnCallback(ret)
  if ret == ErrorCodeSuc then
    MessageSys:SendMessage(CS.GF2.Message.UIEvent.RefreshSgin, nil)
    UIGuildGlobal:PopupHintMessage(7001)
    UIManager.CloseUI(UIDef.UIChangeAutographPanel)
  else
    UIGuildGlobal:PopupHintMessage(7004)
  end
end
function UIChangeAutographPanel:OnValueChanged()
  local wordNum = UIUtils.GetStringWordNum(self.mView.mInput_Sign.text)
  if wordNum > TableData:GetMottoLimit() then
    UIGuildGlobal:PopupHintMessage(7003)
    return
  end
end
