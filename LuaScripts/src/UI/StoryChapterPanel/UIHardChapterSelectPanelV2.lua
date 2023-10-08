require("UI.StoryChapterPanel.UIHardChapterDetailPanelView")
require("UI.StoryChapterPanel.Item.UIHardChapterSelectItem")
require("UI.Common.UICommonArrowBtnItem")
require("UI.UIBasePanel")
UIHardChapterSelectPanelV2 = class("UIHardChapterSelectPanelV2", UIBasePanel)
UIHardChapterSelectPanelV2.__index = UIHardChapterSelectPanelV2
function UIHardChapterSelectPanelV2:ctor()
  UIHardChapterSelectPanelV2.super.ctor(self)
end
function UIHardChapterSelectPanelV2:OnAwake()
  if NetCmdDungeonData:CheckDifficultChapterSystemHasLook() == false then
    PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "DifficultSystem", 1)
  end
end
function UIHardChapterSelectPanelV2:OnInit(root, data)
  self:SetRoot(root)
  self.mView = UIHardChapterDetailPanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  self.tabList = {}
  self.chapterList = TableData.listDifficultyChapterDatas:GetList()
  self.maxPageNum = math.ceil(self.chapterList.Count / 5)
  self.pageNum = NetCmdDungeonData.difficultChapterPageNum
  self.curIndex = -1
  self.tabListCount = 6
  self.arrowBtn = UICommonArrowBtnItem.New()
  self.arrowBtn:InitObj(self.ui.mObj_ViewSwitch)
  self:AddBtnListener()
  self.tableTotalRaidNum = TableData.GlobalSystemData.DifficultyStageSweepsTimes
  self.canRaidNum = 99
  setactive(self.ui.mTrans_Times, self.tableTotalRaidNum > 0)
  self:RefreshRaidNum()
  self:InitTabs()
  self:RefreshTabs()
end
function UIHardChapterSelectPanelV2:OnTop()
  self:RefreshRaidNum()
  self:ReFreshPanel()
end
function UIHardChapterSelectPanelV2:OnShowStart()
  self.needRefresh = true
  for i = 1, 5 do
    local anim = self.tabList[i].ui.mAnimator_Root
    anim:Update(10)
    anim:Update(10)
    anim:Update(0.1)
  end
end
function UIHardChapterSelectPanelV2:OnBackFrom()
  self:RefreshRaidNum()
  self:DelayCall(0.5, function()
    self.needRefresh = true
    self:ReFreshPanel()
  end)
end
function UIHardChapterSelectPanelV2:OnSave()
  NetCmdDungeonData:SetDifficultChapterPageNum(self.pageNum)
end
function UIHardChapterSelectPanelV2:OnRecover()
  self.needRefresh = false
end
function UIHardChapterSelectPanelV2:OnRelease()
end
function UIHardChapterSelectPanelV2:OnClose()
  UIHardChapterSelectPanelV2.curIndex = -1
  self.ui = nil
  self.mView = nil
  self.currentChapter = nil
  self:ReleaseTimers()
  self.needShowTip = nil
  self:ReleaseTable(self.tabList)
  self.tabList = nil
end
function UIHardChapterSelectPanelV2:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIHardChapterSelectPanelV2)
  end
  self.arrowBtn:SetLeftArrowClickFunction(function()
    self:OnClickArrow(-1)
  end)
  self.arrowBtn:SetRightArrowClickFunction(function()
    self:OnClickArrow(1)
  end)
  self.arrowBtn:SetLeftArrowActiveFunction(function()
    return self.pageNum > 1
  end)
  self.arrowBtn:SetRightArrowActiveFunction(function()
    return self.pageNum < self.maxPageNum
  end)
end
function UIHardChapterSelectPanelV2:InitTabs()
  for i = 1, self.tabListCount do
    local root = self.ui.mTrans_Center:Find(string.format("Root/GrpChapterSelection%s", i))
    local item = UIHardChapterSelectItem.New()
    item:InitCtrl(root)
    self.tabList[i] = item
  end
