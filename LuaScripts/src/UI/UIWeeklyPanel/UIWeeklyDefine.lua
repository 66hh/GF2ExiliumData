UIWeeklyDefine = {
  MaxShowTeamCount = 3,
  TeamMaxGunCount = 4,
  StoryID = 5007,
  LevelType = {
    Start = 11,
    Normal = 12,
    End = 19
  },
  GameMode = {A = 1, B = 2},
  NotOpenTipCheck = function(callBack)
    if not NetCmdSimulateBattleData:IsWeeklyOpen() then
      MessageBoxPanel.ShowSingleType(TableData.GetHintById(180161), function()
        UIManager.JumpToMainPanel()
      end)
      if callBack then
        MessageSys:RemoveListener(UIEvent.UserTapScreen, callBack)
      end
    end
  end
}
