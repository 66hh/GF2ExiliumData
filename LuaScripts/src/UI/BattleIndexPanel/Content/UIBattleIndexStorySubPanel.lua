require("UI.BattleIndexPanel.Item.UIBattleIndexTabStoryItem")
require("UI.ChapterPanel.UIChapterGlobal")
UIBattleIndexStorySubPanel = class("UIBattleIndexStorySubPanel", UIBaseView)
UIBattleIndexStorySubPanel.__index = UIBattleIndexStorySubPanel
UIBattleIndexStorySubPanel.curIndex = -1
UIBattleIndexStorySubPanel.tabList = {}
function UIBattleIndexStorySubPanel:__InitCtrl()
end
function UIBattleIndexStorySubPanel:SetCurrentIndex(index)
  UIChapterGlobal:RecordChapterId(index)
end
function UIBattleIndexStorySubPanel:InitCtrl(root, parent)
  self.ui = {}
  self:SetRoot(root)
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
  self.mParent = parent
  self.chapterList = TableData.GetNormalChapterList()
  self.clickID = -1
  self:InitTabs()
  local chapterId = UIChapterGlobal:GetRecordChapterId() or NetCmdDungeonData:GetCurrentChapterByType(1)
  if 0 < chapterId then
    self:OnClickTab(self.chapterList[chapterId - 1])
  else
    self:OnClickTab(self.chapterList[0])
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Ok.gameObject).onClick = function()
    self:EnterChapter()
  end
  UIUtils.AddBtnClickListener(self.ui.mBtn_TutorialStage, function()
    self:OnClickTutorialStage()
  end)
end
function UIBattleIndexStorySubPanel:InitTabs()
  for i = 0, self.chapterList.Count - 1 do
    do
      local data = self.chapterList[i]
      local item
      if self.tabList[data.id] == nil then
        item = UIBattleIndexTabStoryItem.New()
        item:InitCtrl(self.ui.mTrans_Content)
        self.tabList[data.id] = item
      else
        item = self.tabList[data.id]
      end
      item:SetData(data)
      item:SetIndexText(i + 1)
      item:SetGlobalTabId(data.GlobalTab)
      UIUtils.GetButtonListener(item.ui.mBtn_Root.gameObject).onClick = function()
        self:OnClickTab(data)
      end
    end
  end
end
function UIBattleIndexStorySubPanel:NewChapterUnlock()
  if NetCmdDungeonData.HasNewChapterUnlocked then
    TimerSys:DelayCall(0.5, function()
      UIManager.OpenUIByParam(UIDef.UINewChapterShowDialog, {
        NewChapterID = NetCmdDungeonData.NewChapterID
      })
    end)
  end
end
function UIBattleIndexStorySubPanel:IsReadyToStartTutorial()
  return not NetCmdDungeonData.HasNewChapterUnlocked
end
function UIBattleIndexStorySubPanel:RefreshTabs()
  for i = 0, self.chapterList.Count - 1 do
    local data = self.chapterList[i]
    if self.tabList[data.id] ~= nil then
      self.tabList[data.id]:SetData(data)
    end
  end
  self:RefreshTutorialStageTab()
end
function UIBattleIndexStorySubPanel:OnShowStart(isRecover)
  if not isRecover then
    self:NewChapterUnlock()
  end
end
function UIBattleIndexStorySubPanel:OnShowFinish()
end
function UIBattleIndexStorySubPanel:OnBackFrom()
  self:NewChapterUnlock()
  self:OnClickTabByIndex()
end
function UIBattleIndexStorySubPanel:OnClickTabByIndex()
  local recordChapterId = UIChapterGlobal:GetRecordChapterId() or 1
  self:OnClickTab(self.chapterList[recordChapterId - 1])
