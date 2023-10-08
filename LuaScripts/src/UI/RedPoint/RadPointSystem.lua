require("UI.RedPoint.RedPointNode")
require("UI.RedPoint.RedPointConst")
local RedPointSystem = class("RedPointSystem")
RedPointSystem.__index = RedPointSystem
RedPointSystem.instance = nil
RedPointSystem.rootNode = nil
RedPointSystem.listRedPointTreeList = {
  RedPointConst.Main,
  RedPointConst.Mails,
  RedPointConst.Chapters,
  RedPointConst.Chapter,
  RedPointConst.ChapterReward,
  RedPointConst.StoryBattleStage,
  RedPointConst.SimResourceStageIndex,
  RedPointConst.SimulateBattle,
  RedPointConst.Daily,
  RedPointConst.Notice,
  RedPointConst.Barracks,
  RedPointConst.PlayerInfo,
  RedPointConst.PlayerCard,
  RedPointConst.Chat,
  RedPointConst.UAV,
  RedPointConst.Friend,
  RedPointConst.ApplyFriend,
  RedPointConst.ApplyTeam,
  RedPointConst.LoungeChat,
  RedPointConst.Archives,
  RedPointConst.Store,
  RedPointConst.Gacha,
  RedPointConst.AccumulateRecharge,
  RedPointConst.PVP,
  RedPointConst.Repository,
  RedPointConst.RepositoryPiece,
  RedPointConst.RepositoryGunPiece,
  RedPointConst.CommandCenter,
  RedPointConst.CommandCenterIndoor,
  RedPointConst.CommandCenterOutDoor,
  RedPointConst.DarkZoneQuest,
  RedPointConst.RecentActivity,
  RedPointConst.BattlePass,
  RedPointConst.BattlePassTask,
  RedPointConst.BattlePassMain,
  RedPointConst.BattlePassCollection,
  RedPointConst.MainPlayerInfo,
  RedPointConst.MainBattlePass,
  RedPointConst.MainChapters,
  RedPointConst.MainDaily,
  RedPointConst.MainBarracks,
  RedPointConst.MainGacha,
  RedPointConst.MainRecentActivity,
  RedPointConst.NewTask
}
function RedPointSystem:ctor()
  self.rootNode = nil
  MessageSys:AddListener(CS.GF2.Message.RedPointEvent.InitRedPointCount, self.InitRedPointCount)
  MessageSys:AddListener(CS.GF2.Message.RedPointEvent.RedPointUpdate, self.RedPointUpdate)
end
function RedPointSystem.OnRelease()
  self = RedPointSystem
end
function RedPointSystem:GetInstance()
  if self.instance == nil then
    self.instance = self.New()
    self.instance:InitRedPointTree()
  end
  return self.instance
end
function RedPointSystem:InitRedPointTree()
  self.rootNode = RedPointNode.New()
  self.rootNode.nodeName = RedPointConst.Main
  self.rootNode.fullName = RedPointConst.Main
  for _, value in pairs(self.listRedPointTreeList) do
    local node = self.rootNode
    local treeNodeArr = string.split(value, ":")
    if treeNodeArr[1] == self.rootNode.nodeName and 1 < #treeNodeArr then
      for i = 2, #treeNodeArr do
        local name = treeNodeArr[i]
        if node.dicChild[name] == nil then
          node.dicChild[name] = RedPointNode.New()
        end
        node.dicChild[name].nodeName = name
        node.dicChild[name].fullName = node.fullName .. ":" .. name
        node.dicChild[name].parent = node
        node = node.dicChild[name]
      end
    end
  end
