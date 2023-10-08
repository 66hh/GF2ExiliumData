require("UI.Common.UICommonItem")
require("UI.CombatLauncherPanel.Item.UICommonEnemyItem")
require("UI.BattleIndexPanel.Item.UICombatLauncherChallengeItem")
require("UI.StoryChapterPanel.Item.UIHardChapterDetailItem")
require("UI.StoryChapterPanel.UIHardChapterDetailPanelView")
require("UI.UIBasePanel")
UIHardChapterDetailPanel = class("UIHardChapterDetailPanel", UIBasePanel)
UIHardChapterDetailPanel.__index = UIHardChapterDetailPanel
UIHardChapterDetailPanel.LauncherType = {
  Chapter = 1,
  SimCombat = 2,
  Training = 3,
  Weekly = 4,
  Story = 5,
  HideStory = 6
}
function UIHardChapterDetailPanel:ctor()
  UIHardChapterDetailPanel.super.ctor(self)
end
function UIHardChapterDetailPanel.Close()
  UIManager.CloseUI(UIDef.UIHardChapterDetailPanel)
end
function UIHardChapterDetailPanel:OnRelease()
  self.super.OnRelease(self)
end
function UIHardChapterDetailPanel:OnClose()
  if not self.skipClear then
    self.chapterId = 0
    self.storyCount = 0
    self.curDiff = -1
    self.jumpId = 0
    self.lineList = {}
    self.curStage = nil
    NetCmdDungeonData:SetLastUnlockDifficultStoryID(0)
  end
  self.lastUnlockStoryID = nil
  self:RemoveListeners()
  self.skipClear = nil
  self:ReleaseCtrlTable(self.stageItemList, true)
  self.stageItemList = nil
  self:ReleaseCtrlTable(self.dropList, true)
  self:ReleaseCtrlTable(self.firstDropList, true)
  self:ReleaseCtrlTable(self.enemyList, true)
  self:ReleaseCtrlTable(self.challengeList, true)
  self:ReleaseCtrlTable(self.riddleItemList, true)
  self.dropList = nil
  self.firstDropList = nil
  self.enemyList = nil
  self.challengeList = nil
  self.riddleItemList = nil
  for i = 1, #self.stageStrItem do
    gfdestroy(self.stageStrItem[i].mUIRoot.gameObject)
  end
  self.stageStrItem = nil
  self.mView = nil
  self.ui = nil
  self.formatStr = nil
  self.maxStageItem = nil
  self.isFirstInUI = nil
  self.canRaidNum = nil
  self.maxRaidTime = nil
  self.super.OnClose(self)
end
function UIHardChapterDetailPanel:OnInit(root, data, behaviorId)
  self:SetRoot(root)
  self.RedPointType = {
    RedPointConst.ChapterReward
  }
  self.mView = UIHardChapterDetailPanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self:InitBaseData()
  self.formatStr = TableData.GetHintById(193008)
  function self.updateChapter()
    self:UpdateChapterInfo()
  end
  self:AddListeners()
  self:AddBtnListener()
  if data and type(data) == "userdata" then
    if data.Length == 2 then
      if data[1] > 0 then
        self.chapterId = TableData.listDifficultyStoryDatas:GetDataById(data[1]).chapter
        self.jumpId = data[1]
      else
        local storyData
        if 0 < data[0] then
          storyData = NetCmdDungeonData:GetCurrentDifficultStoryByChapterID(data[0])
          self.chapterId = storyData.chapter
          self.jumpId = storyData.id
        end
      end
    elseif data.Length == 1 and 0 < data[0] then
      self.chapterId = data[0]
    end
  elseif data and type(data) == "number" then
    self.chapterId = tonumber(data)
  end
  self.chapterData = TableData.listDifficultyChapterDatas:GetDataById(self.chapterId)
  self.ui.mText_TitleName.text = self.chapterData.name.str
  self.ui.mText_ChapterNum.text = self.chapterData.num
  if self.curDiff == nil or self.curDiff == -1 then
    self.curDiff = self.chapterData.type
  end
  self.recordStoryId = self.chapterId ~= self.recordChapterId and 0 or self.recordStoryId
  self.recordChapterId = self.chapterId
  setactive(self.ui.mTrans_TextList, false)
  self.ui.mAnimator_RaidBtn = self.ui.mBtn_Raid.transform:GetComponent(typeof(CS.UnityEngine.Animator))
end
function UIHardChapterDetailPanel:InitBaseData()
  self.chapterId = 0
  self.storyCount = 0
  self.jumpId = 0
  self.curDiff = -1
  self.stageItemList = {}
  self.lineList = {}
  self.curStage = nil
  local tbNum = TableData.GlobalSystemData.DifficultyStageSweepsTimes
  local totalNum = 0 < tbNum and tbNum or 99
  self.maxRaidTime = totalNum
  if 0 < tbNum then
    self.maxRaidTime = totalNum - NetCmdSimulateBattleData.storyTotalRaidNum
  end
  self.dropList = {}
  self.firstDropList = {}
  self.enemyList = {}
  self.challengeList = {}
  self.riddleItemList = {}
  self.stageStrItem = {}
  if self.targetListOn == nil then
    self.targetListOn = true
  end
  if self.enemyListOn == nil then
    self.enemyListOn = true
  end
  if self.dropListOn == nil then
    self.dropListOn = true
  end
  if self.firstDropListOn == nil then
    self.firstDropListOn = true
  end
  if self.riddleItemListOn == nil then
    self.riddleItemListOn = true
  end
  if self.winTargetOn == nil then
    self.winTargetOn = true
  end
