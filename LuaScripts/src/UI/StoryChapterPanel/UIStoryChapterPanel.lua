require("UI.BattleIndexPanel.UIBattleDetailDialog")
require("UI.StoryChapterPanel.Item.UIStageLineItem")
require("UI.StoryChapterPanel.Item.UIStoryChapterPlotListItem")
require("UI.StoryChapterPanel.Item.UIBranchChapterListItem")
require("UI.StoryChapterPanel.Item.UIStoryChapterListItem")
require("UI.ChapterPanel.UIChapterGlobal")
require("UI.StoryChapterPanel.UIStoryChapterPanelView")
require("UI.UIBasePanel")
UIStoryChapterPanel = class("UIStoryChapterPanel", UIBasePanel)
UIStoryChapterPanel.__index = UIStoryChapterPanel
UIStoryChapterPanel.chapterId = 0
UIStoryChapterPanel.normalChapterId = 0
UIStoryChapterPanel.storyCount = 0
UIStoryChapterPanel.jumpId = 0
UIStoryChapterPanel.jumpNotOpenId = 0
UIStoryChapterPanel.stageItemList = {}
UIStoryChapterPanel.lineList = {}
UIStoryChapterPanel.curStage = nil
UIStoryChapterPanel.ChapterRedPointKey = "_ChapterNewUnlockRedPointKey_"
function UIStoryChapterPanel:ctor(csPanel)
  UIStoryChapterPanel.super.ctor(self)
  self.mCSPanel = csPanel
end
function UIStoryChapterPanel.Close()
  UIManager.CloseUI(UIDef.UIChapterPanel)
end
function UIStoryChapterPanel:OnSave()
  UIChapterGlobal:RecordChapterId(self.chapterId)
  if self.curStage ~= nil and (self.curStage.storyData.type == GlobalConfig.StoryType.Branch or self.curStage.storyData.type == GlobalConfig.StoryType.Normal) then
    NetCmdDungeonData.lastUnfinishedStory = self.curStage.storyData
    NetCmdDungeonData:RecordLastUnfinishedStoryPass()
  end
  self.skipClear = true
  self:OnRelease()
end
function UIStoryChapterPanel:OnRelease()
  self.stageItemList = {}
end
function UIStoryChapterPanel:OnClose()
  if not self.skipClear then
    self.recordChapterId = 0
    self.chapterId = 0
    self.normalChapterId = 0
    self.storyCount = 0
    self.jumpId = 0
    self.jumpNotOpenId = 0
    self.lineList = {}
  end
  if self.behaviorId == 1 then
    UIChapterGlobal:RecordChapterId(nil)
  end
  self.isReadyToStartTutorial = true
  self.curStage = nil
  self.lineUpdate = false
  self.scrollReset = false
  self.skipClear = nil
  self:RemoveListeners()