end
function RedPointSystem:AddRedPointListener(strNode, objRedPoint, callback, systemId)
  if strNode == nil or strNode == "" then
    return
  end
  local nodeList = string.split(strNode, ":")
  if #nodeList == 1 and nodeList[1] ~= RedPointConst.Main then
    printstack("Get Wrong Root Node! current is " .. nodeList[1])
    return
  end
  local node = self.rootNode
  for i = 2, #nodeList do
    if node.dicChild[nodeList[i]] == nil then
      printstack("Does Not Contains Child Node :" .. nodeList[i])
      return
    end
    node = node.dicChild[nodeList[i]]
    if i == #nodeList then
      node.systemId = systemId
      node.onNumChangeCallback = callback
      node:SetRedPointObj(objRedPoint)
    end
  end
end
function RedPointSystem:RemoveRedPointListener(strNode)
  if strNode == nil or strNode == "" then
    return
  end
  local nodeList = string.split(strNode, ":")
  if #nodeList == 1 and nodeList[1] ~= RedPointConst.Main then
    printstack("Get Wrong Root Node! current is " .. nodeList[1])
    return
  end
  local node = self.rootNode
  for i = 2, #nodeList do
    if node.dicChild[nodeList[i]] == nil then
      printstack("Does Not Contains Child Node :" .. nodeList[i])
      return
    end
    node = node.dicChild[nodeList[i]]
    if i == #nodeList then
      node.onNumChangeCallback = nil
      node.objRedPoint = nil
      node.txtRedNum = nil
    end
  end
end
function RedPointSystem:SetInvoke(strNode, redNum)
  if strNode == "" then
    return
  end
  local nodeList = string.split(strNode, ":")
  if #nodeList == 1 and nodeList[1] ~= RedPointConst.Main then
    printstack("Get Wrong Root Node! current is " .. nodeList[1])
    return
  end
  local node = self.rootNode
  node:SetRedPointNum(redNum)
  for i = 2, #nodeList do
    if node.dicChild[nodeList[i]] == nil then
      printstack("Does Not Contains Child Node :" .. nodeList[i])
      return
    end
    node = node.dicChild[nodeList[i]]
    if i == #nodeList then
      node:SetRedPointNum(redNum)
    end
  end
end
function RedPointSystem:GetRedPointCountByType(strNode)
  if strNode == "" then
    return
  end
  local nodeList = string.split(strNode, ":")
  if #nodeList == 1 then
    if nodeList[1] ~= RedPointConst.Main then
      printstack("Get Wrong Root Node! current is " .. nodeList[1])
      return
    end
    return self.rootNode:GetRedPointNum()
  end
  local node = self.rootNode
  for i = 2, #nodeList do
    if node.dicChild[nodeList[i]] == nil then
      printstack("Does Not Contains Child Node :" .. nodeList[i])
      return
    end
    node = node.dicChild[nodeList[i]]
    if i == #nodeList then
      return node:GetRedPointNum()
    end
  end
end
function RedPointSystem.RedPointUpdate(obj)
  local id = obj.Sender
  if id then
    local type = RedPointConst[id]
    if type then
      RedPointSystem:GetInstance():UpdateRedPointByType(type)
    end
  end
end
function RedPointSystem.InitRedPointCount()
  RedPointSystem:GetInstance():UpdateAllSystem()
