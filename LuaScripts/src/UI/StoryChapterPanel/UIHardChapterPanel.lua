require("UI.StoryChapterPanel.UIHardChapterPanelView")
require("UI.UIBasePanel")
UIHardChapterPanel = class("UIHardChapterPanel", UIBasePanel)
UIHardChapterPanel.__index = UIHardChapterPanel
UIHardChapterPanel.chapterId = 0
UIHardChapterPanel.normalChapterId = 0
UIHardChapterPanel.storyCount = 0
UIHardChapterPanel.jumpId = 0
UIHardChapterPanel.curDiff = -1
UIHardChapterPanel.stageItemList = {}
UIHardChapterPanel.lineList = {}
UIHardChapterPanel.curStage = nil
function UIHardChapterPanel:ctor()
  UIHardChapterPanel.super.ctor(self)
end
function UIHardChapterPanel.Close()
  UIManager.CloseUI(UIDef.UIChapterHardPanel)
end
function UIHardChapterPanel:OnRelease()
  UIHardChapterPanel.stageItemList = {}
end
function UIHardChapterPanel:OnClose()
  if not self.skipClear then
    UIHardChapterPanel.chapterId = 0
    UIHardChapterPanel.normalChapterId = 0
    UIHardChapterPanel.storyCount = 0
    UIHardChapterPanel.curDiff = -1
    UIHardChapterPanel.jumpId = 0
    UIHardChapterPanel.lineList = {}
    UIHardChapterPanel.curStage = nil
  end
  UIHardChapterPanel:RemoveListeners()
  self.skipClear = nil
  UIHardChapterPanel.scrollReset = false
end
function UIHardChapterPanel:OnInit(root, data, behaviorId)
  UIHardChapterPanel.super.SetRoot(UIHardChapterPanel, root)
  UIHardChapterPanel.RedPointType = {
    RedPointConst.ChapterReward
  }
  UIHardChapterPanel.mView = UIHardChapterPanelView.New()
  self.ui = {}
  UIHardChapterPanel.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    GlobalConfig.IsOpenStagePanelByJumpUI = false
    UIHardChapterPanel.Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIHardChapterPanel.curDiff = -1
    UIHardChapterPanel.jumpId = 0
    GlobalConfig.IsOpenStagePanelByJumpUI = false
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChapterReward.gameObject).onClick = function()
    UIHardChapterPanel:OnClickChapterReward()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    UIHardChapterPanel:OnClickChapterReward()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Guide.gameObject).onClick = self.OnClickGuide
  function self.updateChapter()
    self:UpdateChapterInfo()
  end
  self:AddListeners()
  if data and type(data) == "userdata" then
    if data.Length == 3 then
      if data[2] > 0 then
        self.chapterId = TableData.listStoryDatas:GetDataById(data[2]).chapter
        self.jumpId = data[2]
      else
        local storyData
        if 0 < data[1] then
          storyData = NetCmdDungeonData:GetCurrentStoryByChapterID(data[1])
        elseif data[1] == 0 then
          storyData = NetCmdDungeonData:GetCurrentStoryByType(data[0])
        end
        self.chapterId = storyData.chapter
        self.jumpId = storyData.id
      end
    elseif data.Length == 2 then
      if 0 < data[1] then
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
      local chatperData = TableData.listChapterDatas:GetDataById(chapterId)
      self.curDiff = chatperData.type
      self.chapterId = chapterId
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(chapterId)
      self.jumpId = tonumber(data)
    else
      local chapterData = TableData.listChapterDatas:GetDataById(data)
      self.chapterId = tonumber(data)
      if self.curDiff == nil or self.curDiff == -1 then
        self.curDiff = chapterData.type
      end
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
    end
    self.recordStoryId = self.chapterId ~= self.recordChapterId and 0 or self.recordStoryId
    self.recordChapterId = self.chapterId
  end
end
function UIHardChapterPanel.OnClickGuide()
  UIManager.OpenUIByParam(UIDef.UISysGuideWindow, {1})
end
function UIHardChapterPanel.ClearUIRecordData()
  UIHardChapterPanel.recordStoryId = 0
  UIHardChapterPanel.recordChapterId = 0
end
function UIHardChapterPanel:AddListeners()
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.updateChapter)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.AVGEvent.AVGFirstDrop, UIHardChapterPanel.OpenReceivePanel)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.ChapterReward)
end
function UIHardChapterPanel:RemoveListeners()
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.updateChapter)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.AVGEvent.AVGFirstDrop, UIHardChapterPanel.OpenReceivePanel)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.ChapterReward)
end
function UIHardChapterPanel:OnTop()
  self:OnShowStart()