end
function UIHardChapterDetailPanel.OnClickGuide()
  UIManager.OpenUIByParam(UIDef.UISysGuideWindow, {1})
end
function UIHardChapterDetailPanel.ClearUIRecordData()
  UIHardChapterDetailPanel.recordStoryId = 0
  UIHardChapterDetailPanel.recordChapterId = 0
end
function UIHardChapterDetailPanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    self:OnBtnGoClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Enemy.gameObject).onClick = function()
    self:OnEnemyClick(not self.enemyListOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Target.gameObject).onClick = function()
    self:OnTargetClick(not self.targetListOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Drop.gameObject).onClick = function()
    self:OnDropClick(not self.dropListOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_FirstDrop.gameObject).onClick = function()
    self:OnFirstDropClick(not self.firstDropListOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_RiddleItem.gameObject).onClick = function()
    self:OnRiddleItemClick(not self.riddleItemListOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIHardChapterDetailPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Description.gameObject).onClick = function()
    self:OnClickAnalysis()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChapterReward.gameObject).onClick = function()
    self:OnClickChapterReward()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_WinTarget.gameObject).onClick = function()
    self:OnWinTargetClick(not self.winTargetOn)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Guide.gameObject).onClick = self.OnClickGuide
  UIUtils.GetButtonListener(self.ui.mBtn_Raid.gameObject).onClick = function()
    if self.isFinishChallenge == false then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(103078))
    else
      local maxNum = math.min(self.maxRaidTime, self.canRaidNum)
      if maxNum <= 0 then
        local hint = TableData.GetHintById(601)
        CS.PopupMessageManager.PopupString(hint)
        return
      end
      local data = {}
      for i, v in pairs(self.difficultyStoryData.sweeps_cost) do
        data.costItemId = i
        data.costItemNum = v
      end
      data.chapterId = self.difficultyStoryData.id
      data.maxSweepsNum = maxNum
      local showData = UIUtils.GetKVSortItemTable(self.storyData.sweeps_reward)
      data.rewardItemList = showData
      function data.raidCallBack(raidTime, callback)
        NetCmdSimulateBattleData:SendDifficultStoryRaid(data.chapterId, raidTime, callback)
      end
      function data.raidEndCallback()
        self:ReFreshPanel()
      end
      if not TipsManager.CheckStaminaIsEnoughOnly(data.costItemNum) then
        TipsManager.ShowBuyStamina()
        return
      end
      UIManager.OpenUIByParam(UIDef.UIRaidDialogV3, data)
    end
  end
end
function UIHardChapterDetailPanel:AddListeners()
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.updateChapter)
  function self.loadingEndFunc()
    self:SetVisible(false)
    self:SetVisible(true)
  end
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.loadingEndFunc)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.ChapterReward)
  local f = function()
    self:UpdateStaminaInfo()
  end
  self:AddMessageListener(CS.GF2.Message.ModelDataEvent.StaminaUpdate, f)
  self:AddMessageListener(CS.GF2.Message.CampaignEvent.ResInfoUpdate, f)
end
function UIHardChapterDetailPanel:RemoveListeners()
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.updateChapter)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.OnLoadingEnd, self.loadingEndFunc)
  self.loadingEndFunc = nil
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.ChapterReward)
end
function UIHardChapterDetailPanel:OnTop()
end
function UIHardChapterDetailPanel:OnShowStart()
  self:ReFreshPanel()
end
function UIHardChapterDetailPanel:OnBackFrom()
  self:ReFreshPanel()
end
function UIHardChapterDetailPanel:OnShowFinish()
end
function UIHardChapterDetailPanel:OnHide()
end
function UIHardChapterDetailPanel:ReFreshPanel()
  if self.chapterId then
    self.unlockStoryId = NetCmdSimulateBattleData:GetDifficultUnlockInfo(self.chapterId)
    self:UpdateStoryStageItem()
    self:UpdateRewardInfo()
    self.lastUnlockStoryID = NetCmdDungeonData.lastUnlockStoryID
    if self.lastUnlockStoryID > 0 and self.lastUnlockStoryID ~= self.maxStageItem.difficultyStoryData.id then
      self:DelayCall(0.7, function()
        local d = TableData.listDifficultyStoryDatas:GetDataById(self.lastUnlockStoryID)
        if d.key_item.Count > 0 then
          local dataList = {}
          for i, v in pairs(d.key_item) do
            local item = {}
            item.ItemId = i
            item.ItemNum = v
            item.Relate = 0
            table.insert(dataList, item)
          end
          UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {dataList})
        end
        NetCmdDungeonData:SetLastUnlockDifficultStoryID(self.maxStageItem.difficultyStoryData.id)
      end)
    end
  end
