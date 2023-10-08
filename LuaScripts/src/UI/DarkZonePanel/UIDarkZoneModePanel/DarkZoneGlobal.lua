DarkZoneGlobal = {}
DarkZoneGlobal.PanelType = {
  Quest = 1,
  Explore = 2,
  EndLess = 3
}
DarkZoneGlobal.QuestType = {NewBie = 1, Normal = 2}
DarkZoneGlobal.LevelType = {}
DarkZoneGlobal.LevelTypeMin = 0
DarkZoneGlobal.LevelTypeMax = 0
DarkZoneGlobal.LevelToStcID = {}
DarkZoneGlobal.DepartToLevel = {}
DarkZoneGlobal.DepartList = {}
DarkZoneGlobal.StcIDToLevel = {}
DarkZoneGlobal.QuestState = {
  Locked = 0,
  UnLocked = 1,
  Finished = 2
}
DarkZoneGlobal.TimeLimitID = 311
DarkZoneGlobal.PopDelayTimeZone = 1.5
DarkZoneGlobal.PopDelayTime = 2.5
DarkZoneGlobal.NewBieGroupFinishKey = "NewBieGroupFinishKey"
DarkZoneGlobal.ExploreZone1 = "ExploreZone1_"
DarkZoneGlobal.ExploreZone2 = "ExploreZone2_"
DarkZoneGlobal.ExploreZone3 = "ExploreZone3_"
DarkZoneGlobal.NewQuestGroupUnlock = "DarkZoneNewQuestGroupUnlock"
DarkZoneGlobal.NewQuestGroupPopupUnlock = "DarkZoneNewQuestGroupPopupUnlock_"
DarkZoneGlobal.NewQuestBtnUnlock = "DarkZoneNewQuestBtnUnlock_"
DarkZoneGlobal.QuestUnlock = "DarkZoneQuestTaskUnlock_"
DarkZoneGlobal.ExploreZoneUnlock = "DarkZoneExploreUnlock_"
DarkZoneGlobal.EndLessZoneUnlock = "DarkZoneEndLessZoneUnlock_"
DarkZoneGlobal.ExploreZoneBeaconUnlock = "DarkZoneExploreBeaconUnlock"
DarkZoneGlobal.ExploreZoneRaidUnlock = "DarkZoneExploreRaidUnlock"
DarkZoneGlobal.EndlessItemRedPointKey = "_EndlessItemRedPointKey_"
DarkZoneGlobal.MakeTableRedPointKey = "_MakeTableRedPointKey_"
DarkZoneGlobal.NewExploreRedPointKey = "_NewExploreRedPointKey_"
DarkZoneGlobal.QuestUnlockId = 28000
DarkZoneGlobal.ColorType = {
  newBie = CS.GF2.UI.UITool.StringToColor("95cecc"),
  newBie2 = CS.GF2.UI.UITool.StringToColor("acce95"),
  normal = CS.GF2.UI.UITool.StringToColor("2b92c2"),
  hard = CS.GF2.UI.UITool.StringToColor("c2942b"),
  veryHard = CS.GF2.UI.UITool.StringToColor("c2412b"),
  noOpen = CS.GF2.UI.UITool.StringToColor("687470"),
  Open = CS.GF2.UI.UITool.StringToColor("568692")
}
DarkZoneGlobal.EventType = {
  Start = 1,
  Time = 2,
  Random = 3,
  End = 4
}
DarkZoneGlobal.ModeUnlockId = {
  [DarkZoneGlobal.PanelType.Quest] = 28002,
  [DarkZoneGlobal.PanelType.Explore] = 28006,
  [DarkZoneGlobal.PanelType.EndLess] = 28005
}
DarkZoneGlobal.ExploreUnlockId = {
  1113,
  1117,
  1121
}
DarkZoneGlobal.QuestMapPos = {
  Normal = Vector2(207, 117),
  Hard = Vector2(-334, 88),
  VeryHard = Vector2(-48, -271),
  Center = Vector2(-6.81, -31.5)
}
DarkZoneGlobal.QuestSize = Vector3(0.585, 0.585, 0.585)
DarkZoneGlobal.MapNormalSize = Vector3(0.355, 0.355, 0.355)
DarkZoneGlobal.CalculateTime = 30
DarkZoneGlobal.EventIcon = {
  [DarkZoneGlobal.EventType.Start] = "Icon_DarkzoneMapSelect_Begin",
  [DarkZoneGlobal.EventType.Random] = "Icon_DarkzoneMapSelect_Random",
  [DarkZoneGlobal.EventType.Time] = "Icon_DarkzoneMapSelect_Time",
  [DarkZoneGlobal.EventType.End] = "Icon_DarkzoneMapSelect_End"
}
DarkZoneGlobal.QuestCacheIDKey = "_DarkZoneQuestCacheIDKey_"
