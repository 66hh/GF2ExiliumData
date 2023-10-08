require("UI.PVP.UIPVPGlobal")
require("UI.UIBasePanel")
require("UI.PVP.Item.UIPVPMainLeftTabItem")
UIPVPMainPanel = class("UIPVPMainPanel", UIBasePanel)
UIPVPMainPanel.__index = UIPVPMainPanel
local self = UIPVPMainPanel
function UIPVPMainPanel:ctor(obj)
  UIPVPMainPanel.super.ctor(self)
  obj.Type = UIBasePanelType.Panel
end
function UIPVPMainPanel:OnAwake()
  NetCmdPVPData:RequestPVPInfo(function()
  end)
end
function UIPVPMainPanel:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.closeTimer = nil
  self.pvpData = NetCmdPVPData.PvpInfo
  self.pvpMatchInfo = NetCmdPVPData.PvpMatchInfo
  self.isClose = not NetCmdPVPData.PVPIsOpen
  self.timeHint = TableData.GetHintById(120024)
  setactive(self.ui.mBtn_Info.gameObject, false)
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UINRTPVPPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnStart.gameObject).onClick = function()
    if self.isClose then
      self:CurWeeklySettleIsClose()
    else
      UIPVPGlobal.IsOpenPVPChallengeDialog = UIDef.UIPVPChallengeDialog
      UIManager.OpenUI(UIDef.UIPVPChallengeDialog)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnDefenseFleet.gameObject).onClick = function()
    self:OnDefenseClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NewPlayer.gameObject).onClick = function()
    self:OnNewPlayerClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Toggle.gameObject).onClick = function()
    if self.openFlagIndex == 0 then
      self.openFlagIndex = 1
    else
      self.openFlagIndex = 0
    end
    self:RehreshDetailState(true)
  end
  self:UpdateRoleInfo()
  self:UpdateRewardItem()
  self:CheckKickOut()
  function self.UpdateRewardInfo()
    self:UpdateRewardItem()
  end
  MessageSys:AddListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.UpdateRewardInfo)
end
function UIPVPMainPanel:RehreshDetailState(isPlayAni)
  if self.openFlagIndex == 1 then
    setactive(self.ui.mTrans_RightList, true)
    self.ui.mAnimator_Toggle:SetBool("Bool", true)
  else
    setactive(self.ui.mTrans_RightList, false)
    self.ui.mAnimator_Toggle:SetBool("Bool", false)
  end
  UIUtils.SetIntLocal("PVPMainPanelDetail", self.openFlagIndex)
end
function UIPVPMainPanel:OnClose()
  self:CleanCloseTimer()
  MessageSys:RemoveListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.UpdateRewardInfo)
end
function UIPVPMainPanel:OnShowFinish()
  if UIPVPGlobal.IsOpenPVPChallengeDialog ~= 0 and not self.isClose and (not NetCmdPVPData.PvpLevelChangeFlag or not not UIPVPGlobal.IsOpenPVPRankChangeDialog) then
    UIPVPGlobal.IsOpenPVPChallengeDialog = 0
  end
  if not self.isClose then
    self:UpdateDialog()
    self:UpdateRoleInfo()
    self:UpdateRewardItem()
    self:CheckKickOut()
  end
  self.openFlagIndex = UIUtils.GetIntLocal("PVPMainPanelDetail")
  self:RehreshDetailState(false)
end
function UIPVPMainPanel:UpdateRoleInfo()
  if NetCmdPVPData.nrtPvpSeasonId == 0 then
    return
  end
  self.currSeasonId = NetCmdPVPData.seasonData.season_id
  self.currSeasonName = NetCmdPVPData.seasonData.name.str
  self.ui.mText_Rank.text = UIPVPGlobal.GetLevel(self.pvpData.level)
  UIPVPGlobal.GetRankImage(self.pvpData.level, self.ui.mImg_Icon, self.ui.mImg_IconBg)
  self.ui.mText_WinNum.text = TableData.GetHintById(120020) .. NetCmdPVPData:GetRewardPoints()
  self.ui.mImg_Bg.sprite = IconUtils.GetAtlasSprite("PVPPic/Img_PVPRank_MainBG_" .. NetCmdPVPData:GetCurrentSeasonLevelId(self.pvpData.level).section)
end
function UIPVPMainPanel:OnDefenseClick()
  UIManager.OpenUI(UIDef.UIPVPDefenseTeamDialog)
end
function UIPVPMainPanel:OnNewPlayerClick()
  UIManager.OpenUIByParam(UIDef.UIPVPQuestPanel)