end
function UIHardChapterPanel:OnShowStart()
  if UIHardChapterPanel.chapterId then
    UIHardChapterPanel:UpdateChapterBG()
    UIHardChapterPanel:UpdateHideStage()
    UIHardChapterPanel:UpdateStoryStageItem()
    UIHardChapterPanel:UpdateRewardInfo()
    UIHardChapterPanel:UpdateChapterSwitch()
    UIHardChapterPanel:UpdateLine()
    UIHardChapterPanel:ResetScroll()
  end
end
function UIHardChapterPanel:OnClickChapterReward()
  UIManager.OpenUIByParam(UIDef.UIChapterRewardPanel, self.chapterId)
end
function UIHardChapterPanel:UpdateHideStage()
  if NetCmdDungeonData:NeedOpenHideStage(self.chapterId) then
    MessageBoxPanel.ShowSingleType(TableData.GetHintById(610))
  end
end
function UIHardChapterPanel:UpdateStoryStageItem()
  if self.scrollReset then
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
  self.ui.mText_ChapterNum.text = string.format("-", chapterData.id % 100)
  self.ui.mText_ChapterName.text = chapterData.name.str
  for i = 1, #self.stageItemList do
    self.stageItemList[i]:SetData(nil, false)
  end
  local list = {}
  for i = 0, storyListData.Count - 1 do
    table.insert(list, storyListData[i])
  end
  table.sort(list, function(a, b)
    if a.type == b.type then
      return a.id < b.id
    else
      return a.type < b.type
    end
  end)
  local delta = TableData.GlobalConfigData.SelectedStoryPosition * self.ui.mUIRoot.rect.size.x
  local tempItem
  for i = 1, #list do
    do
      local item
      if i > #self.stageItemList then
        item = UIHardChapterListItem.New()
        item:InitCtrl(self.ui.mTrans_CombatList)
        UIUtils.GetButtonListener(item.ui.mBtn_Stage.gameObject).onClick = function()
          self:OnStoryClick(item)
        end
        table.insert(self.stageItemList, item)
      else
        item = self.stageItemList[i]
      end
      item:SetData(list[i])
      item:UpdateStagePos(delta)
    end
  end
  for _, item in ipairs(self.stageItemList) do
    if item.storyData and 0 < item.storyData.pre_id.Count then
      local preStory = self:GetStoryItemId(item.storyData.pre_id[0])
      if preStory then
        item.preStory = preStory
        preStory.nextStory = item
      end
    end
  end
end
function UIHardChapterPanel:OnStoryClick(item, needAni)
  needAni = needAni == nil and true or needAni
  if self.curStage ~= nil then
    if self.curStage.storyData.id == item.storyData.id then
      return
    end
    self.curStage:SetSelected(false)
  end
  local stageData = TableData.GetStageData(item.storyData.stage_id)
  if stageData ~= nil then
    local record = NetCmdStageRecordData:GetStageRecordById(stageData.id)
    self:ShowStageInfo(record, item.storyData, stageData)
    self:ScrollMoveToMid(-item.mUIRoot.transform.localPosition.x, needAni, true)
    item:SetSelected(true)
    self.curStage = item
  end
end
function UIHardChapterPanel:UpdateRewardInfo()
  local storyCount = NetCmdDungeonData:GetCanChallengeStoryList(self.chapterId).Count
  local stars = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterId)
  self.ui.mText_RewardNum.text = stars .. "/" .. storyCount * UIChapterGlobal.MaxChallengeNum
  self.ui.mText_RewardBubbleNum.text = stars .. "/" .. storyCount * UIChapterGlobal.MaxChallengeNum
  self:UpdateRewardState()
end
function UIHardChapterPanel:UpdateRewardState()
  local canReceive = NetCmdDungeonData:UpdateChatperRewardRedPoint(self.chapterId) > 0
  local phase = NetCmdDungeonData:GetCannotGetPhaseByChapterID(self.chapterId)
  setactive(self.ui.mTrans_Received, phase < 0)
  setactive(self.ui.mTrans_Reward, phase == 0)
  setactive(self.ui.mTrans_Bubble, 0 < phase)
  if 0 < phase then
    local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
    setactive(self.ui.mTrans_RedPoint, canReceive)
    local state = NetCmdDungeonData:GetCurStateByChapterID(self.chapterId, phase)
    local count = NetCmdDungeonData:GetCanChallengeStoryList(self.chapterId).Count
    local star = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterId)
    self.ui.mText_RewardText.text = state == 0 and TableData.GetHintReplaceById(103098, phase * count - star) or TableData.GetHintById(103099)
    for i = 1, 3 do
      if phase == i then
        for key, value in pairs(chapterData["chapter_reward_" .. i]) do
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
function UIHardChapterPanel:ShowStageInfo(stageRecord, storyData, stageData)
  UIBattleDetailDialog.OpenByChapterData(UIDef.UIChapterHardPanel, stageData, stageRecord, storyData, NetCmdDungeonData:IsUnLockStory(storyData.id), function()
    UIHardChapterPanel:OnClickCloseChapterInfoPanel()
  end)
