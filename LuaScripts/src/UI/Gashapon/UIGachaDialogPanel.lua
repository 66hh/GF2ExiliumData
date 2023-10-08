require("UI.UIBasePanel")
require("UI.Gashapon.UIGachaDialogPanelView")
UIGachaDialogPanel = class("UIGachaDialogPanel", UIBasePanel)
UIGachaDialogPanel.__index = UIGachaDialogPanel
UIGachaDialogPanel.mView = nil
function UIGachaDialogPanel:ctor(csPanel)
  UIGachaDialogPanel.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIGachaDialogPanel:OnInit(root, data)
  UIGachaDialogPanel.super.SetRoot(UIGachaDialogPanel, root)
  self.mView = UIGachaDialogPanelView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mView:InitCtrl(self.mUIRoot)
  self.gunData = data[1]
  self.callback = data[2]
  self.quickCallBack = data[3]
  self.isUnskipable = data[4] or false
  self.skipPanel = data[5] or nil
  if self.skipPanel ~= nil then
    setactive(self.skipPanel.ui.mBtn_IconSkip.gameObject, not self.isUnskipable)
  end
  local soundData = TableData.listAudioDatas:GetDataById(self.gunData.get_audio)
  local soundArr = string.split(soundData.AudioName, "/")
  CS.CriWareAudioController.PlayVoice(soundArr[1], soundArr[2])
  self.ui.mText_Content.text = self.gunData.dialogue.str
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnClickClose()
  end
  function self.gashaSpeakEndFunc(msg)
    if msg ~= nil then
      self.isUnskipable = false
    end
    self:OnClickClose(msg)
  end
  self.closeTimer = TimerSys:DelayCall(1, function()
    if not CS.CriWareAudioController.IsVoicePlaying() then
      self.isUnskipable = false
      self:OnClickClose()
    end
  end, nil, -1)
  self.protectTimer = TimerSys:DelayCall(15, function()
    self.isUnskipable = false
    self:OnClickClose()
  end)
  MessageSys:AddListener(UIEvent.GashaSpeakEnd, self.gashaSpeakEndFunc)
end
function UIGachaDialogPanel:OnClickClose(msg)
  if self.isUnskipable then
    return
  end
  if self.closeTimer ~= nil then
    self.closeTimer:Stop()
    self.closeTimer = nil
  end
  if self.protectTimer ~= nil then
    self.protectTimer:Stop()
    self.protectTimer = nil
  end
  CS.CriWareAudioController.StopVoice()
  UISystem:CloseUIForce(UIDef.UIGachaDialogPanel)
  if msg ~= nil and msg.Sender ~= nil then
    if self.quickCallBack ~= nil then
      self.quickCallBack()
      self.callback = nil
      self.quickCallBack = nil
    end
  elseif self.callback ~= nil then
    self.callback()
    self.callback = nil
    self.quickCallBack = nil
  end
end
function UIGachaDialogPanel:OnClose()
  MessageSys:RemoveListener(UIEvent.GashaSpeakEnd, self.gashaSpeakEndFunc)
end