end
function UIPVPMainPanel:CleanCloseTimer()
  if self.closeTimer ~= nil then
    self.closeTimer:Stop()
    self.closeTimer = nil
  end
end
function UIPVPMainPanel:CheckKickOut()
  self:CleanCloseTimer()
  self.pvpLastTime = NetCmdPVPData.PVPLastTime
  local deltaTimeStr = NetCmdPVPData:ConvertPvpTime(CGameTime:GetTimestamp(), NetCmdPVPData.PVPCloseTime)
  if self.pvpLastTime <= 0 then
    self.ui.mText_Tittle.text = TableData.GetHintById(120151)
  elseif deltaTimeStr == nil or deltaTimeStr == "" then
    self.ui.mText_Tittle.text = TableData.GetHintById(120151)
  elseif self.currSeasonId == 1 then
    self.ui.mText_Tittle.text = TableData.GetHintById(120160, deltaTimeStr)
  else
    self.ui.mText_Tittle.text = TableData.GetHintById(120161, self.currSeasonName, deltaTimeStr)
  end
  local repeatCount = self.pvpLastTime + 1
  if self.pvpLastTime <= 0 then
    self:CurWeeklySettleIsClose()
    return
  end
  self.closeTimer = TimerSys:DelayCall(1, function()
    deltaTimeStr = NetCmdPVPData:ConvertPvpTime(CGameTime:GetTimestamp(), NetCmdPVPData.PVPCloseTime)
    if deltaTimeStr == nil or deltaTimeStr == "" then
      self.ui.mText_Tittle.text = TableData.GetHintById(120151)
    elseif self.currSeasonId == 1 then
      self.ui.mText_Tittle.text = TableData.GetHintById(120160, deltaTimeStr)
    else
      self.ui.mText_Tittle.text = TableData.GetHintById(120161, self.currSeasonName, deltaTimeStr)
    end
    if self.pvpLastTime <= 0 then
      self.ui.mText_Tittle.text = TableData.GetHintById(120151)
      if self.closeTimer ~= nil then
        self.closeTimer:Stop()
        self.closeTimer = nil
      end
      self:CurWeeklySettleIsClose()
    end
    self.pvpLastTime = self.pvpLastTime - 1
  end, nil, repeatCount)
end
function UIPVPMainPanel:UpdateDialog()
  self:UpdateBouns()
  self:UpdateLeftTabList()
  self:UpdateRightList()
  self:UpdateRedPoint()
  if self:CheckWeeklySettleEnd() then
    return
  end
  if self:CheckNewWeeklySettleOpen() then
    return
  end
  if self:CheckPvpLevelIsChange() then
    return
  end
end
function UIPVPMainPanel:IsReadyToStartTutorial()
  local tmpBoolean = NetCmdPVPData:GetPvpNewSeasonOpen()
  if tmpBoolean and NetCmdPVPData.seasonData.season_id > 0 then
    return false
  end
  tmpBoolean = NetCmdPVPData.SeasonSettle ~= nil
  if tmpBoolean then
    return false
  end
  tmpBoolean = NetCmdPVPData.PvpLevelChangeFlag and not UIPVPGlobal.IsOpenPVPRankChangeDialog
  if tmpBoolean then
    return false
  end
  return true
end
function UIPVPMainPanel:CurWeeklySettleIsClose()
  local hint = TableData.GetHintById(120203)
  local content = MessageContent.New(hint, MessageContent.MessageType.SingleBtn, function()
    self.isClose = true
    UIManager.JumpToMainPanel()
  end)
  MessageBoxPanel.Show(content)
end
function UIPVPMainPanel:CheckNewWeeklySettleOpen()
  local tmpBoolean = NetCmdPVPData:GetPvpNewSeasonOpen()
  if tmpBoolean and NetCmdPVPData.seasonData.season_id > 0 then
    UIManager.OpenUI(UIDef.UIPVPNewSeasonOpenDialog)
    return true
  end
  return false
end
function UIPVPMainPanel:CheckWeeklySettleEnd()
  local tmpBoolean = NetCmdPVPData.SeasonSettle ~= nil
  if tmpBoolean then
    UIManager.OpenUI(UIDef.UIPVPSeasonSettlementDialog)
    return true
  end
  return false
end
function UIPVPMainPanel:CheckPvpLevelIsChange()
  local tmpBoolean = NetCmdPVPData.PvpLevelChangeFlag and not UIPVPGlobal.IsOpenPVPRankChangeDialog
  if tmpBoolean then
    UIManager.OpenUI(UIDef.UIPVPRankChangeDialog)
    return true
  end
  return false