end
function UIStoryChapterPanel:OnInit(root, data, behaviorId)
  self.behaviorId = behaviorId
  UIStoryChapterPanel.super.SetRoot(UIStoryChapterPanel, root)
  UIStoryChapterPanel.RedPointType = {
    RedPointConst.ChapterReward
  }
  UIStoryChapterPanel.mView = UIStoryChapterPanelView.New()
  self.ui = {}
  UIStoryChapterPanel.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    MessageSys:SendMessage(UIEvent.StoryCloseDetail, nil)
    GlobalConfig.IsOpenStagePanelByJumpUI = false
    UIStoryChapterPanel.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_CloseDetail.gameObject).onClick = function()
    MessageSys:SendMessage(UIEvent.StoryCloseDetail, nil)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    MessageSys:SendMessage(UIEvent.StoryCloseDetail, nil)
    self.jumpId = 0
    self.jumpNotOpenId = 0
    self.recordChapterId = 0
    UIChapterGlobal:RecordChapterId(nil)
    GlobalConfig.IsOpenStagePanelByJumpUI = false
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChapterReward.gameObject).onClick = function()
    UIStoryChapterPanel:OnClickChapterReward()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    UIStoryChapterPanel:OnClickChapterReward()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ViewAVG.gameObject).onClick = function()
    UIStoryChapterPanel:OnClickViewAVG()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Guide.gameObject).onClick = self.OnClickGuide
  self:AddListeners()
  self.recordChapterId = UIChapterGlobal:GetRecordChapterId() or 1
  self.isReadyToStartTutorial = true
  self.panelWidth = UISystem.UICanvas.transform.sizeDelta.x
  if data and type(data) == "userdata" then
    if data.Length == 4 then
      if data[2] > 0 then
        self.chapterId = TableData.listStoryDatas:GetDataById(data[2]).chapter
        self.jumpId = data[2]
      else
        local storyData
        if data[1] > 0 then
          storyData = NetCmdDungeonData:GetCurrentStoryByChapterID(data[1], data[3])
        elseif data[1] == 0 then
          storyData = NetCmdDungeonData:GetCurrentStoryByType(data[0], data[3])
        end
        self.chapterId = storyData.chapter
        self.jumpId = storyData.id
      end
    elseif data.Length == 3 then
      if data[2] > 0 then
        self.chapterId = TableData.listStoryDatas:GetDataById(data[2]).chapter
        self.jumpId = data[2]
      else
        local storyData
        if data[1] > 0 then
          storyData = NetCmdDungeonData:GetCurrentStoryByChapterID(data[1])
        elseif data[1] == 0 then
          storyData = NetCmdDungeonData:GetCurrentStoryByType(data[0])
        end
        self.chapterId = storyData.chapter
        self.jumpId = storyData.id
      end
    elseif data.Length == 2 then
      if data[1] > 0 then
        self.chapterId = data[1]
      else
        self.chapterId = NetCmdDungeonData:GetCurrentChapterByType(data[0])
      end
    end
    local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
    if self.curDiff == nil or self.curDiff == -1 then
      self.curDiff = chapterData.type
    end
    self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
    self.recordStoryId = self.chapterId ~= self.recordChapterId and 0 or self.recordStoryId
    self.recordChapterId = self.chapterId
    return
  end
  if data then
    if behaviorId ~= nil and behaviorId ~= 0 then
      local chapterId = 0
      if behaviorId == 6 then
        chapterId = TableData.listStoryDatas:GetDataById(tonumber(data)).chapter
      elseif behaviorId == 1 then
        chapterId = tonumber(data)
      end
      self.chapterId = UIChapterGlobal:GetNormalChapterId(chapterId)
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(chapterId)
      self.jumpId = tonumber(data)
    elseif self.recordChapterId ~= nil and self.recordChapterId > 0 then
      local chapterData = TableData.listChapterDatas:GetDataById(self.recordChapterId)
      self.chapterId = self.recordChapterId
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
    else
      local chapterData = TableData.listChapterDatas:GetDataById(data)
      self.chapterId = tonumber(data)
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
    end
    self.recordStoryId = self.chapterId ~= self.recordChapterId and 0 or self.recordStoryId
    self.recordChapterId = self.chapterId
  end
  PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. self.ChapterRedPointKey .. self.chapterId, 0)
end
function UIStoryChapterPanel.OnClickGuide()
  UIManager.OpenUIByParam(UIDef.UISysGuideWindow, {1})
end
function UIStoryChapterPanel.ClearUIRecordData()
  UIStoryChapterPanel.recordStoryId = 0
  UIStoryChapterPanel.recordChapterId = 0
end
function UIStoryChapterPanel:AddListeners()
  function self.AvgSceneClose()
    local canPopup = UICommonReceivePanel.CheckCanPopup()
    if canPopup then
      gfdebug("[Tutorial] UICommonReceivePanel Set IsReadyToStartTutorial false")
      self.isReadyToStartTutorial = false
      UICommonReceivePanel.OpenWithCheckPopupDownLeftTips(nil, {
        nil,
        nil,
        nil,
        true,
        nil,
        UIBasePanelType.Panel,
        function()
          gfdebug("[Tutorial] UICommonReceivePanel Set IsReadyToStartTutorial true")
          self.isReadyToStartTutorial = true
          setactivewithcheck(self.ui.mTrans_Mask, false)
        end
      })
    else
      setactivewithcheck(self.ui.mTrans_Mask, false)
    end
  end
  function self.UpdateChapterInfo()
    self:UpdateRedPoint()
    self:UpdateLine()
    self:UpdateRewardInfo()
    self:OnClickCloseChapterInfoPanel()
  end
  function self.OpenReceivePanel()
  end
  function self.OnAVGStartShowCallback()
    setactivewithcheck(self.ui.mTrans_Mask, true)
  end
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.UpdateChapterInfo)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.AvgSceneClose, self.AvgSceneClose)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.AVGEvent.AVGFirstDrop, self.OpenReceivePanel)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.AVGEvent.AVGStartShow, self.OnAVGStartShowCallback)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.ChapterReward)
end
function UIStoryChapterPanel:RemoveListeners()
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.UpdateChapterInfo)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.AvgSceneClose, self.AvgSceneClose)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.AVGEvent.AVGFirstDrop, self.OpenReceivePanel)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.AVGEvent.AVGStartShow, self.OnAVGStartShowCallback)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.ChapterReward)
end
function UIStoryChapterPanel:OnRecover()
  self:OnShowStart()
