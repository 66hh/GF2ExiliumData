UIRaidDuringPanel = class("UIRaidDuringPanel", UIBasePanel)
function UIRaidDuringPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIRaidDuringPanel.Open(data)
  UIManager.OpenUIByParam(UIDef.UIRaidDuringPanel, data)
end
function UIRaidDuringPanel.Close()
  UIManager.CloseUI(UIDef.UIRaidDuringPanel)
end
function UIRaidDuringPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
end
function UIRaidDuringPanel:OnInit(root, data)
  self.OnDuringEndCallback = data.OnDuringEndCallback
  local animLength = self.ui.mAnimation.clip.length
  self.mTimer = TimerSys:DelayCall(animLength, function()
    UIManager.CloseUI(UIDef.UIRaidDuringPanel)
    if self.OnDuringEndCallback then
      self:OnDuringEndCallback()
    end
  end)
end
function UIRaidDuringPanel:OnShowStart()
  local canvasGroup = self.mUIRoot:Find("Root"):GetComponent("CanvasGroup")
  canvasGroup.blocksRaycasts = true
  self.ui.mAnimation:Play()
end
function UIRaidDuringPanel:OnClose()
  local canvasGroup = self.mUIRoot:Find("Root"):GetComponent("CanvasGroup")
  canvasGroup.blocksRaycasts = false
end
function UIRaidDuringPanel:OnRelease()
  if self.mTimer ~= nil then
    self.mTimer:Stop()
  end
  self.mTimer = nil
  self.super.OnRelease(self)
end