end
function UIPVPMainPanel:UpdateRewardItem()
  self.ui.mSlider_ProgressBar.FillAmount = 0
  self.ui.mText_WinNum.text = TableData.GetHintById(120020) .. NetCmdPVPData:GetRewardPoints()
  for i = 1, 3 do
    self:SetRewardItemWithIndex(i)
  end
end
function UIPVPMainPanel:UpdateBouns()
  self.ui.mText_Victories.text = string_format(TableData.GetHintById(120056), NetCmdPVPData.PvpInfo.bouns, TableData.GlobalSystemData.PvpContinuityTimes)
  if NetCmdPVPData.PvpInfo.bouns >= TableData.GlobalSystemData.PvpContinuityTimes then
    self.ui.mText_Victories.text = string_format(TableData.GetHintById(120056), 0, TableData.GlobalSystemData.PvpContinuityTimes)
  end
  setactive(self.ui.mTrans_Victories.gameObject, NetCmdPVPData.BonusRewardTime < TableData.GlobalSystemData.PvpContinuityWeeknumber)
end
function UIPVPMainPanel:SetRewardItemWithIndex(i)
  local tmpValue = UIPVPGlobal.GetRewardValue()
  local tableRewardValue = TableData.listNrtpvpRewardDatas:GetDataById(i).value
  local isGet = NetCmdPVPData:HasGetPvpPhaseReward(i)
  local canNotGet = tmpValue < tableRewardValue
  local notGet = not NetCmdPVPData:HasGetPvpPhaseReward(i) and tmpValue >= tableRewardValue
  if isGet then
    UIPVPGlobal.CurRewardState[i] = UIPVPGlobal.RewardType.Finish
  elseif canNotGet then
    UIPVPGlobal.CurRewardState[i] = UIPVPGlobal.RewardType.UnFinish
  elseif notGet then
    UIPVPGlobal.CurRewardState[i] = UIPVPGlobal.RewardType.Receive
  end
  UIUtils.GetButtonListener(self.ui["mBtn_RewardItem" .. i].gameObject).onClick = function()
    if UIPVPGlobal.CurRewardState[i] == UIPVPGlobal.RewardType.Receive then
      local otherTable = {}
      local pvpRewardData = TableData.listNrtpvpRewardDatas:GetDataById(i)
      for i = 1, pvpRewardData.reward_list.Key.Count do
        otherTable[pvpRewardData.reward_list.Key[i - 1]] = pvpRewardData.reward_list.Value[i - 1]
      end
      if TipsManager.CheckItemIsOverflowAndStopByList(otherTable) then
        return
      end
      NetCmdPVPData:ReqGetReward(i, function()
        UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
          nil,
          function()
            self:UpdateRewardItem()
          end
        })
      end)
    else
      UIManager.OpenUI(UIDef.UIPVPRewardDialog)
    end
  end
  self.ui["mText_RewardNum" .. i].text = tableRewardValue
  setactive(self.ui["mTrans_Effect" .. i], notGet)
  setactive(self.ui["mObj_RedPoint" .. i], notGet)
  setactive(self.ui["mTrans_Finished" .. i], isGet and not notGet)
  local rewardCount = TableData.listNrtpvpRewardDatas:GetList().Count
  local lastValue = i == 1 and 0 or TableData.listNrtpvpRewardDatas:GetDataById(i - 1).value
  if tmpValue >= lastValue and tmpValue <= tableRewardValue then
    local percent1 = (i - 1) / TableData.listNrtpvpRewardDatas:GetList().Count
    local deltaValue1 = tmpValue - lastValue
    local deltaValue2 = tableRewardValue - lastValue
    local percent2 = deltaValue1 / deltaValue2 / rewardCount
    local resultPercent = percent1 + percent2
    self.ui.mSlider_ProgressBar.FillAmount = resultPercent
  elseif i == 3 and tmpValue >= tableRewardValue then
    self.ui.mSlider_ProgressBar.FillAmount = 1
  end
end
function UIPVPMainPanel:OnClickGradeUpClose(level)
  NetCmdPVPData:ReqGetUpgradeReward(level, function(ret)
    self:OnShowReward(ret)
  end)
end
function UIPVPMainPanel:OnShowReward(ret)
  if ret == ErrorCodeSuc then
    local rewardList = NetCmdPVPData.RewardList
    if not rewardList or rewardList.Count > 0 then
    end
  end