end
function UIStoryChapterPanel:OnShowStart(isResetScroll)
  local chapterData = TableData.listChapterDatas:GetDataById(self.recordChapterId)
  if NetCmdDungeonData.lastUnfinishedStory ~= nil then
    local stageRecord = NetCmdDungeonData:GetCmdStoryData(NetCmdDungeonData.lastUnfinishedStory.id)
    local passed = NetCmdDungeonData.LastUnfinishedStoryIsPassed
    if stageRecord == nil or stageRecord.first_pass_time <= 0 or passed then
      if NetCmdDungeonData.lastUnfinishedStory.type ~= GlobalConfig.StoryType.Story then
        self.jumpNotOpenId = NetCmdDungeonData.lastUnfinishedStory.id
        self.scrollReset = false
      end
    else
      for i = 0, NetCmdDungeonData.lastUnfinishedStory.next_id.Count - 1 do
        local nextId = NetCmdDungeonData.lastUnfinishedStory.next_id[i]
        if NetCmdDungeonData.lastUnfinishedStory ~= nil then
          local storyData = TableData.listStoryDatas:GetDataById(tonumber(nextId))
          if storyData then
            local preFinished = true
            for j = 0, storyData.pre_id.Count - 1 do
              local prevId = storyData.pre_id[i]
              local preStoryData = TableData.listStoryDatas:GetDataById(tonumber(prevId))
              if preStoryData then
                local record = NetCmdStageRecordData:GetStageRecordById(preStoryData.stage_id)
                if record == nil or record.first_pass_time <= 0 then
                  preFinished = false
                end
              end
            end
            if preFinished then
              self.chapterId = storyData.chapter
              self.jumpNotOpenId = nextId
              self.scrollReset = false
              NetCmdDungeonData.lastUnfinishedStory = nil
            end
          end
        end
      end
      if NetCmdDungeonData.lastUnfinishedStory ~= nil then
        self.jumpNotOpenId = NetCmdDungeonData.lastUnfinishedStory.id
        self.scrollReset = false
        NetCmdDungeonData.lastUnfinishedStory = nil
      end
    end
  end
  if UIStoryChapterPanel.chapterId then
    UIChapterGlobal:RecordChapterId(self.chapterId)
    UIStoryChapterPanel:UpdateChapterBG()
    UIStoryChapterPanel:UpdateViewAVGBtn()
    UIStoryChapterPanel:UpdateHideStage()
    UIStoryChapterPanel:UpdateStoryStageItem()
    UIStoryChapterPanel:UpdateRewardInfo()
    UIStoryChapterPanel:UpdateChapterSwitch()
    UIStoryChapterPanel:UpdateLine()
    if isResetScroll ~= false then
      UIStoryChapterPanel:ResetScroll()
    end
    UIStoryChapterPanel:OnSwitchTab()
  end
end
function UIStoryChapterPanel:OnBackFrom()
  self:OnShowStart()
end
function UIStoryChapterPanel:OnTop()
  UIStoryChapterPanel:UpdateRewardInfo()
end
function UIStoryChapterPanel:UpdateHideStage()
  if NetCmdDungeonData:NeedOpenHideStage(self.chapterId) then
    MessageBoxPanel.ShowSingleType(TableData.GetHintById(610))
  end