end
function RedPointSystem:UpdateRedPointByType(type, needMessage)
  if type == nil then
    return
  end
  needMessage = needMessage ~= nil and needMessage or true
  local count = 0
  if type == RedPointConst.Mails then
    count = NetCmdMailData:UpdateRedPoint()
  elseif type == RedPointConst.BattlePass or type == RedPointConst.MainBattlePass then
    count = NetCmdBattlePassData:GetShowCommandSceneRedPoint()
  elseif type == RedPointConst.ChapterReward then
    count = NetCmdDungeonData:UpdateRewardRedPoint()
  elseif type == RedPointConst.StoryBattleStage then
    local hasReward = false
    local storyList = TableData.GetNormalChapterList()
    for i = 0, storyList.Count - 1 do
      hasReward = hasReward or 0 < NetCmdDungeonData:UpdateChatperRewardRedPoint(storyList[i].id)
    end
    local isNeedRedPoint = NetCmdSimulateBattleData:CheckTeachingUnlockRedPoint() or NetCmdSimulateBattleData:CheckTeachingRewardRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteReadRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint()
    if hasReward or isNeedRedPoint then
      count = count + 1
    end
  elseif type == RedPointConst.SimResourceStageIndex then
    if NetCmdSimulateBattleData:CheckSimStageIndexRedPoint(4) then
      count = count + 1
    end
  elseif type == RedPointConst.SimulateBattle then
    if NetCmdSimulateBattleData:CheckSimBattleHasRedPoint() then
      count = count + 1
    end
  elseif type == RedPointConst.Daily or type == RedPointConst.MainDaily then
    count = NetCmdQuestData:UpdateRedPoint()
  elseif type == RedPointConst.Notice then
    count = PostInfoConfig.UpdateRedPoint()
  elseif type == RedPointConst.Gacha or type == RedPointConst.MainGacha then
    count = GashaponNetCmdHandler:UpdateRedPoint()
  elseif type == RedPointConst.Barracks or type == RedPointConst.MainBarracks then
    count = NetCmdTeamData:UpdateBarracksRedPoint()
  elseif type == RedPointConst.PlayerInfo or type == RedPointConst.MainPlayerInfo then
    count = NetCmdIllustrationData:UpdatePlayerCardRedPoint() + NetCmdIllustrationData:UpdatePlayerSettingRedPoint()
  elseif type == RedPointConst.PlayerCard or type == RedPointConst.MainPlayerCard then
    count = NetCmdIllustrationData:UpdatePlayerCardRedPoint()
  elseif type == RedPointConst.Friend then
    count = NetCmdFriendData:UpdateRedPoint()
  elseif type == RedPointConst.ApplyFriend then
    count = NetCmdFriendData:UpdateApplyFriendRedPoint()
  elseif type == RedPointConst.Chat then
    count = NetCmdChatData:UpdateChatRedPoint() + NetCmdChatData:UpdateTeamChatRedPoint()
  elseif type == RedPointConst.Repository then
    count = NetCmdItemData:UpdateWeaponPieceRedPoint() + NetCmdItemData:UpdateGiftPickRedPoint()
  elseif type == RedPointConst.RepositoryPiece then
    count = NetCmdItemData:UpdateWeaponPieceRedPoint()
  elseif type == RedPointConst.RepositoryGunPiece then
    count = NetCmdItemData:UpdateWeaponPieceRedPoint()
  elseif type == RedPointConst.FriendChat then
    count = NetCmdChatData:UpdateChatRedPoint()
  elseif type == RedPointConst.TeamChat then
    count = NetCmdChatData:UpdateTeamChatRedPoint()
  elseif type == RedPointConst.LoungeChat then
    count = 0
  elseif type == RedPointConst.Archives then
    count = NetCmdArchivesData:UpdateArchivesRedPoint()
  elseif type == RedPointConst.Store then
    count = NetCmdStoreData:GetStoreRedPoint()
  elseif type == RedPointConst.AccumulateRecharge then
    count = NetCmdStoreData:GetAccumulateRechargeRedPoint()
  elseif type == RedPointConst.ExchangeLicense then
    count = NetCmdStoreData:GetExchangeStoreRedPoint()
  elseif type == RedPointConst.PVP then
    if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.Nrtpvp) then
      count = NetCmdPVPData:CheckPvpRedPoint()
    end
  elseif type == RedPointConst.CommandCenterIndoor then
    count = NetCmdCommandCenterAdjutantData:GetInDoorBackgroundRedPointNum()
  elseif type == RedPointConst.CommandCenterOutDoor then
    count = NetCmdCommandCenterAdjutantData:GetOutDoorBackgroundRedPointNum()
  elseif type == RedPointConst.DarkZoneQuest then
    count = NetCmdDarkZoneSeasonData:UpdateQuestRedPoint()
  elseif type == RedPointConst.RecentActivity or type == RedPointConst.MainRecentActivity then
    if NetCmdRecentActivityData:CheckAllRecentActivityRedPoint() then
      count = count + 1
    end
    if NetCmdThemeData:ThemeHaveRedPoint(0) then
      count = count + 1
    end
  elseif type == RedPointConst.BattlePassMain then
    count = NetCmdBattlePassData:UpdateMainPanelRedPointCount()
  elseif type == RedPointConst.BattlePassTask then
    count = NetCmdBattlePassData:UpdateRedPointCount()
  elseif type == RedPointConst.BattlePassCollection then
    count = NetCmdBattlePassData:UpdateCollectionRedPointCount()
  elseif type == RedPointConst.NewTask then
    count = NetCmdQuestData:UpdateNewTaskRedPoint()
  end
  if needMessage == true then
    self:SetInvoke(type, count)
  end