end
function UIHardChapterDetailPanel:OnClickChapterReward()
  local t = {}
  t.chapterId = self.chapterId
  t.isDifficult = true
  UIManager.OpenUIByParam(UIDef.UIChapterRewardPanel, t)
end
function UIHardChapterDetailPanel:UpdateHideStage()
  if NetCmdDungeonData:NeedOpenHideStage(self.chapterId) then
    MessageBoxPanel.ShowSingleType(TableData.GetHintById(610))
  end
end
function UIHardChapterDetailPanel:UpdateStoryStageItem()
  local storyListData = TableData.GetDifficultStorysByChapterID(self.chapterId)
  self.storyCount = storyListData.Count
  for i = 1, #self.stageItemList do
    self.stageItemList[i]:SetData(nil, false)
  end
  local list = {}
  for i = 0, storyListData.Count - 1 do
    table.insert(list, storyListData[i])
  end
  table.sort(list, function(a, b)
    return a.id < b.id
  end)
  self.maxStageItem = nil
  for i = 1, #list do
    local item
    if i > #self.stageItemList then
      item = UIHardChapterDetailItem.New()
      item:InitCtrl(self.ui.mTrans_LevelList)
      UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
        self:OnStoryClick(item)
      end
      table.insert(self.stageItemList, item)
    else
      item = self.stageItemList[i]
    end
    if 0 < self.unlockStoryId and self.unlockStoryId >= list[i].id then
      item.hasAnalysis = true
    end
    item:SetData(list[i])
    item:SetIsCurrentStage(false)
    item:SetIsLastStory(i == #list)
    if self.jumpId and item.difficultyStoryData.id == self.jumpId then
      self.curStage = item
      self.jumpId = nil
      self.isFirstInUI = false
    end
  end
  for _, item in ipairs(self.stageItemList) do
    if item.difficultyStoryData and 0 < item.difficultyStoryData.pre_id then
      local preStory = self:GetStoryItemId(item.difficultyStoryData.pre_id)
      if preStory then
        item.preStory = preStory
        preStory.nextStory = item
        if item.isUnlock == false and item.preStory and item.preStory.isUnlock == true and self.maxStageItem == nil then
          self.maxStageItem = item.preStory
        end
      end
    end
  end
  if self.maxStageItem == nil then
    local count = #self.stageItemList
    self.maxStageItem = self.stageItemList[count]
  end
  if self.isFirstInUI ~= false then
    self:OnStoryClick(self.maxStageItem)
    self.isFirstInUI = false
  else
    self:OnStoryClick(self.curStage)
  end
  if self.maxStageItem then
    self.maxStageItem:SetIsCurrentStage(true)
  end
  local collectNum = 0
  local unlockID = self.unlockStoryId
  if self.unlockStoryId == 0 then
    unlockID = self.stageItemList[1].difficultyStoryData.id
  end
  local d = TableData.listDifficultyStoryDatas:GetDataById(unlockID)
  collectNum = d.parse
  self.ui.mText_StageCollectNum.text = collectNum .. "%"
end
function UIHardChapterDetailPanel:OnStoryClick(item)
  if item == nil then
    return
  end
  local needAni = self.curStage and self.curStage.difficultyStoryData.id ~= item.difficultyStoryData.id
  if self.curStage ~= nil then
    self.curStage:SetSelected(false)
  end
  local stageData = TableData.GetStageData(item.difficultyStoryData.id)
  if stageData ~= nil then
    local record = NetCmdStageRecordData:GetStageRecordById(stageData.id)
    self:UpdateAnalysisInfoPanel(item, stageData)
    self:ShowStageInfo(record, item.difficultyStoryData, stageData)
    self:UpdateRaidInfo()
    item:SetSelected(true)
    self.curStage = item
    if needAni == true then
      self.ui.mAnimator_Root:SetTrigger("GrpContent_FadeIn")
      self.ui.mAnimator_Root:SetTrigger("GrpRight_FadeIn")
      self.ui.mScrollRect_DetailsList.verticalNormalizedPosition = 1
      self:OnWinTargetClick(true)
      self:OnEnemyClick(true)
      self:OnTargetClick(true)
      self:OnDropClick(true)
      self:OnFirstDropClick(true)
      self:OnRiddleItemClick(true)
    end
    self.ui.mAnimator_Root:SetBool("Btn_Description_Bool", self.canAnalysis == 1 and self.hasAnalysis == false)
  end
end
function UIHardChapterDetailPanel:UpdateRewardInfo()
  self:UpdateRewardState()
end
function UIHardChapterDetailPanel:UpdateRewardState()
  local canReceive = NetCmdDungeonData:UpdateDifficultChapterRewardRedPoint(self.chapterId) > 0
  setactive(self.ui.mTrans_RewardRedPoint, canReceive)
  local star = NetCmdDungeonData:GetCurStarsByDifficultChapterID(self.chapterId)
  local rewardList = self.chapterData.chapter_reward_value
  local count = rewardList.Count
  local rewardNum = rewardList[count - 1]
  self.ui.mText_RewardNum.text = string_format(TableData.GetHintById(194001), star, rewardNum)
end
function UIHardChapterDetailPanel:ShowStageInfo(stageRecord, storyData, stageData)
  local isCanBattle = NetCmdDungeonData:IsUnLockDifficultStory(storyData.id) and self.hasAnalysis == true
  self:InitChapterData(stageData, stageRecord, storyData, isCanBattle)
end
function UIHardChapterDetailPanel:UpdateAnalysisInfoPanel(item, stageData)
  for i = 1, #self.stageStrItem do
    local item = self.stageStrItem[i]
    setactive(item.mUIRoot, false)
  end
  self.difficultyStoryData = item.difficultyStoryData
  local maxAnalysisNum = item.difficultyStoryData.unlock_num
  local analysisNum = 0
  if self.unlockStoryId >= self.difficultyStoryData.id or self.difficultyStoryData.unlock == false then
    analysisNum = item.difficultyStoryData.unlock_num
  end
  self.ui.mText_Record.text = string_format(self.formatStr, analysisNum, maxAnalysisNum)
  local str = ""
  if 0 < analysisNum then
    local idList = self.difficultyStoryData.unlock_content
    for i = 0, idList.Count - 1 do
      local tbID = idList[i]
      local informationData = TableData.listInformationDetailCsDatas:GetDataById(tbID)
      local index = i + 1
      if self.stageStrItem[index] == nil then
        local go = instantiate(self.ui.mTrans_TextList, self.ui.mTrans_TextList.parent)
        local t = {}
        t = UIUtils.GetUIBindTable(go)
        t.mUIRoot = go.transform
        self.stageStrItem[index] = t
      end
      local item = self.stageStrItem[index]
      setactive(item.mUIRoot, true)
      item.mText_Title.text = informationData.title.str
      item.mTextFit_Details.text = informationData.text.str
    end
  end
  setactive(self.ui.mTrans_DetailsList, 0 < analysisNum)
  local preID = item.difficultyStoryData.pre_id
  local preData
  if 0 < preID then
    preData = TableData.listDifficultyStoryDatas:GetDataById(preID)
  end
  self.canAnalysis = 0
  self.hasAnalysis = 0 < analysisNum
  if self.hasAnalysis == false then
    if preData and preData.unlock and preID > self.unlockStoryId then
      self.canAnalysis = -1
    else
      self.canAnalysis = 1
    end
    for i, v in pairs(item.difficultyStoryData.unlock_item) do
      self.ui.mImg_AnalysisItem.sprite = IconUtils.GetItemIconSprite(i)
      if self.canAnalysis > -1 then
        local itemNum = NetCmdItemData:GetNetItemCount(i)
        if v > itemNum then
          self.costItemData = TableData.GetItemData(i)
          self.canAnalysis = 0
        end
      end
    end
  end
  setactive(self.ui.mBtn_Description, self.canAnalysis > -1 and self.hasAnalysis == false)
  setactive(self.ui.mTrans_AnalysisDesc, self.hasAnalysis == false)
  if self.canAnalysis == -1 then
    self.ui.mText_LockedDesc.text = TableData.GetHintById(193012)
  else
    self.ui.mText_LockedDesc.text = TableData.GetHintById(193003)
  end
  setactive(self.ui.mTrans_AnalysisRedPoint, self.canAnalysis == 1)
end
function UIHardChapterDetailPanel:UpdateRaidInfo()
  local canRaid = self.difficultyStoryData.sweeps_open
  setactive(self.ui.mBtn_Raid, canRaid == true)
  self.canRaidNum = 0
  if canRaid then
    local storySweepNum = 0 < self.difficultyStoryData.sweeps_num and self.difficultyStoryData.sweeps_num or 99
    local todayStoryRaidTime = NetCmdSimulateBattleData:GetDifficultStoryRaidTime(self.difficultyStoryData.id)
    local raidNum = storySweepNum
    if 0 < self.difficultyStoryData.sweeps_num then
      raidNum = storySweepNum - todayStoryRaidTime
    end
    self.canRaidNum = raidNum
    setactive(self.ui.mTrans_Challenge, self.canRaidNum <= 0 and 0 >= self.maxRaidTime)
  end
  if self.isFinishChallenge ~= true or self.canRaidNum <= 0 then
  end
  local canClickRaid = canRaid == true and self.canRaidNum > 0 and 0 < self.maxRaidTime
  local needShowRaid = true
  if canRaid then
    needShowRaid = canClickRaid
  end
  setactive(self.ui.mTrans_Challenge, self.canBattle == true and canClickRaid == false and self.isFinishChallenge == true)
  setactive(self.ui.mTrans_Action, self.canBattle and (needShowRaid or self.isFinishChallenge == false))
  setactive(self.ui.mTrans_Locked, self.canBattle == false)
  self.ui.mAnimator_RaidBtn:SetBool("Lock", self.isFinishChallenge == false)
  if self.isFirst == false then
    self:UpdateRaidDropItemList()
  end
  setactive(self.ui.mTrans_RiddleItemList, self.isFirst == false)
end
function UIHardChapterDetailPanel:OnClickAnalysis()
  local preID = self.difficultyStoryData.pre_id
  local preStageHasComplete = true
  if 0 < preID then
    preStageHasComplete = NetCmdDungeonData:CheckStageHasComplete(preID)
  end
  if self.canAnalysis == 0 then
    CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(225), self.costItemData.name.str))
    return
  elseif self.canAnalysis == -1 or preStageHasComplete == false then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(200001))
    return
  end
  local t = {}
  t.storyData = self.difficultyStoryData
  t.isLast = self.curStage.isLast
  function t.callBack()
    self:ReFreshPanel()
    self.ui.mAnimator_Root:SetTrigger("GrpRight_FadeIn")
    self.ui.mAnimator_Root:SetTrigger("GrpContent_Analysis_FadeIn")
  end
  local callBack = function()
    UIManager.OpenUIByParam(UIDef.UIBatHardAnalysisDialog, t)
  end
  NetCmdSimulateBattleData:SendAnalysisStory(self.difficultyStoryData.id, callBack())