end
function UIStoryChapterPanel:UpdateStoryStageItem()
  if self.scrollReset then
    for _, item in pairs(self.stageItemList) do
      if item.storyData then
        item:UpdateItem()
      end
    end
    return
  end
  local storyListData = TableData.GetStorysByChapterID(self.chapterId, false)
  local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
  local isUnlockHide = NetCmdDungeonData:IsUnlockHideStory(self.chapterId)
  self.storyCount = storyListData.Count
  local lastData = storyListData[0]
  local firstData = storyListData[0]
  for i = 0, storyListData.Count - 1 do
    if not (storyListData[i].type ~= GlobalConfig.StoryType.Hide or isUnlockHide) then
      break
    end
    if storyListData[i].mSfxPos.x > lastData.mSfxPos.x then
      lastData = storyListData[i]
    end
    if storyListData[i].mSfxPos.x < firstData.mSfxPos.x then
      firstData = storyListData[i]
    end
  end
  self:UpdateCombatContent(firstData, lastData)
  self.ui.mText_ChapterNum.text = string.format("-", chapterData.id)
  self.ui.mText_ChapterS.text = string.format(string_format(TableData.GetHintById(615), "-"), chapterData.id)
  self.ui.mText_ChapterName.text = chapterData.name.str
  for _, item in pairs(self.stageItemList) do
    item:SetData(nil, false)
  end
  local normalList = {}
  local branchList = {}
  local storyList = {}
  local hideList = {}
  for i = 0, storyListData.Count - 1 do
    if storyListData[i].type == GlobalConfig.StoryType.Normal then
      table.insert(normalList, storyListData[i])
    elseif storyListData[i].type == GlobalConfig.StoryType.StoryBattle then
      table.insert(normalList, storyListData[i])
    elseif storyListData[i].type == GlobalConfig.StoryType.Branch then
      table.insert(branchList, storyListData[i])
    elseif storyListData[i].type == GlobalConfig.StoryType.Story then
      table.insert(storyList, storyListData[i])
    elseif storyListData[i].type == GlobalConfig.StoryType.Hide then
      table.insert(hideList, storyListData[i])
    end
  end
  table.sort(storyList, function(a, b)
    if a.type == b.type then
      return a.id < b.id
    else
      return a.type < b.type
    end
  end)
  local delta = TableData.GlobalConfigData.SelectedStoryPosition * self.panelWidth
  for i = 1, #normalList do
    do
      local item
      local id = GlobalConfig.StoryType.Normal * 100 + i
      if self.stageItemList[id] == nil then
        item = UIStoryChapterListItem.New()
        item:InitCtrl(self.ui.mTrans_CombatList)
        self.stageItemList[id] = item
      else
        item = self.stageItemList[id]
      end
      UIUtils.GetButtonListener(item.ui.mBtn_Stage.gameObject).onClick = function()
        self:OnStoryClick(item)
      end
      item:SetData(normalList[i])
      item:UpdateStagePos(delta)
    end
  end
  for i = 1, #branchList do
    do
      local item
      local id = GlobalConfig.StoryType.Branch * 100 + i
      if self.stageItemList[id] == nil then
        item = UIBranchChapterListItem.New()
        item:InitCtrl(self.ui.mTrans_CombatList)
        self.stageItemList[id] = item
      else
        item = self.stageItemList[id]
      end
      UIUtils.GetButtonListener(item.ui.mBtn_Stage.gameObject).onClick = function()
        self:OnStoryClick(item)
      end
      item:SetData(branchList[i])
      item:UpdateStagePos(delta)
    end
  end
  for i = 1, #storyList do
    do
      local item
      local id = GlobalConfig.StoryType.Story * 100 + i
      if self.stageItemList[id] == nil then
        item = UIStoryChapterPlotListItem.New()
        item:InitCtrl(self.ui.mTrans_CombatList)
        self.stageItemList[id] = item
      else
        item = self.stageItemList[id]
      end
      UIUtils.GetButtonListener(item.ui.mBtn_Stage.gameObject).onClick = function()
        self:OnStoryClick(item)
      end
      item:SetData(storyList[i])
      item:UpdateStagePos(delta)
    end
  end
  for i = 1, #hideList do
    do
      local item
      local id = GlobalConfig.StoryType.Hide * 100 + i
      if self.stageItemList[id] == nil then
        item = UIBranchChapterListItem.New()
        item:InitCtrl(self.ui.mTrans_CombatList)
        self.stageItemList[id] = item
      else
        item = self.stageItemList[id]
      end
      UIUtils.GetButtonListener(item.ui.mBtn_Stage.gameObject).onClick = function()
        self:OnStoryClick(item)
      end
      item:SetData(hideList[i])
      item:UpdateStagePos(delta)
    end
  end
  for _, item in pairs(self.stageItemList) do
    if item.storyData and 0 < item.storyData.pre_id.Count then
      for i = 0, item.storyData.pre_id.Count - 1 do
        local preStory = self:GetStoryItemId(item.storyData.pre_id[i])
        if preStory then
          item.preStory = preStory
          if item.storyData.type == GlobalConfig.StoryType.Branch and (preStory.storyData.type == GlobalConfig.StoryType.Normal or preStory.storyData.type == GlobalConfig.StoryType.Story) then
            preStory.nextBranchStory = item
          else
            preStory.nextStory = item
          end
          if preStory.mUIRoot.transform:GetSiblingIndex() > item.mUIRoot.transform:GetSiblingIndex() then
            item.mUIRoot.transform:SetSiblingIndex(preStory.mUIRoot.transform:GetSiblingIndex() + 1)
          end
        end
      end
    end
  end
