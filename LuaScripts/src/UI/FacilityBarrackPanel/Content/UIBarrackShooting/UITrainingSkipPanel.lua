UITrainingSkipPanel = class("UITrainingSkipPanel", UIBasePanel)
UITrainingSkipPanel.TrainingType = {LevelUp = 1, Break = 2}
function UITrainingSkipPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
  csPanel.UsePool = false
end
function UITrainingSkipPanel:OnAwake(root, gunId)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BgSkip.gameObject, function()
    self:onClickSkip()
  end)
  setactive(self.ui.mBtn_IconSkip, false)
  self.ui.mText_Skip.text = TableData.GetHintById(109003)
end
function UITrainingSkipPanel:OnInit(root, data)
  self.gunId = data.GunId
  self.type = data.TrainingType
  self.onClickSkipCallback = data.OnClickSkipCallback
end
function UITrainingSkipPanel:OnShowStart()
  setactive(self.ui.mBtn_BgSkip, true)
  setactive(self.ui.mTrans_NextTips, true)
end
function UITrainingSkipPanel:OnCameraStart()
  return 0.01
end
function UITrainingSkipPanel:OnCameraBack()
  return 0.01
end
function UITrainingSkipPanel:OnClose()
  self.gunId = nil
  self.gunCmdData = nil
end
function UITrainingSkipPanel:OnRelease()
  self.ui = nil
  self.super.OnRelease(self)
end
function UITrainingSkipPanel:onClickSkip()
  UIManager.CloseUI(UIDef.UITrainingSkipPanel)
  AudioUtils.PlayCommonAudio(1050076)
  if self.onClickSkipCallback then
    self.onClickSkipCallback()
    self.onClickSkipCallback = nil
  end
end
