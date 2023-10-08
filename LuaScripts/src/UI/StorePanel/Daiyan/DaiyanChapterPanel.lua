require("UI.UIBasePanel")
require("UI.BattleIndexPanel.UIBattleDetailDialog")
require("UI.StoryChapterPanel.Item.UIStageLineItem")
require("UI.ChapterPanel.UIChapterGlobal")
require("UI.StorePanel.Daiyan.DaiyanChapterListItem")
DaiyanChapterPanel = class("DaiyanChapterPanel", UIBasePanel)
DaiyanChapterPanel.__index = DaiyanChapterPanel
function DaiyanChapterPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function DaiyanChapterPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.normalChapterId = 0
  self.storyCount = 0
  self.jumpId = 0
  self.stageItemList = {}
  self.curStage = nil
  self.scrollReset = false
  self.minItem = nil
  self.minData = nil
end
function DaiyanChapterPanel:OnInit(root, data)
  if data == nil then
    local chapterId = NetCmdThemeData:GetCurrChapterId()
    self.chapterData = TableData.listChapterDatas:GetDataById(chapterId)
  else
    self.chapterData = data.chapterData
  end
  self.curDiff = self.chapterData.type
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.DaiyanChapterPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChapterReward.gameObject).onClick = function()
    self:OnClickChapterReward()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    self:OnClickChapterReward()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_DetailsList.gameObject).onClick = function()
    MessageSys:SendMessage(UIEvent.StoryCloseDetail, nil)
  end
  self:AddListeners()
end
function DaiyanChapterPanel:AddListeners()
  function self.UpdateChapterData()
    self:UpdateRewardInfo()
    self:OnClickCloseChapterInfoPanel()
  end
  function self.OpenReceivePanel()
    self.ui.mCanvasGroup_Root.blocksRaycasts = true
  end
  function self.OnAVGStartShowCallback()
  end
  function self.AvgSceneClose()
    local canPopup = UICommonReceivePanel.CheckCanPopup()
    if canPopup then
      UICommonReceivePanel.OpenWithCheckPopupDownLeftTips(nil, {
        nil,
        nil,
        nil,
        true,
        nil,
        UIBasePanelType.Panel,
        function()
          self.ui.mCanvasGroup_Root.blocksRaycasts = true
        end
      })
    end
  end
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.UpdateChapterData)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.AVGEvent.AVGFirstDrop, self.OpenReceivePanel)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.AVGEvent.AVGStartShow, self.OnAVGStartShowCallback)
  CS.GF2.Message.MessageSys.Instance:AddListener(CS.GF2.Message.UIEvent.AvgSceneClose, self.AvgSceneClose)
end
function DaiyanChapterPanel:RemoveListeners()
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.RefreshChapterInfo, self.UpdateChapterData)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.AVGEvent.AVGFirstDrop, self.OpenReceivePanel)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.UIEvent.AvgSceneClose, self.AvgSceneClose)
  CS.GF2.Message.MessageSys.Instance:RemoveListener(CS.GF2.Message.AVGEvent.AVGStartShow, self.OnAVGStartShowCallback)
end
function DaiyanChapterPanel:OnClickChapterReward()
  local t = {}
  t.chapterId = self.chapterData.id
  t.isDifficult = false
  UIManager.OpenUIByParam(UIDef.UIChapterRewardPanel, t)
end
function DaiyanChapterPanel:OnShowStart()
  self:UpdateData(1)
end
function DaiyanChapterPanel:UpdateData(index)
  NetCmdThemeData:UpdateLevelInfo(self.chapterData.stage_group)
  self:UpdateChapterBG()
  self:UpdateChapterInfo()
  self:UpdateStoryStageItem()
  self:UpdateRewardInfo()
  self:UpdateChapterSwitch()
  if index == 1 then
    self.jumpId = NetCmdThemeData:GetCurrUnLockLevel()
  else
    self.jumpId = NetCmdThemeData:GetCurrResultLevelId()
    if self.jumpId == 0 then
      self.jumpId = NetCmdThemeData:GetCurrUnLockLevel()
    end
  end
  self:ResetScroll()
