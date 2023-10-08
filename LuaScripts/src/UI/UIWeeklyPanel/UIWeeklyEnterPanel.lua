require("UI.UIBasePanel")
require("UI.SimpleMessageBox.SimpleMessageBoxPanel")
require("UI.UIWeeklyPanel.UIWeeklyFleetPanel")
require("UI.UIWeeklyPanel.UIWeeklyDefine")
require("UI.UIUnitInfoPanel.UIUnitInfoPanel")
UIWeeklyEnterPanel = class("UIWeeklyEnterPanel", UIBasePanel)
UIWeeklyEnterPanel.__index = UIWeeklyEnterPanel
UIWeeklyEnterPanel.mUITeamList = {}
UIWeeklyEnterPanel.mOriCoinColor = nil
function UIWeeklyEnterPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIWeeklyEnterPanel.Close()
  UIManager.CloseUI(UIDef.UIWeeklyEnterPanel)
end
function UIWeeklyEnterPanel:OnInit(root)
  UIWeeklyEnterPanel.super.SetRoot(UIWeeklyEnterPanel, root)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mData = NetCmdSimulateBattleData:GetSimCombatWeeklyData()
  self:RegisterEvent()
  self:RegisterMessage()
  if UIWeeklyEnterPanel.mOriCoinColor == nil then
    UIWeeklyEnterPanel.mOriCoinColor = self.ui.mText_CoinNum.color
  end
  if self.mData:CheckSimWeeklyNeedNewWatch() then
    self.ui.mCanvasGroup_Root.blocksRaycasts = false
  end
  if self.mData:CheckSimWeeklyNeedFirstWatch() then
    self.mData:FirstWatchSimWeekly()
  end
end
function UIWeeklyEnterPanel:OnFadeInFinish()
  if self.mData:CheckSimWeeklyNeedNewWatch() then
    UIManager.OpenUI(UIDef.UIWeeklyNewSeasonDialog)
    self:DelayCall(0.5, function()
      self.ui.mCanvasGroup_Root.blocksRaycasts = true
    end)
  end
end
function UIWeeklyEnterPanel:IsReadyToStartTutorial()
  return not self.mData:CheckSimWeeklyNeedNewWatch()
end
function UIWeeklyEnterPanel:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_SpecialShop.gameObject).onClick = function()
    SceneSwitch:SwitchByID(UIWeeklyDefine.StoryID)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnClickEnterBattle()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Continue.gameObject).onClick = function()
    self:ContinueBattle()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ViewTeam.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.UIWeeklyTeamDetailsDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_CoinRoot.gameObject).onClick = function()
    UITipsPanel.Open(self.costItemData)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpProgress.gameObject).onClick = function()
    if self.mData.currentChallengeLevel <= self.mData.cycleData.max_level then
      UIManager.OpenUIByParam(UIDef.UIWeeklyChallengeProgressDialog, {
        data = self.mData,
        onClose = function(isUIWeeklyUnLockDialog)
          self:OnCloseUIWeeklyUnLockDialog(isUIWeeklyUnLockDialog)
        end
      })
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_UpLevel.gameObject).onClick = function()
    local currentChallengeLevel = self.mData.currentChallengeLevel
    local maxLevel = self.mData.cycleData.max_level
    if currentChallengeLevel >= maxLevel then
      return
    end
    NetCmdSimulateBattleData:ReqSimCombatWeekEnterNextLevel(function()
      UIManager.OpenUIByParam(UIDef.UIWeeklyUnLockDialog, function(isUIWeeklyUnLockDialog)
        self:OnCloseUIWeeklyUnLockDialog(isUIWeeklyUnLockDialog)
      end)
    end)
  end
end
function UIWeeklyEnterPanel:OnCloseUIWeeklyUnLockDialog(isUIWeeklyUnLockDialog)
  self:UpdatePanel()
  if isUIWeeklyUnLockDialog then
    self.ui.mAnimator_Root:SetBool("Refresh", true)
  end
end
function UIWeeklyEnterPanel:RegisterMessage()
  function self.NotOpenTipCheck()
    UIWeeklyDefine.NotOpenTipCheck(self.NotOpenTipCheck)
  end
  MessageSys:AddListener(UIEvent.UserTapScreen, self.NotOpenTipCheck)
  function self.InitFade()
    setactive(self.mUIRoot, false)
    setactive(self.mUIRoot, true)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.InitFade)
end
function UIWeeklyEnterPanel:RemoveAllMessage()
  MessageSys:RemoveListener(UIEvent.UserTapScreen, self.NotOpenTipCheck)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.InitFade)
end
function UIWeeklyEnterPanel:OnShowStart()
  self:UpdatePanel()
end
function UIWeeklyEnterPanel:OnShowFinish()
  local totalCount = self.mData.degreeData.b_id.Count
  local currentStageIndex = self.mData.bStageIndex
  if totalCount <= currentStageIndex then
    self:ShowSettlementPanel()
  end
end
function UIWeeklyEnterPanel:OnRecover()
  self:UpdatePanel()