end
function UIBattleIndexStorySubPanel:OnClickTab(data)
  local id = data.id
  self.clickID = data.id
  local str = CS.LuaUIUtils.CheckUnlockPopupStrByRepeatedList(data.unlock)
  if string.len(str) > 0 then
    CS.PopupMessageManager.PopupString(str)
    return
  end
  UIChapterGlobal:RecordChapterId(id)
  for i, tab in pairs(self.tabList) do
    if i == id then
      self.curItem = tab
    end
    tab.ui.mBtn_Root.interactable = i ~= id
  end
  self:CalculatePercent()
  self.ui.mText_Des.text = self.curItem.mData.chapter_des.str
  if self.mParent ~= nil then
    self.mParent:RefreshStoryBg(self.curItem.mData)
  end
  LuaUtils.AutoScrollToVisible(self.ui.mVirtualList, self.curItem:GetRoot(), self.ui.mHovLayoutGroup.spacing.y, 1, 0.5, 0.2)
  MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIBattleIndexPanel, self.curItem:GetGlobalTab())
end
function UIBattleIndexStorySubPanel:EnterChapter()
  if self.opened then
    return
  end
  local item = self.curItem
  if item.mData.id and item.isUnLock then
    local chapterId = item.mData.id
    UIBattleIndexStorySubPanel.curChapterId = item.mData.id
    if item.isNew then
      AccountNetCmdHandler:UpdateWatchedChapter(item.mData.id)
      item.isNew = false
      if self.opened == nil then
        self.opened = true
      end
      local story = TableData.GetFirstStoryByChapterID(item.mData.id)
      CS.AVGController.PlayAVG(story.stage_id, 10, function()
        UIManager.OpenUIByParam(UIDef.UIChapterPanel, chapterId)
        gfdebug("初次点击进入章节")
        self.opened = nil
      end)
    else
      UIManager.OpenUIByParam(UIDef.UIChapterPanel, chapterId)
      self.opened = nil
    end
  end
end
function UIBattleIndexStorySubPanel:CalculatePercent()
  local storyCount = NetCmdDungeonData:GetCanChallengeStoryList(self.curItem.mData.id).Count
  local total = storyCount * UIChapterGlobal.MaxChallengeNum
  local stars = NetCmdDungeonData:GetCurStarsByChapterID(self.curItem.mData.id)
  local storyData = NetCmdDungeonData:GetCurrentStory()
  self.ui.mText_Num.text = storyData.code.str
  self.ui.mText_Percentage.text = tostring(math.ceil(stars / total * 100)) .. "%"
  self.ui.mText_PercentNum.text = string_format(TableData.GetHintById(112016), stars, total)
  if stars == total then
    self.ui.mColor_Bg.color = ColorUtils.RedColor5
  else
    self.ui.mColor_Bg.color = ColorUtils.BlueColor5
  end
end
function UIBattleIndexStorySubPanel:RefreshTutorialStageTab()
  local isNeedRedPoint = NetCmdSimulateBattleData:CheckTeachingUnlockRedPoint() or NetCmdSimulateBattleData:CheckTeachingRewardRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteReadRedPoint() or NetCmdSimulateBattleData:CheckTeachingNoteProgressRedPoint()
  setactive(self.ui.mTrans_TutorialStageRedPoint, isNeedRedPoint)
  local underCombatTypeData = TableDataBase.listUnderCombatTypeDatas:GetDataById(StageType.TutorialStage.value__)
  local isUnlock = AccountNetCmdHandler:CheckSystemIsUnLock(underCombatTypeData.unlock)
  setactivewithcheck(self.ui.mTrans_TutorialLock, not isUnlock)
  setactivewithcheck(self.ui.mTrans_TutorialOpen, isUnlock)
end
function UIBattleIndexStorySubPanel:OnClickTutorialStage()
  local underCombatTypeData = TableDataBase.listUnderCombatTypeDatas:GetDataById(StageType.TutorialStage.value__)
  if TipsManager.NeedLockTips(underCombatTypeData.unlock) then
    return
  end
  local simType = underCombatTypeData.id
  local eType = StageType.__CastFrom(simType)
  NetCmdStageRecordData:RequestStageRecordByType(eType, function(ret)
    if ret == ErrorCodeSuc then
      UIManager.OpenUIByParam(UIDef.UISimCombatTutorialEntrancePanel, simType)
    end
  end)
end
function UIBattleIndexStorySubPanel:OnRelease()
  self.opened = nil
  for _, obj in pairs(UIBattleIndexStorySubPanel.tabList) do
    obj:RemoveListener()
    gfdestroy(obj:GetRoot())
  end
  UIBattleIndexStorySubPanel.tabList = {}
end
function UIBattleIndexStorySubPanel:OnClose()
end