end
function DaiyanChapterPanel:UpdateChapterBG()
  local chapterData = TableData.listChapterDatas:GetDataById(self.chapterData.id)
  self.ui.mImage_Bg.sprite = IconUtils.GetChapterBg(chapterData.map_background)
  if not self.ui.mBgScrollHelper.enabled then
    self.ui.mBgScrollHelper.enabled = true
    self.ui.mBgScrollHelper:RefreshPos(true)
  end
end
function DaiyanChapterPanel:UpdateChapterInfo()
  self.ui.mText_ChapterName.text = self.chapterData.name.str
  if not self.ui.mBgScrollHelper.enabled then
    self.ui.mBgScrollHelper.enabled = true
    self.ui.mBgScrollHelper:RefreshPos(true)
  end
  local themeaticData = TableDataBase.listPlanDatas:GetDataById(self.chapterData.plan_id)
  if themeaticData and themeaticData.args.Count > 0 then
    if themeaticData.system == 5 then
      local activityEntranceData = TableDataBase.listActivityEntranceDatas:GetDataById(themeaticData.args[0], true)
      if activityEntranceData then
        self.ui.mText_ActivityName.text = activityEntranceData.name.str
      end
    elseif themeaticData.system == 7 then
      local activityData = TableDataBase.listActivityConfigDatas:GetDataById(themeaticData.args[0], true)
      if activityData then
        self.ui.mText_ActivityName.text = activityData.name.str
      end
    end
  end
end
function DaiyanChapterPanel:UpdateRewardInfo()
  if self.chapterData.chapter_reward_value.Count > 0 then
    local stars = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterData.id)
    local totalStar = self.chapterData.chapter_reward_value[self.chapterData.chapter_reward_value.Count - 1]
    self.ui.mText_RewardNum.text = stars .. "/" .. totalStar
    self.ui.mText_RewardBubbleNum.text = stars .. "/" .. totalStar
    self:UpdateRewardState()
  else
    setactive(self.ui.mTrans_Bubble.gameObject, false)
    setactive(self.ui.mTrans_Received, false)
    setactive(self.ui.mTrans_Reward, false)
    setactive(self.ui.mTrans_RewardRedPoint.gameObject, false)
  end
end
function DaiyanChapterPanel:UpdateRewardState()
  local canReceive = NetCmdDungeonData:UpdateChatperRewardRedPoint(self.chapterData.id) > 0
  local phase = NetCmdDungeonData:GetCannotGetPhaseByChapterID(self.chapterData.id)
  local rewardCount = NetCmdDungeonData:GetChapterRewardCount(self.chapterData.id)
  setactive(self.ui.mTrans_Received, phase == -1)
  setactive(self.ui.mTrans_Reward, phase == 0)
  setactive(self.ui.mTrans_Bubble, 0 < phase and phase < 4)
  if 0 < phase then
    local strList = string.split(self.chapterData.chapter_reward, "|")
    setactive(self.ui.mTrans_RedPoint.gameObject, canReceive)
    local state = NetCmdDungeonData:GetCurStateByChapterID(self.chapterData.id, phase)
    local count
    if phase > self.chapterData.chapter_reward_value.Count then
      count = 0
    else
      count = self.chapterData.chapter_reward_value[phase - 1]
    end
    local star = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterData.id)
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
          if key == self.chapterData.chapter_reward_show[i] then
            local itemData = TableData.GetItemData(key)
            self.ui.mImg_RewardIcon.sprite = IconUtils.GetItemIconSprite(key)
            self.ui.mImg_QualityCor.color = TableData.GetGlobalGun_Quality_Color2(itemData.rank)
          end
        end
      end
    end
  else
    setactive(self.ui.mTrans_RewardRedPoint.gameObject, canReceive)
  end
