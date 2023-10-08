require("UI.UIBasePanel")
UIWeeklyRankPromotionDialog = class("UIWeeklyRankPromotionDialog", UIBasePanel)
UIWeeklyRankPromotionDialog.__index = UIWeeklyRankPromotionDialog
function UIWeeklyRankPromotionDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIWeeklyRankPromotionDialog:OnInit(root)
  self.super.SetRoot(UIWeeklyRankPromotionDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  self:Refresh()
end
function UIWeeklyRankPromotionDialog:Refresh()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIWeeklyRankPromotionDialog)
    UIManager.OpenUI(UIDef.UIWeeklyModeBSettlementPanel)
  end
  local scoreData = self.mData:GetGameBRankDataByScore(self.mData.gameBLastScore)
  if scoreData then
    self.ui.mText_Lv.text = scoreData.name.str
  end
end