end
function UIWeeklyEnterPanel:OnRelease()
  if self.mUITeamList then
    for i = 1, #self.mUITeamList do
      self.mUITeamList[i]:Release()
    end
  end
  self:ReleaseCtrlTable(self.mUITeamList, true)
  UIWeeklyEnterPanel.mUITeamList = {}
end
function UIWeeklyEnterPanel:OnClose()
  self:RemoveAllMessage()
  if self.mUITeamList then
    for i = 1, #self.mUITeamList do
      self.mUITeamList[i]:Release()
    end
  end
  self:ReleaseCtrlTable(self.mUITeamList, true)
end
function UIWeeklyEnterPanel:UpdatePanel()
  self.mIsStart = self.mData.isStartB
  self.mMaxTeamCount = self.mData.degreeData.b_id.Length
  self.ui.mText_MaxTeamCount.text = UIUtils.StringFormat("{0:d3}", self.mMaxTeamCount)
  self.ui.mText_Tag.text = self.mData.degreeData.b_boss_en_name.str
  self:UpdateBaseInfo()
  self:UpdateChallenge()
  self:UpdateRight()
  self:UpdateRedPoint()
end
function UIWeeklyEnterPanel:UpdateBaseInfo()
  self.isOpen = NetCmdSimulateBattleData:IsWeeklyOpen()
  if self.isOpen then
    self.ui.mText_Title.text = self.mData.degreeData.name.str
    self.ui.mText_Desc.text = self.mData.degreeData.des.str
    local dataTable = TableDataBase.listTimerDatas:GetDataById(CS.GF2.Data.TimerType.Weekly.value__, true)
    local leftTime = CS.TimeUtils.GetLeftTimeByTimerData(dataTable)
    self.ui.mText_CountDown:StartCountdown(leftTime)
    self.ui.mText_CountDown:AddFinishCallback(function(isEnd)
      if isEnd then
        MessageBoxPanel.ShowSingleType(TableData.GetHintById(180161), function()
          UIManager.JumpToMainPanel()
        end)
      end
    end)
  end
end
function UIWeeklyEnterPanel:UpdateChallenge()
  local currentLevel = self.mData.currentChallengeLevel
  local maxLevel = self.mData.cycleData.max_level
  self.ui.mText_CurrentLevelNum.text = string_format(TableData.GetHintById(108099), currentLevel)
  local receivedCount, maxChallengeQuestCount = NetCmdSimulateBattleData:GetWeeklyQuestCompleteCount(self.mData.degreeData.quest_challenge_type)
  self.ui.mText_CurrentLevelProgress.text = string_format(TableData.GetHintById(180175), receivedCount, maxChallengeQuestCount)
  local fillAmount = 0
  if maxChallengeQuestCount ~= 0 then
    fillAmount = receivedCount / maxChallengeQuestCount
  end
  local maxChallengeLevel = currentLevel >= maxLevel
  setactive(self.ui.mBtn_UpLevel.gameObject, not maxChallengeLevel and maxChallengeQuestCount <= receivedCount)
  setactive(self.ui.mBtn_GrpProgress.gameObject, maxChallengeLevel or receivedCount < maxChallengeQuestCount)
  setactive(self.ui.mText_CurrentLevelProgress, receivedCount < maxChallengeQuestCount)
  setactive(self.ui.mText_LevelComplete, maxChallengeLevel and maxChallengeQuestCount <= receivedCount)
  UIUtils.EnableBtn(self.ui.mBtn_GrpProgress, not maxChallengeLevel or receivedCount < maxChallengeQuestCount)
  if maxChallengeLevel and maxChallengeQuestCount <= receivedCount then
    fillAmount = 0
  end
  self.ui.mImage_ChallengeProgress.fillAmount = fillAmount
end
function UIWeeklyEnterPanel:UpdateRedPoint()
  setactive(self.ui.mTrans_ChallengeRedPoint, NetCmdSimulateBattleData:HasCanReceiveSimWeeklyChallengeQuest(self.mData.degreeData.quest_challenge_type))
end
function UIWeeklyEnterPanel:UpdateRight()
  setactive(self.ui.mBtn_CoinRoot.transform, not self.mIsStart)
  setactive(self.ui.mBtn_ViewTeam.transform, self.mIsStart)
  setactive(self.ui.mBtn_BossInfo.transform, self.mData.degreeData.b_ppt_id > 0)
  setactive(self.ui.mTrans_StartRoot.transform, not self.mIsStart)
  setactive(self.ui.mTrans_ContinueRoot.transform, self.mIsStart)
  self.ui.mText_MaxScore.text = self.mData:GetBMaxPoint()
  setactive(self.ui.mTrans_BLastScoreRoot, self.mIsStart)
  self.ui.mText_BLastScore.text = tostring(self.mData.gameBLastScore)
  local scoreData = self.mData:GetGameBMaxScoreRankData()
  if not scoreData or self.mData.ChallengeTimes == 0 then
    self.ui.mText_RankLevel.text = TableData.GetHintById(108100)
    setactive(self.ui.mTrans_NoLevel, false)
  else
    self.ui.mText_RankLevel.text = scoreData.name.str
    setactive(self.ui.mTrans_NoLevel, true)
  end
  self.ui.mText_HistoryBossScore.text = self.mData:GetBHistoryScore()
  self:UpdateCoinInfo()
  self:UpdateBossInfo()