end
function DaiyanChapterPanel:UpdateStoryStageItem()
  if self.scrollReset then
    for _, item in pairs(self.stageItemList) do
      if item.storyDataList[_] then
        item:UpdateItem(item.storyDataList[_])
      end
    end
    return
  end
  local storyListData = TableData.GetStorysByChapterID(self.chapterData.id, false, true)
  self.storyCount = storyListData.Count
  local lastData = storyListData[0]
  local firstData = storyListData[0]
  local delta = TableData.GlobalConfigData.SelectedStoryPosition * LuaUtils.GetRectTransformSize(self.mUIRoot.gameObject).x
  local branchSoryDataList = {}
  local storyIdDataList = {}
  for i = 0, storyListData.Count - 1 do
    do
      if storyListData[i].mSfxPos.x > lastData.mSfxPos.x then
        lastData = storyListData[i]
      end
      if storyListData[i].mSfxPos.x < firstData.mSfxPos.x then
        firstData = storyListData[i]
      end
      local item
      local data = storyListData[i]
      if data.type == GlobalConfig.StoryType.Normal or data.type == GlobalConfig.StoryType.Story then
        if self.stageItemList[data.Id] == nil then
          item = DaiyanChapterListItem.New()
          item:InitCtrl(self.ui.mTrans_CombatList)
          self.stageItemList[data.Id] = item
        else
          item = self.stageItemList[data.Id]
        end
        item:SetMainData(self.chapterData, data)
        UIUtils.GetButtonListener(item.itemViewList[data.id].ui.mBtn_Stage.gameObject).onClick = function()
          self:OnStoryClick(item, data, false)
        end
      elseif data.type == GlobalConfig.StoryType.Branch then
        table.insert(branchSoryDataList, data)
      end
      if firstData.id == data.id then
        self.minItem = item
        self.minData = data
      end
      storyIdDataList[data.id] = data
    end
  end
  for i = 1, #branchSoryDataList do
    local branchData = branchSoryDataList[i]
    local item = self.stageItemList[branchData.pre_id[0]]
    local preData = storyIdDataList[branchData.pre_id[0]]
    if preData then
      if item == nil then
        item = self:GetMainItemById(preData.pre_id[0])
      end
      if preData.mSfxPos.y == 0 then
        if 0 < branchData.mSfxPos.y then
          item:SetTopData(self.chapterData, branchData)
        elseif 0 > branchData.mSfxPos.y then
          item:SetBtmData(self.chapterData, branchData)
        end
      elseif 0 < preData.mSfxPos.y then
        if 0 < branchData.mSfxPos.y then
          item:SetTopGroupData(self.chapterData, branchData)
        elseif 0 > branchData.mSfxPos.y then
          item:SetBtmData(self.chapterData, branchData)
        end
      elseif 0 < branchData.mSfxPos.y then
        item:SetTopData(self.chapterData, branchData)
      elseif 0 > branchData.mSfxPos.y then
        item:SetBtmGroupData(self.chapterData, branchData)
      end
      UIUtils.GetButtonListener(item.itemViewList[branchData.id].ui.mBtn_Stage.gameObject).onClick = function()
        self:OnStoryClick(item, branchData, true)
      end
    end
  end
  self:UpdateCombatContent(firstData, lastData)
  self.ui.mText_ChapterName.text = self.chapterData.name.str
  LayoutRebuilder.ForceRebuildLayoutImmediate(self.ui.mTrans_CombatList)
end
function DaiyanChapterPanel:GetMainItemById(preId)
  local mainItem = self.stageItemList[preId]
  while mainItem == nil do
    local data = TableData.listStoryDatas:GetDataById(preId)
    mainItem = self.stageItemList[data.pre_id[0]]
  end
  return mainItem