end
function UIHardChapterPanel:OnClickCloseChapterInfoPanel()
  if self.ui.mTrans_DetailsList.localPosition.x ~= 0 then
    local pos = self.ui.mTrans_DetailsList.localPosition
    pos.x = 0
    CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_DetailsList, self.ui.mTrans_DetailsList.localPosition, pos, 0.8)
  end
  for i = 1, #self.stageItemList do
    self.stageItemList[i]:SetSelected(false)
  end
  self.curStage = nil
end
function UIHardChapterPanel:OnClickChapterReward()
  UIManager.OpenUIByParam(UIDef.UIChapterRewardPanel, self.chapterId)
end
function UIHardChapterPanel:UpdateCombatContent(first, last)
  local panelSize = self.ui.mUIRoot.rect.size.x * TableData.GlobalConfigData.SelectedStoryPosition * 2
  local delta = last.mSfxPos.x - first.mSfxPos.x
  self.ui.mTrans_CombatList.sizeDelta = Vector2(delta + panelSize, 0)
end
function UIHardChapterPanel:UpdateChapterBG()
  local chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
  self.ui.mImage_Bg.sprite = IconUtils.GetChapterBg(chapterData.map_background)
  if not self.ui.mBgScrollHelper.enabled then
    self.ui.mBgScrollHelper.enabled = true
    self.ui.mBgScrollHelper:RefreshPos(true)
  end
end
function UIHardChapterPanel:UpdateLine()
  local combatItem = self.ui.mTrans_DetailsList
  if combatItem == nil or self.scrollReset then
    return
  end
  for _, stage in ipairs(self.stageItemList) do
    if stage.lineItem then
      stage.lineItem:EnableLine(false)
    end
    if stage.branchLineItem then
      stage.branchLineItem:EnableLine(false)
    end
  end
  for i = 1, #self.stageItemList do
    local story = self.stageItemList[i]
    if story.storyData == nil then
      break
    end
    if story.storyData and story.storyData.pre_id.Count > 0 then
      local preStory = self:GetStoryItemId(story.storyData.pre_id[0])
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
            local temVec2 = story.mUIRoot.transform.localPosition
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
function UIHardChapterPanel.OpenReceivePanel()
  UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
    nil,
    nil,
    nil,
    true
  })
end
function UIHardChapterPanel:UpdateChapterInfo()
  for _, item in ipairs(self.stageItemList) do
    item:RefreshStage()
  end
  self:UpdateRedPoint()
  self:UpdateLine()
  self:UpdateRewardState()
  self:OnClickCloseChapterInfoPanel()
end
function UIHardChapterPanel:GetStoryItemId(id)
  for i = 1, #self.stageItemList do
    local item = self.stageItemList[i]
    if item.storyData ~= nil and item.storyData.id == id then
      return item
    end
  end
end
function UIHardChapterPanel:ResetScroll()
  if self.ui.mTrans_CombatList == nil or self.scrollReset then
    return
  end
  local offsetX = self.ui.mTrans_CombatList.rect.size.x - self.ui.mTrans_DetailsList.rect.size.x
  local itemX = 0
  self.mOffsetX = offsetX <= 0 and 0 or offsetX
  local curItem
  local canChooseItem = false
  for i = 1, #self.stageItemList do
    local item = self.stageItemList[i]
    if item.storyData ~= nil then
      if 0 < self.jumpId and item.storyData.id == self.jumpId and item.isUnlock then
        curItem = item
        canChooseItem = true
        break
      end
      if UIHardChapterPanel.recordStoryId ~= 0 then
        if UIHardChapterPanel.recordStoryId == item.storyData.id then
          curItem = item
        end
      elseif item.isUnlock and item.storyData.type == GlobalConfig.StoryType.Hard and itemX <= item.storyData.mSfxPos.x then
        itemX = item.storyData.mSfxPos.x
        curItem = item
      end
    end
  end
  if curItem then
    if 0 >= self.jumpId then
      self:ScrollMoveToMid(-curItem.mUIRoot.transform.localPosition.x)
    end
    if canChooseItem then
      self:OnStoryClick(curItem, false)
    end
  else
    self.ui.mTrans_DetailsList.anchoredPosition = Vector2(self.mOffsetX / 2, 0)
  end
  self.scrollReset = true