end
function UIHardChapterDetailPanel.OpenReceivePanel()
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
    nil,
    nil,
    nil,
    true
  })
end
function UIHardChapterDetailPanel:UpdateChapterInfo()
  for _, item in ipairs(self.stageItemList) do
    item:RefreshStage()
  end
  self:UpdateRedPoint()
  self:UpdateRewardState()
end
function UIHardChapterDetailPanel:GetStoryItemId(id)
  for i = 1, #self.stageItemList do
    local item = self.stageItemList[i]
    if item.difficultyStoryData ~= nil and item.difficultyStoryData.id == id then
      return item
    end
  end
end
function UIHardChapterDetailPanel:OnRecover()
  self:ReFreshPanel()
end
function UIHardChapterDetailPanel:OnSave()
  self.skipClear = true
  NetCmdDungeonData:SetLastUnlockDifficultStoryID(self.maxStageItem.difficultyStoryData.id)
end
function UIHardChapterDetailPanel:InitChapterData(stageData, stageRecord, storyData, isCanBattle)
  if storyData.type == GlobalConfig.StoryType.Hide then
    self.type = UIHardChapterDetailPanel.LauncherType.HideStory
  elseif storyData.type == GlobalConfig.StoryType.Story then
    self.type = UIHardChapterDetailPanel.LauncherType.Story
  else
    self.type = UIHardChapterDetailPanel.LauncherType.Chapter
  end
  self.storyData = storyData
  self:InitData(stageData, stageRecord, isCanBattle)
  self:UpdatePanel()
