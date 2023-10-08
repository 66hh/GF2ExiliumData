require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
ActivityTourTurnChangeDialog = class("ActivityTourTurnChangeDialog", UIBasePanel)
ActivityTourTurnChangeDialog.__index = ActivityTourTurnChangeDialog
function ActivityTourTurnChangeDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourTurnChangeDialog:OnInit(root)
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  MessageSys:SendMessage(MonopolyEvent.ResetActionTimeLine, nil)
  MessageSys:SendMessage(MonopolyEvent.OnRefreshRoundCount, nil)
  self:UpdateAll()
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourTurnChangeDialog.CloseSelf()
  UIManager.CloseUI(UIDef.ActivityTourTurnChangeDialog)
end
function ActivityTourTurnChangeDialog:UpdateAll()
  if MonopolyWorld.IsGmMode then
    return
  end
  local currentRound = NetCmdMonopolyData.currentRound
  self.ui.mText_CurrentRound.text = tostring(currentRound)
  local tipRoundCount = MonopolyWorld.MpData.levelData.prompt_round
  local showTip = currentRound >= tipRoundCount
  setactive(self.ui.mText_LeftRound, showTip)
  if showTip then
    self.ui.mText_LeftRound.text = UIUtils.StringFormatWithHintId(270160, MonopolyWorld.MpData.levelData.max_round - currentRound)
  end
end
function ActivityTourTurnChangeDialog:OnFadeInFinish()
  self:DelayCall(2, function()
    UIManager.CloseUI(UIDef.ActivityTourTurnChangeDialog)
  end)
end
function ActivityTourTurnChangeDialog:OnClose()
  self:ReleaseTimers()
end