end
function DaiyanChapterPanel:OnStoryClick(item, data, isBranch, needAni, hideDetails)
  needAni = needAni == nil and true or needAni
  isBranch = isBranch or false
  local stageData = TableData.GetStageData(data.stage_id)
  if stageData ~= nil then
    local record = NetCmdStageRecordData:GetStageRecordById(stageData.id)
    if not hideDetails then
      self:ShowStageInfo(record, item.storyDataList[data.id], stageData)
      local shiftingCount = 0
      if isBranch then
        local mainData = self:GetMainDataById(data.pre_id[0])
        if mainData then
          shiftingCount = data.mSfxPos.x - mainData.mSfxPos.x
        end
      end
      self:ScrollMoveToMid(-(item.mUIRoot.transform.localPosition.x + shiftingCount), needAni, true)
      item:SetSelected(data, true)
      self.curStage = item
    else
      self:ScrollMoveToMid(-item.mUIRoot.transform.localPosition.x, needAni, true)
    end
  end
end
function DaiyanChapterPanel:CleanAllSelected()
  for _, item in pairs(self.stageItemList) do
    item:CleanAllSelected()
  end
end
function DaiyanChapterPanel:GetMainDataById(branchid)
  local mainData = TableData.listStoryDatas:GetDataById(branchid)
  if mainData == nil then
    return
  end
  while mainData.type == 11 do
    mainData = TableData.listStoryDatas:GetDataById(mainData.pre_id[0])
  end
  return mainData
end
function DaiyanChapterPanel:ShowStageInfo(stageRecord, storyData, stageData)
  UIBattleDetailDialog.OpenByChapterData(UIDef.UIChapterPanel, stageData, stageRecord, storyData, NetCmdDungeonData:IsUnLockStory(storyData.id), function(tempFirst)
    if tempFirst then
      self.lineUpdate = false
      self.scrollReset = false
      self:UpdateData(1)
      self.ui.mCanvasGroup_Root.blocksRaycasts = false
    else
      self.lineUpdate = false
      self:UpdateData(1)
      self:OnClickCloseChapterInfoPanel()
    end
  end, true)
end
function DaiyanChapterPanel:OnClickCloseChapterInfoPanel()
  if self.ui.mTrans_DetailsList.localPosition.x ~= 0 then
    local pos = self.ui.mTrans_DetailsList.localPosition
    pos.x = 0
    CS.UITweenManager.PlayLocalPositionTween(self.ui.mTrans_DetailsList, self.ui.mTrans_DetailsList.localPosition, pos, 0.8, nil, CS.DG.Tweening.Ease.OutCubic)
  end
  for _, item in pairs(self.stageItemList) do
    item:CleanAllSelected()
  end
end
function DaiyanChapterPanel:ScrollMoveToMid(toPosX, needSlide, onClick)
  needSlide = needSlide == true and true or false
  onClick = onClick == true and true or false
  local combatList = self.ui.mTrans_CombatList
  local ratio = TableData.GlobalConfigData.SelectedStoryForceposition
  toPosX = LuaUtils.GetRectTransformSize(self.mUIRoot.gameObject).x * (ratio - 0.5) + toPosX
  local toPos = Vector3(toPosX, combatList.localPosition.y, 0)
  local itemX = math.max(combatList.sizeDelta.x, 2325)
  local limitPosRight = itemX - LuaUtils.GetRectTransformSize(self.mUIRoot.gameObject).x / 2
  local limitPosLeft = LuaUtils.GetRectTransformSize(self.mUIRoot.gameObject).x / 2
  if math.abs(toPosX) > math.abs(limitPosRight) then
    local total = math.abs(toPosX) - math.abs(combatList.localPosition.x)
    local delta1 = math.abs(toPosX) - math.abs(limitPosRight)
    local delta2 = math.abs(limitPosRight) - math.abs(combatList.localPosition.x)
    toPos.x = -limitPosRight
    local deltaPos = self.ui.mTrans_DetailsList.localPosition
    deltaPos.x = -delta1
    local contentSize = LuaUtils.GetRectTransformSize(combatList.gameObject)
    local detailSize = LuaUtils.GetRectTransformSize(self.ui.mTrans_DetailsList.gameObject)
    if toPos.x > 0 then
      toPos.x = 0
    end
    local offset = 0 - contentSize.x - detailSize.x
    if offset > toPos.x then
      toPos.x = offset
    end
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
    local contentSize = LuaUtils.GetRectTransformSize(combatList.gameObject)
    local detailSize = LuaUtils.GetRectTransformSize(self.ui.mTrans_DetailsList.gameObject)
    if toPos.x > 0 then
      toPos.x = 0
    end
    local offset = 0 - contentSize.x - detailSize.x
    if offset > toPos.x then
      toPos.x = offset
    end
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
  else
    local contentSize = LuaUtils.GetRectTransformSize(combatList.gameObject)
    local detailSize = LuaUtils.GetRectTransformSize(self.ui.mTrans_DetailsList.gameObject)
    if toPos.x > 0 then
      toPos.x = 0
    end
    local offset = 0 - contentSize.x - detailSize.x
    if offset > toPos.x then
      toPos.x = offset
    end
    if needSlide then
      CS.UITweenManager.PlayLocalPositionTween(combatList, combatList.localPosition, toPos, 0.8, nil, CS.DG.Tweening.Ease.OutCubic)
    else
      combatList.localPosition = toPos
    end
  end