end
function UIPVPMainPanel:UpdateLeftTabList()
  local completedPhaseNum = NetCmdPVPQuestData:GetCompletedPhaseNum()
  local dataList = TableData.listNrtpvpTaskGuideDatas:GetList()
  local totalPhaseNum = dataList[dataList.Count - 1].id
  local systemID = SystemList.NrtpvpNewSupplyTime.value__
  if systemID == nil then
    systemID = SystemList.Nrtpvp
  end
  if AccountNetCmdHandler:CheckSystemIsUnLock(systemID) then
    local redPointVisible = NetCmdPVPQuestData:UpdateRedPoint()
    setactive(self.ui.mNewPlayerRedPoint, 0 < redPointVisible)
    setactive(self.ui.mBtn_NewPlayer.gameObject, true)
    if completedPhaseNum == totalPhaseNum then
      setactive(self.ui.mBtn_NewPlayer.gameObject, false)
    end
  else
    setactive(self.ui.mBtn_NewPlayer.gameObject, false)
  end
  setactive(self.ui.mTrans_TabList.gameObject, true)
  local initLeftTabItem = function(btn, leftTab)
    local tmpTabItem
    tmpTabItem = UIPVPMainLeftTabItem.New()
    tmpTabItem:InitCtrl(btn, leftTab)
    if leftTab == UIPVPGlobal.LeftTabList.Store then
      tmpTabItem:SetRedPoint(NetCmdPVPData:PVPStoreRedPoint() > 0)
      RedPointSystem:GetInstance():UpdateRedPointByType(RedPointConst.PVP)
    end
  end
  initLeftTabItem(self.ui.mBtn_Record, UIPVPGlobal.LeftTabList.Record)
  initLeftTabItem(self.ui.mBtn_RankReward, UIPVPGlobal.LeftTabList.Title)
end
function UIPVPMainPanel:UpdateRightList()
  local tmpRightItem = self.ui.mTrans_RightRankInfo
  setactive(tmpRightItem.gameObject, false)
  local rightList = self.ui.mTrans_RightList.transform
  for i = 2, rightList.childCount - 1 do
    gfdestroy(rightList:GetChild(i))
  end
  local initRightItem = function(hintId, str, isHideLine)
    local tmpObj = instantiate(tmpRightItem)
    setactive(tmpObj.gameObject, true)
    UIUtils.AddListItem(tmpObj, self.ui.mTrans_RightList.gameObject)
    tmpObj.transform:Find("Text_Title"):GetComponent(typeof(CS.UnityEngine.UI.Text)).text = TableData.GetHintById(hintId)
    tmpObj.transform:Find("Text_Num"):GetComponent(typeof(CS.UnityEngine.UI.Text)).text = str
    if isHideLine then
      setactive(tmpObj.transform:Find("ImgLine").gameObject, false)
    end
  end
  local pointsStr = "{0}/{1}"
  local nextLevelData = NetCmdPVPData:GetCurrentSeasonLevelId(self.pvpData.level + 1)
  if nextLevelData == nil then
    pointsStr = self.pvpData.points
  else
    pointsStr = string_format(pointsStr, self.pvpData.points, nextLevelData.LowerLimitPoints)
  end
  initRightItem(120006, pointsStr)
  local maxEffectNum = NetCmdPVPData:GetMaxEffectNum()
  initRightItem(120039, maxEffectNum)
  initRightItem(120008, self.pvpData.seasonAtkWin .. "/" .. self.pvpData.seasonAtkTotal)
  initRightItem(120009, self.pvpData.seasonDefWin .. "/" .. self.pvpData.seasonDefTotal, true)
end
function UIPVPMainPanel:UpdateRedPoint()
  local defenseBtnRedPoint = self.ui.mBtn_BtnDefenseFleet.gameObject.transform:Find("Root/Trans_RedPoint")
  setactive(defenseBtnRedPoint.gameObject, NetCmdPVPData:GetFirstRedPointPvpMap() ~= 0 or NetCmdPVPData:GetBaseMapUpLv() ~= 0 or NetCmdPVPData:GetMapUpLvRedCount() ~= 0)
end
function UIPVPMainPanel:OnHide()
  self.isHide = true
  if self.closeTimer ~= nil then
    self.closeTimer:Stop()
    self.closeTimer = nil
  end
end
function UIPVPMainPanel:OnBackFrom()
end
function UIPVPMainPanel:OnTop()
  self.openFlagIndex = UIUtils.GetIntLocal("PVPMainPanelDetail")
  self:RehreshDetailState(false)
end