end
function UIStoryChapterPanel:IsReadyToStartTutorial()
  gfdebug("[Tutorial] UICommonReceivePanel Get IsReadyToStartTutorial: " .. tostring(self.isReadyToStartTutorial))
  return self.isReadyToStartTutorial
end
function UIStoryChapterPanel:OnStoryClick(item, needAni, hideDetails)
  needAni = needAni == nil and true or needAni
  local stageData = TableData.GetStageData(item.storyData.stage_id)
  if stageData ~= nil then
    local record = NetCmdStageRecordData:GetStageRecordById(stageData.id)
    if not hideDetails then
      self:ShowStageInfo(record, item.storyData, stageData)
      self:ScrollMoveToMid(-item.mUIRoot.transform.localPosition.x, needAni, true)
      item:SetSelected(true)
      self.curStage = item
    else
      self:ScrollMoveToMid(-item.mUIRoot.transform.localPosition.x, needAni, true)
    end
  end
end
function UIStoryChapterPanel:MoveToNext()
  if self.curStage.storyData.next_id.Count > 0 then
    local nextId = self.curStage.storyData.next_id[0]
    if nextId ~= nil then
      self:OnStoryClick(self:GetStoryItemId(nextId), nil, true)
    end
  end
end
function UIStoryChapterPanel:UpdateRewardInfo()
  local storyCount = NetCmdDungeonData:GetCanChallengeStoryList(self.chapterId).Count
  local stars = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterId)
  self.ui.mText_RewardNum.text = stars .. "/" .. storyCount * UIChapterGlobal.MaxChallengeNum
  self.ui.mText_RewardBubbleNum.text = stars
  self.ui.mText_AllNum.text = "/" .. storyCount * UIChapterGlobal.MaxChallengeNum
  self:UpdateRewardState()
end
function UIStoryChapterPanel:UpdateRewardState()
  local canReceive = NetCmdDungeonData:UpdateChatperRewardRedPoint(self.chapterId) > 0
  local phase = NetCmdDungeonData:GetCannotGetPhaseByChapterID(self.chapterId)
  local rewardCount = NetCmdDungeonData:GetChapterRewardCount(self.chapterId)
  setactive(self.ui.mTrans_Received, phase < 0)
  setactive(self.ui.mTrans_Reward, phase == 0)
  setactive(self.ui.mTrans_Bubble, 0 < phase)
  if 0 < phase then
    local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
    local chapterReward = chapterData.chapter_reward
    local strList = string.split(chapterReward, "|")
    setactive(self.ui.mTrans_RedPoint, canReceive)
    local state = NetCmdDungeonData:GetCurStateByChapterID(self.chapterId, phase)
    local count = chapterData.chapter_reward_value[phase - 1]
    local star = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterId)
    self.ui.mText_RewardText.text = state == 0 and TableData.GetHintReplaceById(103098, count - star) or TableData.GetHintById(103099)
    for i = 1, rewardCount do
      if phase == i then
        local rewardList = {}
        local ss = string.split(strList[i], ",")
        for _, v in ipairs(ss) do
          local s = string.split(v, ":")
          local item = {}
          item.itemId = tonumber(s[1])
          item.itemNum = tonumber(s[2])
          table.insert(rewardList, item)
        end
        for _, value in ipairs(rewardList) do
          local key = value.itemId
          if key == chapterData.chapter_reward_show[i] then
            local itemData = TableData.GetItemData(key)
            self.ui.mImg_RewardIcon.sprite = IconUtils.GetItemIconSprite(key)
            self.ui.mImg_QualityCor.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
          end
        end
      end
    end
  else
    setactive(self.ui.mTrans_RewardRedPoint, canReceive)
  end
end
function UIStoryChapterPanel:OnSwitchTab()
  if self.mCSPanel.ShowType ~= 3 then
    local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
    if chapterData.id == 2 then
      MessageSys:SendMessage(GuideEvent.OnStoryInnerTab2, nil)
    end
  end