end
function DaiyanChapterPanel:UpdateCombatContent(first, last)
  local panelSize = LuaUtils.GetRectTransformSize(self.mUIRoot.gameObject).x * TableData.GlobalConfigData.SelectedStoryPosition * 2
  local delta = last.mSfxPos.x - first.mSfxPos.x
  self.ui.mTrans_CombatList.sizeDelta = Vector2(delta + panelSize, 0)
end
function DaiyanChapterPanel:GetStoryItemId(id)
  for _, item in pairs(self.stageItemList) do
    if item.storyDataList[_] ~= nil and item.storyDataList[_].id == id then
      return item
    end
  end
end
function DaiyanChapterPanel:ResetScroll()
  if self.ui.mTrans_CombatList == nil or self.scrollReset then
    return
  end
  local offsetX = LuaUtils.GetRectTransformSize(self.ui.mTrans_CombatList.gameObject).x - LuaUtils.GetRectTransformSize(self.ui.mTrans_DetailsList.gameObject).x
  local itemX = 0
  self.mOffsetX = offsetX <= 0 and 0 or offsetX
  local curItem, currData
  for _, item in pairs(self.stageItemList) do
    local storyData = item.storyDataList[_]
    if storyData ~= nil then
      if 0 < self.jumpId and storyData.id == self.jumpId and item.itemViewList[_].isUnlock then
        curItem = item
        currData = storyData
        break
      end
      if self.recordStoryId ~= 0 then
        if self.recordStoryId == storyData.id then
          curItem = item
          currData = storyData
        end
      elseif item.isUnlock and (storyData.type == GlobalConfig.StoryType.Normal or storyData.type == GlobalConfig.StoryType.Story or storyData.type == GlobalConfig.StoryType.Hide) and itemX <= storyData.mSfxPos.x then
        itemX = storyData.mSfxPos.x
        curItem = item
        currData = storyData
      end
    end
  end
  self:CleanAniTime()
  if curItem and currData then
    self.aniTime = TimerSys:DelayCall(0.1, function()
      self:ScrollMoveToMid(-curItem.mUIRoot.transform.localPosition.x)
    end)
  elseif self.minItem and self.minData then
    self.aniTime = TimerSys:DelayCall(0.1, function()
      self:ScrollMoveToMid(-self.minItem.mUIRoot.transform.localPosition.x)
    end)
  else
    self.ui.mTrans_DetailsList.anchoredPosition = Vector2(self.mOffsetX / 2, 0)
  end
  self.scrollReset = true
  self.jumpId = 0
end
function DaiyanChapterPanel:CleanAniTime()
  if self.aniTime then
    self.aniTime:Stop()
    self.aniTime = nil
  end