end
function UIHardChapterPanel:PlayListFadeIn()
  setactive(self.ui.mTrans_Mask, true)
  DOTween.DoCanvasFade(self.ui.mTrans_DetailsList, 0, 1, 0.3, 0.3, function()
    setactive(self.ui.mTrans_Mask, false)
  end)
end
function UIHardChapterPanel:ScrollMoveToMid(toPosX, needSlide, onClick)
  needSlide = needSlide == true and true or false
  onClick = onClick == true and true or false
  local combatList = self.ui.mTrans_CombatList
  local ratio = TableData.GlobalConfigData.SelectedStoryForceposition
  toPosX = self.ui.mUIRoot.rect.size.x * (ratio - 0.5) + toPosX
  local toPos = Vector3(toPosX, combatList.localPosition.y, 0)
  local itemX = self.storyCount > 2 and math.max(combatList.sizeDelta.x, 2325) or combatList.sizeDelta.x
  local limitPosRight = itemX - self.ui.mUIRoot.rect.size.x / 2
  local limitPosLeft = self.ui.mUIRoot.rect.size.x / 2
  if math.abs(toPosX) > math.abs(limitPosRight) then
    local total = math.abs(toPosX) - math.abs(combatList.localPosition.x)
    local delta1 = math.abs(toPosX) - math.abs(limitPosRight)
    local delta2 = math.abs(limitPosRight) - math.abs(combatList.localPosition.x)
    toPos.x = -limitPosRight
    local deltaPos = self.ui.mTrans_DetailsList.localPosition
    deltaPos.x = self.storyCount == 1 and -delta1 / 4 or -delta1
    if needSlide then
      CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.4 * (delta2 / total), function()
        if self.storyCount == 1 then
          self.ui.mTrans_DetailsList.localPosition = deltaPos
        else
          CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_DetailsList, self.ui.mTrans_DetailsList.localPosition, deltaPos, 0.8, nil, CS.DG.Tweening.Ease.OutCubic)
        end
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
    deltaPos.x = self.storyCount == 1 and -delta1 / 4 or -delta1
    if needSlide then
      CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.4 * (delta2 / total), function()
        if self.storyCount == 1 then
          self.ui.mTrans_DetailsList.localPosition = deltaPos
        else
          CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_DetailsList, self.ui.mTrans_DetailsList.localPosition, deltaPos, 0.8, nil, CS.DG.Tweening.Ease.OutCubic)
        end
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
function UIHardChapterPanel:UpdateChapterSwitch()
  local data = TableData.listChapterDatas:GetDataById(self.chapterId)
  local lastData = TableData.listChapterDatas:GetDataById(self.chapterId - 1, true)
  local nextData = TableData.listChapterDatas:GetDataById(self.chapterId + 1, true)
  setactive(self.ui.mTrans_PreChapter.gameObject, lastData ~= nil)
  setactive(self.ui.mTrans_NextChapter.gameObject, nextData ~= nil and NetCmdDungeonData:IsUnLockChapter(self.chapterId + 1))
  if lastData then
    local normalId = UIChapterGlobal:GetNormalChapterId(lastData.id)
    self.ui.mText_PreChapterNum.text = UIChapterGlobal:GetTensDigitNum(normalId)
    UIUtils.GetButtonListener(self.ui.mBtn_PreChapter.gameObject).onClick = function()
      self.chapterId = self.chapterId - 1
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterId)
      UIHardChapterPanel.recordStoryId = self.chapterId ~= UIHardChapterPanel.recordChapterId and 0 or UIHardChapterPanel.recordStoryId
      UIHardChapterPanel.recordChapterId = self.chapterId
      UIManager.ChangeCacheUIData(UIDef.UIHardChapterPanel, self.chapterId)
      self.ui.mBgScrollHelper.enabled = false
      self.scrollReset = false
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
      UIHardChapterPanel.recordStoryId = self.chapterId ~= UIHardChapterPanel.recordChapterId and 0 or UIHardChapterPanel.recordStoryId
      UIHardChapterPanel.recordChapterId = self.chapterId
      UIManager.ChangeCacheUIData(UIDef.UIHardChapterPanel, self.chapterId)
      self.ui.mBgScrollHelper.enabled = false
      self.scrollReset = false
      self.ui.mAnimator_Root:SetTrigger("Next")
      self:OnShowStart()
    end
  end
  self.ui.mText_CurrentChapterNum.text = UIChapterGlobal:GetTensDigitNum(self.normalChapterId)
end
function UIHardChapterPanel:OnRecover()
  self:OnShowStart()
end
function UIHardChapterPanel:OnSave()
  self.skipClear = true
  self:OnRelease()
end