end
function RedPointSystem:UpdateAllSystem()
  self:UpdateRedPointByType(RedPointConst.Chapters)
  self:UpdateRedPointByType(RedPointConst.ChapterReward)
  self:UpdateRedPointByType(RedPointConst.StoryBattleStage)
  self:UpdateRedPointByType(RedPointConst.SimResourceStageIndex)
  self:UpdateRedPointByType(RedPointConst.SimulateBattle)
  self:UpdateRedPointByType(RedPointConst.Mails)
  self:UpdateRedPointByType(RedPointConst.Daily)
  self:UpdateRedPointByType(RedPointConst.Notice)
  self:UpdateRedPointByType(RedPointConst.Barracks)
  self:UpdateRedPointByType(RedPointConst.PlayerInfo)
  self:UpdateRedPointByType(RedPointConst.MainPlayerInfo)
  self:UpdateRedPointByType(RedPointConst.PlayerCard)
  self:UpdateRedPointByType(RedPointConst.Chat)
  self:UpdateRedPointByType(RedPointConst.UAV)
  self:UpdateRedPointByType(RedPointConst.Friend)
  self:UpdateRedPointByType(RedPointConst.ApplyFriend)
  self:UpdateRedPointByType(RedPointConst.ApplyTeam)
  self:UpdateRedPointByType(RedPointConst.LoungeChat)
  self:UpdateRedPointByType(RedPointConst.Archives)
  self:UpdateRedPointByType(RedPointConst.Store)
  self:UpdateRedPointByType(RedPointConst.PVP)
  self:UpdateRedPointByType(RedPointConst.DarkZoneQuest)
  self:UpdateRedPointByType(RedPointConst.RecentActivity)
  self:UpdateRedPointByType(RedPointConst.BattlePassTask)
  self:UpdateRedPointByType(RedPointConst.BattlePass)
  self:UpdateRedPointByType(RedPointConst.MainBattlePass)
  self:UpdateRedPointByType(RedPointConst.BattlePassMain)
  self:UpdateRedPointByType(RedPointConst.BattlePassCollection)
  self:UpdateRedPointByType(RedPointConst.MainChapters)
  self:UpdateRedPointByType(RedPointConst.MainDaily)
  self:UpdateRedPointByType(RedPointConst.MainBarracks)
  self:UpdateRedPointByType(RedPointConst.MainGacha)
  self:UpdateRedPointByType(RedPointConst.MainRecentActivity)
  self:UpdateRedPointByType(RedPointConst.NewTask)
end
function RedPointSystem.DebugRedPointLog(root)
  local function _dump(t, space)
    local temp = {}
    local value = RedPointSystem:GetInstance():GetRedPointCountByType(t.fullName)
    table.insert(temp, space .. "+" .. t.nodeName .. " (" .. value .. ")")
    if t.dicChild ~= nil then
      for k, v in pairs(t.dicChild) do
        table.insert(temp, space .. _dump(v, string.rep(" ", #tostring(t.nodeName))))
      end
    end
    return table.concat(temp, "\n")
  end
  print("\n" .. _dump(RedPointSystem:GetInstance().rootNode, ""))
end
return RedPointSystem