end
function DaiyanChapterPanel:UpdateChapterSwitch()
  local data = TableData.listChapterDatas:GetDataById(self.chapterData.id)
  local lastData = TableData.listChapterDatas:GetDataById(self.chapterData.id - 1, true)
  local nextData = TableData.listChapterDatas:GetDataById(self.chapterData.id + 1, true)
  setactive(self.ui.mTrans_PreChapter.gameObject, lastData ~= nil)
  setactive(self.ui.mTrans_NextChapter.gameObject, nextData ~= nil and NetCmdDungeonData:IsUnLockChapter(self.chapterData.id + 1))
  if lastData then
    local normalId = UIChapterGlobal:GetNormalChapterId(lastData.id)
    self.ui.mText_PreChapterNum.text = UIChapterGlobal:GetTensDigitNum(normalId)
    UIUtils.GetButtonListener(self.ui.mBtn_PreChapter.gameObject).onClick = function()
      self.chapterData.id = self.chapterData.id - 1
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterData.id)
      self.recordStoryId = self.chapterData.id ~= self.recordChapterId and 0 or self.recordStoryId
      self.recordChapterId = self.chapterData.id
      UIManager.ChangeCacheUIData(UIDef.DaiyanChapterPanel, self.chapterData.id)
      self.ui.mBgScrollHelper.enabled = false
      self.scrollReset = false
      self.lineUpdate = false
      self.curStage = nil
      self.ui.mAnimator_Root:SetTrigger("Previous")
      self:UpdateData(1)
    end
  end
  if nextData and NetCmdDungeonData:IsUnLockChapter(self.chapterData.id + 1) then
    local normalId = UIChapterGlobal:GetNormalChapterId(nextData.id)
    self.ui.mText_NextChapterNum.text = UIChapterGlobal:GetTensDigitNum(normalId)
    UIUtils.GetButtonListener(self.ui.mBtn_NextChapter.gameObject).onClick = function()
      self.chapterData.id = self.chapterData.id + 1
      self.normalChapterId = UIChapterGlobal:GetNormalChapterId(self.chapterData.id)
      self.recordStoryId = self.chapterData.id ~= self.recordChapterId and 0 or self.recordStoryId
      self.recordChapterId = self.chapterData.id
      UIManager.ChangeCacheUIData(UIDef.DaiyanChapterPanel, self.chapterData.id)
      self.ui.mBgScrollHelper.enabled = false
      self.scrollReset = false
      self.lineUpdate = false
      self.curStage = nil
      self.ui.mAnimator_Root:SetTrigger("Next")
      self:UpdateData(1)
    end
  end
  self.ui.mText_CurrentChapterNum.text = UIChapterGlobal:GetTensDigitNum(self.normalChapterId)
end
function DaiyanChapterPanel:OnShowFinish()
end
function DaiyanChapterPanel:OnTop()
end
function DaiyanChapterPanel:OnBackFrom()
  self:UpdateData(2)
end
function DaiyanChapterPanel:OnRecover()
  self:UpdateData(2)
end
function DaiyanChapterPanel:OnClose()
  self.recordChapterId = 0
  self.chapterId = 0
  self.normalChapterId = 0
  self.storyCount = 0
  self.jumpId = 0
  self.jumpNotOpenId = 0
  self.curStage = nil
  self.lineUpdate = false
  self.scrollReset = false
  self.skipClear = nil
  self:CleanAllSelected()
  self:RemoveListeners()
end
function DaiyanChapterPanel:OnHide()
end
function DaiyanChapterPanel:OnHideFinish()
end
function DaiyanChapterPanel:OnRelease()
  self.recordChapterId = 0
  self.chapterId = 0
  self.normalChapterId = 0
  self.storyCount = 0
  self.jumpId = 0
  self.jumpNotOpenId = 0
  self.curStage = nil
  self.lineUpdate = false
  self.scrollReset = false
  self.skipClear = nil
  self:CleanAllSelected()
  self:RemoveListeners()
end
