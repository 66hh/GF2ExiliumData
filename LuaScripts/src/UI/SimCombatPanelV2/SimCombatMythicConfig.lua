SimCombatMythicConfig = {}
SimCombatMythicConfig.CurSelectedStageGroupIndex = 0
SimCombatMythicConfig.CurSelectedStageLevelIndex = 0
SimCombatMythicConfig.CurSelectedStageLevelTaskIndex = 0
SimCombatMythicConfig.ChapterItemWidth = 542
SimCombatMythicConfig.ChapterItemSpace = -110
SimCombatMythicConfig.ChapterItemPadding = 355
SimCombatMythicConfig.ScreenCenterX = 640
SimCombatMythicConfig.ChapterNumWidth = 67
SimCombatMythicConfig.BattleDetailWidth = 420
SimCombatMythicConfig.ChapterItemMoveDuration = 0.3
SimCombatMythicConfig.IsReadyToStartTutorial = false
SimCombatMythicConfig.ShowWeeklyReset = {IsShow = false, ShowType = 1}
SimCombatMythicConfig.StageGroupState = {LOCK = 0, UNLOCK = 1}
SimCombatMythicConfig.StageLevelState = {
  LOCK = 0,
  UNLOCK = 1,
  FINISH_BASE = 2,
  FINISH_ADVANCE = 3
}
SimCombatMythicConfig.StageTaskState = {
  LOCK = 0,
  UNLOCK = 1,
  FINISH = 2
}
function SimCombatMythicConfig.GetStageLevelNumICon(index)
  local iconName = "Img_SimCombatMythic_Num_" .. tostring(index)
  return IconUtils.GetRogueIcon(iconName)
end
function SimCombatMythicConfig.GetStageTaskLevelNumICon(index)
  local iconName = "Img_SimCombatMythic_Num_" .. tostring(index)
  return IconUtils.GetRogueIcon(iconName)
end