end
function UIStoryChapterPanel:UpdateLine()
  local combatItem = self.ui.mTrans_DetailsList
  if combatItem == nil or self.lineUpdate then
    return
  end
  for _, stage in pairs(self.stageItemList) do
    if stage.lineItem then
      stage.lineItem:EnableLine(false)
    end
    if stage.branchLineItem then
      stage.branchLineItem:EnableLine(false)
    end
  end
  for _, story in pairs(self.stageItemList) do
    if story.storyData ~= nil then
      for i = 0, story.storyData.pre_id.Count - 1 do
        local preStory = self:GetStoryItemId(story.storyData.pre_id[i])
        if preStory then
          if story.storyData.start_point == UIChapterGlobal.StageStartPoint.Right then
            if story.storyData.type == GlobalConfig.StoryType.Branch and (preStory.storyData.type == GlobalConfig.StoryType.Normal or preStory.storyData.type == GlobalConfig.StoryType.Story) then
              local item
              if preStory.branchLineItem then
                item = preStory.branchLineItem
                item:EnableLine(true)
              else
                item = UIStageLineItem.New()
                item:InitCtrl(preStory.ui.mTrans_Root.gameObject)
                preStory.branchLineItem = item
              end
              local temVec1 = preStory.mUIRoot.transform.localPosition
              temVec1.x = temVec1.x + preStory.mUIRoot.transform.sizeDelta.x
              local temVec2 = story.mUIRoot.transform.localPosition
              preStory:SetBranchLine(temVec1, temVec2)
            else
              local item
              if preStory.lineItem then
                item = preStory.lineItem
                item:EnableLine(true)
              else
                item = UIStageLineItem.New()
                item:InitCtrl(preStory.ui.mTrans_Root.gameObject)
                preStory.lineItem = item
              end
              local temVec1 = preStory.mUIRoot.transform.localPosition
              temVec1.x = temVec1.x + preStory.mUIRoot.transform.sizeDelta.x
              local temVec2
              if not story.storyData.hide_point then
                temVec2 = story.mUIRoot.transform.localPosition
              else
                local curStory = story.nextStory
                while curStory.storyData.hide_point do
                  curStory = curStory.nextStory
                end
                temVec2 = curStory.mUIRoot.transform.localPosition
              end
              preStory:SetLine(temVec1, temVec2)
            end
            story:UpdatePoint(story.isUnlock)
          elseif story.storyData.start_point == UIChapterGlobal.StageStartPoint.Top then
          elseif story.storyData.start_point == UIChapterGlobal.StageStartPoint.Bottom then
          end
        end
      end
    end
  end
  self.lineUpdate = true
end
function UIStoryChapterPanel:ShowStageInfo(stageRecord, storyData, stageData)
  UIBattleDetailDialog.OpenByChapterData(UIDef.UIChapterPanel, stageData, stageRecord, storyData, NetCmdDungeonData:IsUnLockStory(storyData.id), function(tempFirst)
    if tempFirst then
      self.lineUpdate = false
      self.scrollReset = false
      self:OnShowStart()
    else
      self.lineUpdate = false
      self:OnShowStart(false)
      UIStoryChapterPanel:OnClickCloseChapterInfoPanel()
    end
  end, true)
end
function UIStoryChapterPanel:OnClickCloseChapterInfoPanel()
  if self.ui.mTrans_DetailsList.localPosition.x ~= 0 then
    local pos = self.ui.mTrans_DetailsList.localPosition
    pos.x = 0
    CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_DetailsList, self.ui.mTrans_DetailsList.localPosition, pos, 0.8, nil, CS.DG.Tweening.Ease.OutCubic)
  end
  for _, item in pairs(self.stageItemList) do
    item:SetSelected(false)
  end
end
function UIStoryChapterPanel:OnClickChapterReward()
  local t = {}
  t.chapterId = self.chapterId
  t.isDifficult = false
  UIManager.OpenUIByParam(UIDef.UIChapterRewardPanel, t)
end
function UIStoryChapterPanel:OnClickViewAVG()
  local story = TableData.GetFirstStoryByChapterID(self.chapterId)
  CS.AVGController.PlayAVG(story.stage_id, 10, function()
    gfdebug("初次点击进入章节")
  end)