end
function UIHardChapterSelectPanelV2:ReFreshPanel()
  if self.needRefresh ~= true then
    return
  end
  local curChapterId = 0
  local chapterNum = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. "HardChapterUnlock")
  for i = 0, self.chapterList.Count - 1 do
    local data = self.chapterList[i]
    local isAllAnalysis = NetCmdSimulateBattleData:IsAnalysisAllDifficultChapterStory(data.id)
    local isComplete = NetCmdDungeonData:IsCompleteDifficultChapter(data.id) and isAllAnalysis
    if isComplete and chapterNum < data.id then
      curChapterId = data.id
      break
    end
  end
  if curChapterId ~= 0 then
    self.needShowTip = chapterNum ~= curChapterId
  end
  self:RefreshTabs()
  if self.needShowTip then
    self:DelayCall(0.7, function()
      local chapterData = TableData.listDifficultyChapterDatas:GetDataById(curChapterId)
      if chapterData.chapter_sweeps_switch == 1 then
        CS.PopupMessageManager.PopupStateChangeString(string_format(TableData.GetHintById(193013), chapterData.num, chapterData.name.str))
      end
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "HardChapterUnlock", curChapterId)
      self.needShowTip = false
      self:ReFreshPanel()
    end)
  end
end
function UIHardChapterSelectPanelV2:RefreshTabs(needAnim)
  if needAnim == true then
    self.ui.mAnimator_Self:SetTrigger("Switch")
  end
  self.currentChapter = nil
  local count = self.pageNum * 5
  count = count > self.chapterList.Count and self.chapterList.Count or count
  local startIndex = 5 * (self.pageNum - 1)
  local endIndex = startIndex + 5
  for i, v in ipairs(self.tabList) do
    v:SetActive(i <= endIndex and i > startIndex)
  end
  for i = startIndex, endIndex - 1 do
    local index = i - startIndex + 1
    local itemIndex = i + 1
    local item = self.tabList[itemIndex]
    if itemIndex <= #self.tabList then
      do
        local data = self.chapterList[i]
        item:SetActive(true)
        local isAllAnalysis = NetCmdSimulateBattleData:IsAnalysisAllDifficultChapterStory(data.id)
        local isComplete = NetCmdDungeonData:IsCompleteDifficultChapter(data.id) and isAllAnalysis
        item:SetData(data)
        item:SetTotalRaidNum(self.canRaidNum)
        item:SetComplete(isComplete)
        UIUtils.GetButtonListener(item.ui.mBtn_Level.gameObject).onClick = function()
          self:OnClickTab(itemIndex)
        end
        UIUtils.GetButtonListener(item.ui.mBtn_Raid.gameObject).onClick = function()
          self:OnClickRaid(itemIndex)
        end
        local isSelect = isComplete == false and self.currentChapter == nil
        if isSelect then
          self.currentChapter = item
        end
        item:IsNowSelect(isSelect == true)
        item:SetAnimState()
      end
    end
  end
  setactive(self.ui.mTrans_None, count < endIndex)
  self.arrowBtn:RefreshArrowActive()
  local showRightRedPoint = self:RefreshArrowRedPoint(1)
  setactive(self.ui.mTrans_RedPointR, showRightRedPoint)
  local showLeftRedPoint = self:RefreshArrowRedPoint(-1)
  setactive(self.ui.mTrans_RedPointL, showLeftRedPoint)
end
function UIHardChapterSelectPanelV2:RefreshRaidNum()
  local storyRaidNum = self.tableTotalRaidNum - NetCmdSimulateBattleData.storyTotalRaidNum
  self.ui.mText_TotalRaidNum.text = string_format(TableData.GetHintById(112016), storyRaidNum, self.tableTotalRaidNum)
