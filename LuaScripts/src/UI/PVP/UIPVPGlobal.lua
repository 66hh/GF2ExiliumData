require("UI.PVP.Item.UIPVPTeamGunAvatarItem")
UIPVPGlobal = {}
UIPVPGlobal.NrtPvpTicket = GlobalConfig.PVPTicketId
UIPVPGlobal.GunMaxStar = 6
UIPVPGlobal.DelayShow = 0.5
UIPVPGlobal.CurPreviewMapIndex = -1
UIPVPGlobal.isMyDefend = false
UIPVPGlobal.TextCostRich = "{0}"
UIPVPGlobal.ButtonType = {
  Challenge = 1,
  History = 2,
  Jump = 3
}
UIPVPGlobal.LineUpType = {
  Attack = 1,
  Defend = 2,
  MeDefend = 3
}
UIPVPGlobal.PVPBattleType = {Challenge = 1, Revenge = 2}
UIPVPGlobal.CheckQueue = {
  None = 0,
  WeeklySettle = 1,
  RankChange = 2,
  RefreshMatchList = 3,
  KickOut = 4,
  Finish = 5
}
UIPVPGlobal.RewardType = {
  Receive = 0,
  Finish = 1,
  UnFinish = 2
}
UIPVPGlobal.LeftTabList = {
  Record = 1,
  Rank = 2,
  Store = 3,
  Robot = 4,
  Title = 5,
  unOPen = 6
}
UIPVPGlobal.RefreshState = {
  AllFree = 1,
  HasFree = 2,
  NoFree = 3
}
UIPVPGlobal.SeasonCallback = nil
UIPVPGlobal.CurRewardState = {}
UIPVPGlobal.IsOpenPVPChallengeDialog = 0
UIPVPGlobal.IsOpenPVPRankChangeDialog = false
UIPVPGlobal.RedPointKey = "_PVPStoreRedPoint_"
UIPVPGlobal.PvpCostNum = 1
function UIPVPGlobal.GetLevel(level)
  return NetCmdPVPData:GetLevel(level)
end
function UIPVPGlobal.GetCurSeasonLevelDataRow(points, ranking)
  local getBeatMatchDataRow = function(curBestMatchLevelDataRow, nrtPvpLevelDataRow)
    if curBestMatchLevelDataRow then
      if curBestMatchLevelDataRow.section < nrtPvpLevelDataRow.section or curBestMatchLevelDataRow.icon > nrtPvpLevelDataRow.icon then
        return nrtPvpLevelDataRow
      else
        return curBestMatchLevelDataRow
      end
    else
      return nrtPvpLevelDataRow
    end
  end
  local bestMatchLevelDataRow
  local idList = UIPVPGlobal.GetCurSeasonLevelDataIdList()
  for i = 0, idList.Count - 1 do
    local nrtPvpLevelDataRow = TableData.listNrtpvpLevelDatas:GetDataById(idList[i])
    if points >= nrtPvpLevelDataRow.lower_limit_points and points <= nrtPvpLevelDataRow.upper_limit_points then
      bestMatchLevelDataRow = getBeatMatchDataRow(bestMatchLevelDataRow, nrtPvpLevelDataRow)
    end
  end
  return bestMatchLevelDataRow
end
function UIPVPGlobal.GetCurSeasonLevelDataIdList()
  local nrtPvpSeasonData = NetCmdPVPData.seasonData
  local nrtPvpLevelByTypeData = TableData.listNrtpvpLevelByTypeDatas:GetDataById(nrtPvpSeasonData.type)
  if not nrtPvpLevelByTypeData then
    return nil
  end
  return nrtPvpLevelByTypeData.Id
end
function UIPVPGlobal.GetRankImage(level, image, imageBg)
  NetCmdPVPData:GetRankImage(level, image, imageBg)
end
function UIPVPGlobal.GetRankNumImage(level, imageNum)
  NetCmdPVPData:GetRankNumImage(level, imageNum)
end
function UIPVPGlobal.GetStageData()
  local stageId = NetCmdPVPData.seasonData.stage
  local stageData = TableData.listStageDatas:GetDataById(stageId)
  return stageData
end
function UIPVPGlobal.GetRewardValue()
  local count = NetCmdItemData:GetResCount(NetCmdPVPData.seasonData.season_item)
  return count
end
function UIPVPGlobal.GetRewardList(index)
  local tmpList = {}
  local pvpRewardData = TableData.listNrtpvpRewardDatas:GetDataById(index)
  for i, v in pairs(pvpRewardData.reward_list) do
    table.insert(tmpList, {index = i, value = v})
  end
  return tmpList
end
function UIPVPGlobal.GetAboutTime(time)
  local strTime = ""
  local deltaTime = CGameTime:GetTimestamp() - time
  deltaTime = deltaTime <= 0 and 1 or deltaTime
  if deltaTime < 3600 then
    strTime = math.ceil(deltaTime / 60)
    return strTime .. TableData.GetHintById(51)
  elseif 3600 <= deltaTime and deltaTime < 86400 then
    strTime = math.ceil(deltaTime / 3600)
    return strTime .. TableData.GetHintById(52)
  else
    strTime = math.ceil(deltaTime / 86400)
    return strTime .. TableData.GetHintById(53)
  end
  return strTime
end
function UIPVPGlobal.GetResult(pvpHistoryInfo, timeText, scoreText)
  local tmpAddOrCost = (pvpHistoryInfo.result or pvpHistoryInfo.ChangePoint >= 0) and " +" or " "
  scoreText.text = TableData.GetHintById(120006) .. tmpAddOrCost .. pvpHistoryInfo.ChangePoint
  timeText.text = UIPVPGlobal.GetAboutTime(pvpHistoryInfo.battleTime) .. TableData.GetHintById(108045)
end
function UIPVPGlobal.SetPvpGunCmdDatas(tmpTeamContent, gunCmdDatas, pvpOpponentInfo, detailType)
  tmpTeamContent = tmpTeamContent.transform
  for i = 0, gunCmdDatas.Count - 1 do
    local gunItem, tmpGunAvatarObj
    if i < tmpTeamContent.childCount then
      tmpGunAvatarObj = tmpTeamContent:GetChild(i).gameObject
    end
    local gunCmdData = gunCmdDatas[i]
    gunItem = UIPVPTeamGunAvatarItem.New(tmpTeamContent, tmpGunAvatarObj)
    gunItem:InitGun(gunCmdData, pvpOpponentInfo, i, detailType)
  end
  CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(tmpTeamContent)
  local scroller = tmpTeamContent:GetComponent(typeof(CS.MonoScrollerFadeManager))
  if scroller ~= nil then
    scroller.enabled = false
    scroller.enabled = true
  end
end
function UIPVPGlobal.GetChallengeAddPoint(level, index)
  local pvpPointsData = TableData.listNrtpvpPointsDatas:GetDataById(level)
  local tmpPlayer = "points_player" .. index .. "_add"
  return pvpPointsData[tmpPlayer]
end