end
function UIStoryChapterPanel:UpdateCombatContent(first, last)
  local panelSize = self.panelWidth * TableData.GlobalConfigData.SelectedStoryPosition * 2
  local delta = last.mSfxPos.x - first.mSfxPos.x
  self.ui.mTrans_CombatList.sizeDelta = Vector2(delta + panelSize, 0)
end
function UIStoryChapterPanel:UpdateChapterBG()
  local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
  self.ui.mImage_Bg.sprite = IconUtils.GetChapterBg(chapterData.map_background)
  if not self.ui.mBgScrollHelper.enabled then
    self.ui.mBgScrollHelper.enabled = true
    self.ui.mBgScrollHelper:RefreshPos(true)
  end
end
function UIStoryChapterPanel:UpdateViewAVGBtn()
  local story = TableData.GetFirstStoryByChapterID(self.chapterId)
  local hasAVG = NetCmdDungeonData:HasAVGChapter(story.stage_id)
  setactive(self.ui.mTrans_ViewAVG.gameObject, hasAVG)
end
function UIStoryChapterPanel:GetStoryItemId(id)
  for _, item in pairs(self.stageItemList) do
    if item.storyData ~= nil and item.storyData.id == id then
      return item
    end
  end
end
function UIStoryChapterPanel:ResetScroll()
  if self.ui.mTrans_CombatList == nil or self.scrollReset then
    return
  end
  local offsetX = self.ui.mTrans_CombatList.rect.size.x - self.ui.mTrans_DetailsList.rect.size.x
  local itemX = 0
  self.mOffsetX = offsetX <= 0 and 0 or offsetX
  local curItem
  local canChooseItem = false
  for _, item in pairs(self.stageItemList) do
    if item.storyData ~= nil then
      if 0 < self.jumpId then
        if item.storyData.id == self.jumpId and item.isUnlock then
          curItem = item
          canChooseItem = true
          break
        end
      elseif 0 < self.jumpNotOpenId and item.storyData.id == self.jumpNotOpenId and item.isUnlock then
        curItem = item
        canChooseItem = false
        break
      end
      if UIStoryChapterPanel.recordStoryId ~= nil and UIStoryChapterPanel.recordStoryId ~= 0 then
        if UIStoryChapterPanel.recordStoryId == item.storyData.id then
          curItem = item
        end
      elseif item.isUnlock and (item.storyData.type == GlobalConfig.StoryType.Normal or item.storyData.type == GlobalConfig.StoryType.Story or item.storyData.type == GlobalConfig.StoryType.Hide) and itemX <= item.storyData.mSfxPos.x then
        itemX = item.storyData.mSfxPos.x
        curItem = item
      end
    end
  end
  if curItem then
    if canChooseItem then
      self:OnStoryClick(curItem, false)
    else
      self:ScrollMoveToMid(-curItem.mUIRoot.transform.localPosition.x)
    end
  else
    self.ui.mTrans_DetailsList.anchoredPosition = Vector2(0, 0)
  end
  self.scrollReset = true
  self.jumpId = 0
end
function UIStoryChapterPanel:ScrollMoveToMid(toPosX, needSlide, onClick)
  needSlide = needSlide == true and true or false
  onClick = onClick == true and true or false
  local combatList = self.ui.mTrans_CombatList
  local ratio = TableData.GlobalConfigData.SelectedStoryForceposition
  toPosX = self.panelWidth * (ratio - 0.5) + toPosX
  local toPos = Vector3(toPosX, combatList.localPosition.y, 0)
  local itemX = math.max(combatList.sizeDelta.x, 2325)
  local limitPosRight = itemX - self.panelWidth / 2
  local limitPosLeft = self.panelWidth / 2
  if math.abs(toPosX) > math.abs(limitPosRight) then
    local total = math.abs(toPosX) - math.abs(combatList.localPosition.x)
    local delta1 = math.abs(toPosX) - math.abs(limitPosRight)
    local delta2 = math.abs(limitPosRight) - math.abs(combatList.localPosition.x)
    toPos.x = -limitPosRight
    local deltaPos = self.ui.mTrans_DetailsList.localPosition
    deltaPos.x = -delta1
    if needSlide then
      self.ui.mScrollRect_GrpDetailsList.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Clamped
      CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.4 * (delta2 / total), function()
        CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_DetailsList, self.ui.mTrans_DetailsList.localPosition, deltaPos, 0.8, function()
          self.ui.mScrollRect_GrpDetailsList.movementType = CS.UnityEngine.UI.ScrollRect.MovementType.Elastic
        end, CS.DG.Tweening.Ease.OutCubic)
      end)
    else
      combatList.localPosition = toPos
      if onClick then
        self.ui.mTrans_DetailsList.localPosition = deltaPos
      end
    end
  elseif math.abs(toPosX) < math.abs(limitPosLeft) then
    local total = math.abs(toPosX) - math.abs(combatList.localPosition.x)
    local delta1 = math.abs(toPosX) - math.abs(limitPosLeft)
    local delta2 = math.abs(limitPosLeft) - math.abs(combatList.localPosition.x)
    toPos.x = -limitPosLeft
    local deltaPos = self.ui.mTrans_DetailsList.localPosition
    deltaPos.x = -delta1
    if needSlide then
      CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.4 * (delta2 / total), function()
        CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_DetailsList, self.ui.mTrans_DetailsList.localPosition, deltaPos, 0.8, nil, CS.DG.Tweening.Ease.OutCubic)
      end)
    else
      combatList.localPosition = toPos
      if onClick then
        self.ui.mTrans_DetailsList.localPosition = deltaPos
      end
    end
  elseif needSlide then
    CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.8, nil, CS.DG.Tweening.Ease.OutCubic)
  else
    combatList.localPosition = toPos
  end