end
function UIHardChapterDetailPanel:InitData(stageData, stageRecord, isCanBattle)
  self.stageData = stageData
  self.stageRecord = stageRecord
  self.canBattle = isCanBattle
  self.isFirst = self.stageData.first_reward.Count > 0 and 0 >= self.stageRecord.first_pass_time
  self.stageConfig = TableData.GetStageConfigData(self.stageData.stage_config)
  if 0 < self.stageData.cost_item then
    self.costItemNum = NetCmdItemData:GetItemCountById(self.stageData.cost_item)
  else
    self.costItemNum = 0
  end
end
function UIHardChapterDetailPanel:UpdatePanel()
  self.ui.mText_StageName.text = self.stageData.name.str
  self.ui.mText_StoryNum.text = self.storyData.code.str
  if self.stageData.recommanded_ce > 0 then
    self.ui.mText_StageLvNum.text = string_format(TableData.GetHintById(103086), self.stageData.recommanded_ce)
  else
    self.ui.mText_StageLvNum.text = string_format(TableData.GetHintById(803), self.stageData.recommanded_playerlevel)
  end
  local firstRewardShow = 0 < self.stageData.more_drop_view_list.Count and self:CheckHasExtraDrop()
  local rewardShow = 0 < self.stageData.normal_drop_view_list.Count + self.stageData.exp + self.stageData.weapon_exp
  setactive(self.ui.mTrans_EnemyContent, self.type ~= UIHardChapterDetailPanel.LauncherType.Story)
  setactive(self.ui.mTrans_EnemyList, self.type ~= UIHardChapterDetailPanel.LauncherType.Story)
  setactive(self.ui.mTrans_ChallengeList, self.type ~= UIHardChapterDetailPanel.LauncherType.Story and self.type ~= UIHardChapterDetailPanel.LauncherType.Training and self.type ~= UIHardChapterDetailPanel.LauncherType.HideStory)
  setactive(self.ui.mTrans_FirstDropContent, firstRewardShow or self.isFirst)
  setactive(self.ui.mTrans_FirstDropList, self.firstDropListOn)
  setactive(self.ui.mTrans_DropContent, rewardShow)
  setactive(self.ui.mTrans_DropList, 0 < self.stageData.normal_drop_view_list.Count and self.dropListOn)
  if self.storyData and self.storyData.type == GlobalConfig.StoryType.StoryBattle then
    setactive(self.ui.mTrans_ChallengeContent, false)
  else
    setactive(self.ui.mTrans_ChallengeContent, 0 < self.stageData.challenge_list.Count)
    if 0 < self.stageData.challenge_list.Count then
      self:OnTargetClick(self.targetListOn)
    end
  end
  self:OnRiddleItemClick(self.riddleItemListOn)
  self:OnWinTargetClick(self.winTargetOn)
  self:OnEnemyClick(self.enemyListOn)
  self:OnDropClick(self.dropListOn)
  self:OnFirstDropClick(self.firstDropListOn)
  self:UpdateWinTarget()
  self:UpdateChallengeList()
  self:UpdateEnemyList()
  self:UpdateDropItemList()
  self:UpdateStaminaInfo()
