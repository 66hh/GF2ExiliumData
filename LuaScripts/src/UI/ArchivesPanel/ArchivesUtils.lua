ArchivesUtils = {}
ArchivesUtils.Type = {
  Audio = "Audio",
  Paper = "Paper",
  Video = "Video",
  Electron = "Electron"
}
ArchivesUtils.IsBackFromPlotPanel = false
ArchivesUtils.IsPlayed = false
ArchivesUtils.CurAudioItem = nil
ArchivesUtils.AnimState = -1
ArchivesUtils.EnterWay = 0
ArchivesUtils.IsPlayCodeNameAnim = 0
function ArchivesUtils:SetIndex(num)
  if 1 <= num and num <= 9 then
    return "0" .. tostring(num)
  else
    return tostring(num)
  end
end
function ArchivesUtils:JudgeGunUnLock(IdList)
  for i = 0, IdList.Count - 1 do
    if NetCmdTeamData:GetGunByID(IdList[i]) ~= nil then
      return true, IdList[i]
    end
  end
  return false, 0
end
function ArchivesUtils:GetGunData(IdList)
  for i = 0, IdList.Count - 1 do
    local data = NetCmdTeamData:GetGunByID(IdList[i])
    if data ~= nil then
      return data
    end
  end
  return nil
end
function ArchivesUtils:GetUnlockBestRank(IdList)
  local maxrank = 0
  for i = 0, IdList.Count - 1 do
    local data = NetCmdTeamData:GetGunByID(IdList[i])
    if data ~= nil then
      local gundata = TableData.listGunDatas:GetDataById(data.mGun.Id)
      maxrank = maxrank >= gundata.rank and maxrank or gundata.rank
    end
  end
  return maxrank
end