end
function UIStoryChapterPanel:UpdateChapterSwitch()
  local data = TableData.listChapterDatas:GetDataById(self.chapterId)
  local lastData = TableData.listChapterDatas:GetDataById(self.chapterId - 1, true)
  local nextData = TableData.listChapterDatas:GetDataById(self.chapterId + 1, true)
  setactive(self.ui.mTrans_PreChapter.gameObject, lastData ~= nil)
  setactive(self.ui.mTrans_NextChapter.gameObject, nextData ~= nil and NetCmdDungeonData:IsUnLockChapter(self.chapterId + 1))
  setactive(self.ui.mTrans_ArrowLeft.gameObject, lastData ~= nil)
  setactive(self.ui.mTrans_ArrowRight.gameObject, nextData ~= nil)
  setactive(self.ui.mTrans_Lock.gameObject, nextData == nil or not NetCmdDungeonData:IsUnLockChapter(self.chapterId + 1))
  if lastData then
    local normalId = UIChapterGlobal:GetNormalChapterId(lastData.id)
    self.ui.mText_PreChapterNum.text = UIChapterGlobal:GetTensDigitNum(normalId)
    UIUtils.GetButtonListener(self.ui.mBtn_PreChapter.gameObject).onClick = function()
      self.chapterId = self.chapterId - 1
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
      UIStoryChapterPanel.recordStoryId = self.chapterId ~= UIStoryChapterPanel.recordChapterId and 0 or UIStoryChapterPanel.recordStoryId
      UIStoryChapterPanel.recordChapterId = self.chapterId
      UIManager.ChangeCacheUIData(UIDef.UIStoryChapterPanel, self.chapterId)
      self.ui.mBgScrollHelper.enabled = false
      self.scrollReset = false
      self.lineUpdate = false
      self.curStage = nil
      self.ui.mAnimator_Root:SetTrigger("Previous")
      self:OnShowStart()
    end
  end
  if nextData and NetCmdDungeonData:IsUnLockChapter(self.chapterId + 1) then
    local normalId = UIChapterGlobal:GetNormalChapterId(nextData.id)
    self.ui.mText_NextChapterNum.text = UIChapterGlobal:GetTensDigitNum(normalId)
    UIUtils.GetButtonListener(self.ui.mBtn_NextChapter.gameObject).onClick = function()
      self.chapterId = self.chapterId + 1
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
      UIStoryChapterPanel.recordStoryId = self.chapterId ~= UIStoryChapterPanel.recordChapterId and 0 or UIStoryChapterPanel.recordStoryId
      UIStoryChapterPanel.recordChapterId = self.chapterId
      UIManager.ChangeCacheUIData(UIDef.UIStoryChapterPanel, self.chapterId)
      self.ui.mBgScrollHelper.enabled = false
      self.scrollReset = false
      self.lineUpdate = false
      self.curStage = nil
      self.ui.mAnimator_Root:SetTrigger("Next")
      self:OnShowStart()
    end
  end
  self.ui.mText_CurrentChapterNum.text = UIChapterGlobal:GetTensDigitNum(self.normalChapterId)
end