end
function UIHardChapterDetailPanel:UpdateStaminaInfo()
  if self.stageData.cost_item > 0 then
    self.costItemNum = NetCmdItemData:GetItemCountById(self.stageData.cost_item)
  else
    self.costItemNum = 0
  end
  if self.StaminaCostPercent == nil then
    local costItem
    if 0 >= self.stageRecord.first_pass_time and 0 < self.stageData.first_cost_item then
      costItem = self.stageData.first_cost_item
      self.stamincost = self.stageData.first_stamina_cost
    else
      costItem = self.stageData.cost_item
      self.stamincost = self.stageData.stamina_cost
    end
    if costItem ~= 0 then
      self.costItemNum = NetCmdItemData:GetItemCountById(costItem)
    end
    setactive(self.ui.mTrans_Stamina, 0 < costItem and 0 < self.stamincost)
    if 0 < costItem then
      self.costItemNum = NetCmdItemData:GetItemCountById(costItem)
      setactive(self.ui.mTrans_Stamina, 0 < costItem and 0 < self.stamincost)
      if 0 < costItem then
        self.ui.mImage_StaminaIcon.sprite = IconUtils.GetItemIconSprite(costItem)
        self.ui.mText_StaminaCost.text = self.stamincost
        self.ui.mText_StaminaCost.color = self.costItemNum < self.stamincost and ColorUtils.RedColor or ColorUtils.BlackColor
      end
    end
  else
    self.stamincost = math.floor(self.stageData.stamina_cost * self.StaminaCostPercent)
    setactive(self.ui.mTrans_Stamina, self.stageData.cost_item > 0 and 0 < self.stamincost)
    if self.stageData.cost_item > 0 then
      self.ui.mImage_StaminaIcon.sprite = IconUtils.GetItemIconSprite(self.stageData.cost_item)
      self.ui.mText_StaminaCost.text = self.stamincost
      self.ui.mText_StaminaCost.color = self.costItemNum < self.stamincost and ColorUtils.RedColor or ColorUtils.BlackColor
    end
  end
end
function UIHardChapterDetailPanel:UpdateWinTarget()
  local showStr = self.stageData.goal.str
  self.ui.mText_WinTarget.text = showStr
  setactive(self.ui.mTrans_WinTarget, self.stageData.goal_show and self.stageRecord.first_pass_time <= 0)
  setactive(self.ui.mTrans_WinContent, 0 < string.len(showStr))
end
function UIHardChapterDetailPanel:UpdateChallengeList()
  for _, challenge in ipairs(self.challengeList) do
    challenge:SetData(nil)
  end
  local BitAND = function(a, b)
    local p, c = 1, 0
    while 0 < a and 0 < b do
      local ra, rb = a % 2, b % 2
      if 1 < ra + rb then
        c = c + p
      end
      a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
  end
  local complete_challenge = {}
  local bitFlag = self.stageRecord.complete_challenge
  self.isFinishChallenge = true
  for i = 0, self.stageData.challenge_list.Count - 1 do
    if 0 < BitAND(bitFlag, 1 << i) then
      complete_challenge[i] = true
    else
      complete_challenge[i] = false
    end
  end
  for i = 0, self.stageData.challenge_list.Count - 1 do
    local item = self.challengeList[i + 1]
    local challenge_id = self.stageData.challenge_list[i]
    if item == nil then
      item = UICombatLauncherChallengeItem.New()
      item:InitCtrl(self.ui.mTrans_ChallengeList.transform)
      table.insert(self.challengeList, item)
    end
    local isFinish = complete_challenge[i] or false
    if isFinish == false then
      self.isFinishChallenge = false
    end
    item:SetData(challenge_id, isFinish)
  end
end
function UIHardChapterDetailPanel:UpdateEnemyList()
  for _, enemy in ipairs(self.enemyList) do
    enemy:SetData(nil)
  end
  if self.stageConfig ~= nil then
    local config = self.stageConfig
    local sorted = TableData.GetSortedEnemyData(config.enemies)
    for i = 0, sorted.Count - 1 do
      do
        local enemyId = sorted[i]
        local enemyData = TableData.GetEnemyData(enemyId)
        local item = self.enemyList[i + 1]
        if item == nil then
          item = UICommonEnemyItem.New()
          item:InitCtrl(self.ui.mTrans_EnemyList)
          table.insert(self.enemyList, item)
        end
        item:SetData(enemyData, self.stageData.stage_class)
        UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
          self:OnClickEnemy(enemyId)
        end
      end
    end
  end