end
function UIWeeklyEnterPanel:UpdateCoinInfo()
  for k, v in pairs(self.mData.cycleData.b_cost) do
    self.costItemData = TableData.GetItemData(k)
    self.costNum = v
    local totalCount = NetCmdItemData:GetItemCount(self.costItemData.Id)
    if totalCount < self.costNum then
      self.ui.mText_CoinNum.color = ColorUtils.RedColor
    else
      self.ui.mText_CoinNum.color = UIWeeklyEnterPanel.mOriCoinColor
    end
    self.ui.mText_CoinNum.text = tostring(self.costNum)
    self.ui.mImage_CoinImage.sprite = IconUtils.GetItemIconSprite(self.costItemData.Id)
  end
end
function UIWeeklyEnterPanel:UpdateBossInfo()
  local enemyArr = string.split(self.mData.degreeData.b_boss_id, ":")
  local enemyId = tonumber(enemyArr[1])
  local enemyLevel = tonumber(enemyArr[2])
  local enemyData = TableData.GetEnemyData(enemyId)
  self.ui.mText_BossName.text = enemyData.name.str
  local bossIcon = IconUtils.GetAtlasV2("SimCombatWeekly", self.mData.degreeData.b_boss_pic)
  self.ui.mImage_Boss.sprite = bossIcon
  self.ui.mImage_Boss1.sprite = bossIcon
  self.ui.mImage_Tag.sprite = IconUtils.GetAtlasV2("SimCombatWeekly", self.mData.degreeData.b_boss_logo)
  UIUtils.GetButtonListener(self.ui.mBtn_BossInfo.gameObject).onClick = function()
    UIUnitInfoPanel.Open(UIUnitInfoPanel.ShowType.Enemy, enemyId, enemyLevel)
  end
end
function UIWeeklyEnterPanel:InitTeamData()
  self.mTeamList = {}
  local bTeamIds = self.mData.BTeamIds
  local bTeamCount = bTeamIds and bTeamIds.Count or 0
  self.mTotalUseGunCount = 0
  for i = 0, self.mMaxTeamCount - 1 do
    local ids = i < bTeamCount and bTeamIds[i] or nil
    local gunIdList = {}
    if ids then
      for j = 0, ids.Count - 1 do
        table.insert(gunIdList, ids[j])
        self.mTotalUseGunCount = self.mTotalUseGunCount + 1
      end
    end
    table.insert(self.mTeamList, gunIdList)
  end
end
function UIWeeklyEnterPanel:OnClickEnterBattle()
  if self.costNum > NetCmdItemData:GetItemCount(self.costItemData.Id) then
    CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(108059), self.costItemData.Name))
    return
  end
  UIManager.OpenUIByParam(UIDef.UIWeeklyFleetPanel, {
    costNum = self.costNum,
    costId = self.costItemData.Id,
    startBattle = function()
      self:EnterBattle()
    end
  })
end
function UIWeeklyEnterPanel:EnterBattle()
  NetCmdSimulateBattleData:ReqSimCombatWeeklySaveTeamB(function(ret)
    if ret == ErrorCodeSuc then
      NetCmdSimulateBattleData:ReqSimCombatWeekStartB(function(ret1)
        if ret1 == ErrorCodeSuc then
          self:StartBattle()
        end
      end)
    end
  end)
end
function UIWeeklyEnterPanel:ContinueBattle()
  self:StartBattle()
end
function UIWeeklyEnterPanel:StartBattle()
  local stageId = self.mData:GetBStageId()
  local stageData = TableData.listStageDatas:GetDataById(stageId)
  local bId = self.mData.degreeData.b_id[self.mData.bStageIndex]
  SceneSys:OpenBattleSceneForWeeklyB(bId, stageData)
end
function UIWeeklyEnterPanel:OnClickCancel()
  MessageBox.Show(TableData.GetHintById(64), TableData.GetHintById(108113), nil, function()
    self:ShowSettlementPanel()
  end, function()
  end)
end
function UIWeeklyEnterPanel:ShowSettlementPanel()
  UIUtils.EnableGraphicRaycaster(self.mUIRoot, false)
  NetCmdSimulateBattleData:ReqSimCombatWeekRetreatB(function()
    UIUtils.EnableGraphicRaycaster(self.mUIRoot, true)
    if self.mData:IsNewBRank() then
      UIManager.OpenUI(UIDef.UIWeeklyRankPromotionDialog)
    else
      UIManager.OpenUI(UIDef.UIWeeklyModeBSettlementPanel)
    end
  end)
end
function UIWeeklyEnterPanel:OnBackFrom()
  self:UpdatePanel()
end