end
function UIHardChapterSelectPanelV2:OnClickTab(index, fromInit)
  local item = self.tabList[index]
  if item.isUnLock == false then
    if not fromInit then
      CS.PopupMessageManager.PopupString(item.mData.unlock_hint)
    end
    return
  elseif item.levelUnlocked == false then
    if not fromInit then
      local preData = TableData.listChapterDatas:GetDataById(item.mData.pre_chapter)
      local hint = string_format(TableData.GetHintById(103031), preData.level)
      CS.PopupMessageManager.PopupString(hint)
    end
    return
  end
  self:EnterHard(item)
end
function UIHardChapterSelectPanelV2:OnClickRaid(index)
  local item = self.tabList[index]
  local itemData = item.mData
  if item.canRaid == true then
    if self.canRaidNum <= 0 then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(193024))
      return
    end
    local maxNum = item.canRaidNum
    if maxNum <= 0 then
      local hint = TableData.GetHintById(193023)
      CS.PopupMessageManager.PopupString(hint)
      return
    end
    local data = {}
    for i, v in pairs(itemData.sweeps_cost) do
      data.costItemId = i
      data.costItemNum = v
    end
    data.chapterId = itemData.id
    data.maxSweepsNum = maxNum
    local showData = UIUtils.GetKVSortItemTable(itemData.sweeps_reward)
    data.rewardItemList = showData
    function data.raidCallBack(raidTime, callBack)
      NetCmdSimulateBattleData:SendDifficultChapterRaid(data.chapterId, raidTime, callBack)
    end
    if not TipsManager.CheckStaminaIsEnoughOnly(data.costItemNum) then
      TipsManager.ShowBuyStamina()
      return
    end
    UIManager.OpenUIByParam(UIDef.UIRaidDialogV2, data)
  else
    CS.PopupMessageManager.PopupString(TableData.GetHintById(193014))
  end
end
function UIHardChapterSelectPanelV2:OnClickArrow(changeNum)
  self.pageNum = self.pageNum + changeNum
  if self.pageNum < 1 then
    self.pageNum = 1
  end
  if self.pageNum > self.maxPageNum then
    self.pageNum = self.maxPageNum
  end
  self:RefreshTabs(true)
end
function UIHardChapterSelectPanelV2:GetStoryItemId(id)
  for _, stage in ipairs(self.tabList) do
    if stage.mData.id == id then
      return stage
    end
  end
end
function UIHardChapterSelectPanelV2:EnterHard(item)
  if item.mData.id and item.isUnLock then
    local chapterId = item.mData.id
    if item.isNew then
      AccountNetCmdHandler:UpdateWatchedChapter(item.mData.id)
      item.isNew = false
    end
    if item.isNewChapter then
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. "_ChapterNewUnlockRedPointKey_" .. chapterId, 1)
      item.isNewChapter = false
    end
    UIManager.OpenUIByParam(UIDef.UIHardChapterDetailPanel, chapterId)
  end
end
function UIHardChapterSelectPanelV2:RefreshArrowRedPoint(changeNum)
  local num = self.pageNum + changeNum
  local redPointCount = 0
  if 1 <= num and num <= self.maxPageNum then
    local count = num * 5
    count = count > self.chapterList.Count and self.chapterList.Count or count
    local startIndex = 5 * (num - 1)
    local endIndex = startIndex + 5
    endIndex = count < endIndex and count or endIndex
    for i = startIndex, endIndex - 1 do
      local data = self.chapterList[i]
      local id = data.id
      local isUnLock = true
      for i = 0, data.unlock.Count - 1 do
        if not NetCmdAchieveData:CheckComplete(data.unlock[i]) then
          isUnLock = false
        end
      end
      local levelUnlocked = AccountNetCmdHandler:GetLevel() >= data.level
      local canReceive = 0 < NetCmdDungeonData:UpdateDifficultChapterRewardRedPoint(id)
      local canAnalysis = NetCmdSimulateBattleData:CheckCanAnalysisByChapterID(id)
      local isNewChapter = NetCmdDungeonData:CheckNewChapterUnlockByID(data.id)
      if (canReceive or canAnalysis or isNewChapter) and isUnLock == true and levelUnlocked == true then
        redPointCount = redPointCount + 1
      end
    end
  end
  return 0 < redPointCount
end