end
function UIHardChapterDetailPanel:GetItemSortNew(list)
  local itemIdList = {}
  if list then
    for _, v in pairs(list) do
      table.insert(itemIdList, v)
    end
    table.sort(itemIdList, function(a, b)
      local data1 = TableData.listItemDatas:GetDataById(a.item_id)
      local data2 = TableData.listItemDatas:GetDataById(b.item_id)
      local typeOrder1 = self:GetItemTypeOrder(data1.type)
      local typeOrder2 = self:GetItemTypeOrder(data2.type)
      if data1.rank == data2.rank then
        return data1.id > data2.id
      end
      return data1.rank > data2.rank
    end)
  end
  return itemIdList
end
function UIHardChapterDetailPanel:CheckHasExtraDrop()
  if self.ExtraDropItemId ~= 0 and self.ExtraDropItemId ~= nil then
    local ItemData = NetCmdItemData:GetItemCmdData(self.ExtraDropItemId)
    local ItemNum = 0
    if ItemData ~= nil then
      return 0 < ItemData.Num
    end
  end
  return false
end
function UIHardChapterDetailPanel:UpdateDropItemList()
  local dropList = {}
  local firstDropList = {}
  local analysisItemID = {}
  if self.storyData.next_id > 0 then
    local storyData = TableData.listDifficultyStoryDatas:GetDataById(self.storyData.next_id)
    for i, v in pairs(storyData.unlock_item) do
      analysisItemID[i] = v
    end
  end
  if self.isFirst then
    local prizes = self.stageData.first_reward
    local itemList = self:GetItemSort(prizes)
    for _, value in ipairs(itemList) do
      table.insert(dropList, {
        item_id = value,
        item_num = prizes[value],
        isFirst = true
      })
    end
  end
  local normalDropList = self.stageData.normal_drop_view_list
  if 0 < normalDropList.Count then
    local itemList = self:GetItemSort(normalDropList)
    for _, value in ipairs(itemList) do
      table.insert(dropList, {
        item_id = value,
        item_num = normalDropList[value],
        isFirst = false
      })
    end
  end
  local hasExtra = self:CheckHasExtraDrop()
  if hasExtra then
    local moreDropList = self.stageData.more_drop_view_list
    if 0 < moreDropList.Count then
      local itemList = self:GetItemSort(moreDropList)
      for _, value in ipairs(itemList) do
        local num = moreDropList[value]
        table.insert(dropList, {
          item_id = value,
          item_num = num,
          isFirst = true,
          isExtra = true
        })
      end
    end
  end
  if self.isFirst and 0 < self.stageData.exp_first then
    table.insert(dropList, {
      item_id = 200,
      item_num = self.stageData.exp_first,
      isFirst = true
    })
  elseif 0 < self.stageData.exp then
    table.insert(dropList, {
      item_id = 200,
      item_num = self.stageData.exp,
      isFirst = false
    })
  end
  if self.isFirst and 0 < self.stageData.gun_exp_first then
  elseif 0 < self.stageData.gun_exp then
  end
  if self.isFirst and 0 < self.stageData.weapon_exp_first then
    table.insert(dropList, {
      item_id = 231,
      item_num = self.stageData.weapon_exp_first,
      isFirst = true
    })
  elseif 0 < self.stageData.weapon_exp then
    table.insert(dropList, {
      item_id = 231,
      item_num = self.stageData.weapon_exp,
      isFirst = false
    })
  end
  local sortedDropList = self:GetItemSortNew(dropList)
  local index = 1
  for i, dropItem in ipairs(sortedDropList) do
    local itemId = dropItem.item_id
    local itemData = TableData.GetItemData(itemId)
    if itemData ~= nil and analysisItemID[itemId] == nil then
      if self.dropList[index] == nil then
        local item1 = self:GetAppropriateItem(dropItem.isFirst)
        table.insert(self.dropList, item1)
      end
      local item = self.dropList[index]
      self:SetItemData(itemData, dropItem.item_num, item)
      item:SetFirstDrop(false)
      local isExtra = false
      local itemData = TableData.GetItemData(dropItem.item_id)
      if itemData.type ~= GlobalConfig.ItemType.Weapon then
        item:SetExtraIconVisible(isExtra or hasExtra and dropItem.isFirst and not self.isFirst)
      end
      index = index + 1
    else
    end
  end
  index = 1
  for i, dropItem in ipairs(firstDropList) do
    local itemId = dropItem.item_id
    local itemData = TableData.GetItemData(itemId)
    if itemData ~= nil and analysisItemID[itemId] == nil then
      if self.firstDropList[index] == nil then
        local item1 = self:GetAppropriateItem(dropItem.item_id, dropItem.item_num, dropItem.isFirst)
        table.insert(self.firstDropList, item1)
      end
      local item = self.firstDropList[index]
      self:SetItemData(itemData, dropItem.item_num, item)
      index = index + 1
    else
    end
  end
