DarkZoneExploreGlobal = {}
function DarkZoneExploreGlobal.GetExploreData(level)
  return NetCmdDarkZoneSeasonData:GetDarkZoneExploreData(level)
end
function DarkZoneExploreGlobal.CheckExploreLevelOpen(level)
  return NetCmdDarkZoneSeasonData:IsDarkZoneExploreUnlock(level)
end
