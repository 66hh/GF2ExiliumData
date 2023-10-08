require("UI.UIBasePanel")
UIWeeklyNewSeasonDialog = class("UIWeeklyNewSeasonDialog", UIBasePanel)
UIWeeklyNewSeasonDialog.__index = UIWeeklyNewSeasonDialog
function UIWeeklyNewSeasonDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeeklyNewSeasonDialog:OnInit(root)
  self.super.SetRoot(self, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:RegisterEvent()
  self.mData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  self:UpdateAll()
end
function UIWeeklyNewSeasonDialog.CloseSelf()
  local data = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  if data:CheckSimWeeklyNeedNewWatch() then
    data:WatchSimWeekly()
  end
  UIManager.CloseUI(UIDef.UIWeeklyNewSeasonDialog)
end
function UIWeeklyNewSeasonDialog:OnClose()
end
function UIWeeklyNewSeasonDialog:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self.CloseSelf()
  end
end
function UIWeeklyNewSeasonDialog:UpdateAll()
  local data = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  if not data then
    return
  end
  self.ui.mText_Time:StartCountdown(data:GetCloseTime())
  setactive(self.ui.mTrans_ResetBScore, data.isResetBScore)
  setactive(self.ui.mTrans_ResetTask, data.isResetTask)
end