end
function UIHardChapterDetailPanel:UpdateRaidDropItemList()
  local index = 1
  local showData = UIUtils.GetKVSortItemTable(self.storyData.sweeps_reward)
  for _, v in ipairs(showData) do
    local itemId = v.id
    local itemNum = v.num
    local itemData = TableData.GetItemData(itemId)
    if self.riddleItemList[index] == nil then
      local itemView = UICommonItem.New()
      itemView:InitCtrl(self.ui.mTrans_RiddleItemContent)
      self.riddleItemList[index] = itemView
    end
    local item = self.riddleItemList[index]
    item:SetItemData(itemData.id, itemNum, nil, false)
    index = index + 1
  end
  setactive(self.ui.mTrans_RiddleItemList, self.storyData.sweeps_reward.Key.Count > 0)
end
function UIHardChapterDetailPanel:GetItemSort(prizes)
  return UIUtils.SortStageNormalDrop(prizes)
end
function UIHardChapterDetailPanel:GetItemTypeOrder(type)
  return UIUtils.GetItemTypeOrder(type)
end
function UIHardChapterDetailPanel:GetAppropriateItem(isFirst)
  local itemView = UICommonItem.New()
  if isFirst then
    itemView:InitCtrl(self.ui.mTrans_FirstDropList)
  else
    itemView:InitCtrl(self.ui.mTrans_DropList)
  end
  return itemView
end
function UIHardChapterDetailPanel:SetItemData(itemData, itemNum, InfoItem)
  local disableRaycaster = function()
    if self.raycaster then
      self.raycaster.enabled = false
    end
  end
  if itemData.type == GlobalConfig.ItemType.Weapon then
    InfoItem:SetData(itemData.args[0], 1, disableRaycaster, true)
  else
    InfoItem:SetItemData(itemData.id, itemNum, nil, false, nil, nil, disableRaycaster)
  end
end
function UIHardChapterDetailPanel:OnWinTargetClick(isOn)
  self.winTargetOn = isOn
  setactive(self.ui.mTrans_WinContent, self.winTargetOn)
  self.ui.mAnimator_WinTarget:SetBool("Selected", self.winTargetOn)
end
function UIHardChapterDetailPanel:OnEnemyClick(isOn)
  self.enemyListOn = isOn
  setactive(self.ui.mTrans_EnemyList, self.enemyListOn)
  self.ui.mAnimator_Enemy:SetBool("Selected", self.enemyListOn)
end
function UIHardChapterDetailPanel:OnTargetClick(isOn)
  self.targetListOn = isOn
  setactive(self.ui.mTrans_ChallengeList, self.targetListOn)
  self.ui.mAnimator_Target:SetBool("Selected", self.targetListOn)
end
function UIHardChapterDetailPanel:OnDropClick(isOn)
  self.dropListOn = isOn
  setactive(self.ui.mTrans_DropList, self.dropListOn)
  self.ui.mAnimator_Drop:SetBool("Selected", self.dropListOn)
end
function UIHardChapterDetailPanel:OnFirstDropClick(isOn)
  self.firstDropListOn = isOn
  setactive(self.ui.mTrans_FirstDropList, self.firstDropListOn)
  self.ui.mAnimator_FirstDrop:SetBool("Selected", self.firstDropListOn)
end
function UIHardChapterDetailPanel:OnRiddleItemClick(isOn)
  self.riddleItemListOn = isOn
  setactive(self.ui.mTrans_RiddleItemContent, self.riddleItemListOn)
  self.ui.mAnimator_RiddleItem:SetBool("Selected", self.riddleItemListOn)
end
function UIHardChapterDetailPanel:OnBtnGoClick()
  if self.isFirst then
    for item, count in pairs(self.stageData.first_reward) do
      if TipsManager.CheckItemIsOverflowAndStop(item, count) then
        return
      end
    end
  end
  local normalDropList = self.stageData.normal_drop_view_list
  if normalDropList.Count > 0 then
    local itemList = self:GetItemSort(normalDropList)
    for _, value in ipairs(itemList) do
      if TipsManager.CheckItemIsOverflowAndStop(value) then
        return
      end
    end
  end
  if self.StaminaCostPercent == nil and not TipsManager.CheckTicketIsEnough(1, self.TicketItemId) then
    return
  end
  if not TipsManager.CheckStaminaIsEnough2(self.stamincost) then
    return
  end
  self:StartBattle()
end
function UIHardChapterDetailPanel:OnClickEnemy(enemyId)
  local enemyData = TableData.GetEnemyData(enemyId)
  CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, self.stageData.stage_class + enemyData.add_level)
end
function UIHardChapterDetailPanel:StartBattle()
  SceneSys:OpenBattleSceneForChapter(self.stageData, self.stageRecord, self.storyData and self.storyData.id or 0)
end
