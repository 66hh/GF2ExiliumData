require("UI.UIBasePanel")
require("UI.ChapterPanel.UIChapterRewardPanelView")
require("UI.ChapterPanel.UIChapterGlobal")
require("UI.ChapterPanel.Item.UIChapterRewardListItem")
UIChapterRewardPanel = class("UIChapterRewardPanel", UIBasePanel)
UIChapterRewardPanel.__index = UIChapterRewardPanel
function UIChapterRewardPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIChapterRewardPanel:OnClose()
  self:ReleaseCtrlTable(self.rewardList, true)
  self.rewardList = nil
end
function UIChapterRewardPanel:OnRelease()
end
function UIChapterRewardPanel:OnInit(root, data)
  self.chapterId = data.chapterId
  self.isDifficult = data.isDifficult
  self.rewardList = {}
  self:SetRoot(root)
  self.mView = UIChapterRewardPanelView.New()
  self.ui = {}
  self.mView:InitCtrl(root, self.ui)
  local titleHitNum
  self.progressHitNum = nil
  if self.isDifficult == false then
    titleHitNum = 903245
    self.progressHitNum = 103101
  else
    titleHitNum = 193018
    self.progressHitNum = 193022
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_CloseBg.gameObject).onClick = function()
    self:CloseFunction()
  end
  self:UpdatePanel()
end
function UIChapterRewardPanel:OnTop()
  self:UpdatePanel()
end
function UIChapterRewardPanel:OnShowStart()
  self.timer = TimerSys:DelayFrameCall(1, function()
    if self.lookIndex > 0 then
      local itemRect = self.rewardList[self.lookIndex].mUIRoot:GetComponent(typeof(CS.UnityEngine.RectTransform))
      local itemHeight = itemRect.rect.height
      local itemPos = itemRect.anchoredPosition.y
      local viewHeight = self.ui.mScrollRect_TargetList.viewport.rect.height
      local contentHeight = self.ui.mScrollRect_TargetList.content.rect.height
      local targetHeight = math.abs(itemPos) + itemHeight / 2
      if viewHeight < targetHeight then
        local offset = targetHeight - viewHeight
        local contentOffset = contentHeight - viewHeight
        local value = 1 - offset / contentOffset
        self.ui.mScrollRect_TargetList.verticalNormalizedPosition = value
      end
    end
  end)
end
function UIChapterRewardPanel:UpdatePanel()
  self.lookIndex = 0
  local chapterData
  local rewardCount = 0
  local chapterReward, progressTitleStr
  if self.isDifficult == true then
    chapterData = TableData.listDifficultyChapterDatas:GetDataById(self.chapterId)
    progressTitleStr = TableData.GetHintById(193022)
  else
    chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
    progressTitleStr = TableData.GetHintById(103101)
  end
  self.ui.mText_ProgressTitle.text = progressTitleStr
  rewardCount = chapterData.chapter_reward_value.Count
  local receiveCount = 0
  local finishCount = 0
  local stars = 0
  if self.isDifficult then
    stars = NetCmdDungeonData:GetCurStarsByDifficultChapterID(self.chapterId)
  else
    stars = NetCmdDungeonData:GetCurStarsByChapterID(self.chapterId)
  end
  chapterReward = chapterData.chapter_reward
  local strList = string.split(chapterReward, "|")
  for i = 1, rewardCount do
    local rewardList = {}
    local ss = string.split(strList[i], ",")
    for _, v in ipairs(ss) do
      local s = string.split(v, ":")
      local item = {}
      item.itemId = tonumber(s[1])
      item.itemNum = tonumber(s[2])
      table.insert(rewardList, item)
    end
    local rewardItem
    if self.rewardList[i] == nil then
      rewardItem = UIChapterRewardListItem.New()
      rewardItem:InitCtrl(self.ui.mTrans_Content)
      UIUtils.GetButtonListener(rewardItem.ui.transReceive.gameObject).onClick = function()
        NetCmdDungeonData:GetReward(self.chapterId, i, self.isDifficult, function(ret)
          if ret == ErrorCodeSuc then
            self:TakeQuestRewardCallBack()
          end
        end)
      end
    else
      rewardItem = self.rewardList[i]
    end
    local state = 0
    if self.isDifficult == true then
      state = NetCmdDungeonData:GetCurStateByDifficultChapterID(self.chapterId, i)
    else
      state = NetCmdDungeonData:GetCurStateByChapterID(self.chapterId, i)
    end
    if state == UIChapterGlobal.RewardState.Receive and self.lookIndex == 0 then
      self.lookIndex = i
    end
    receiveCount = state == UIChapterGlobal.RewardState.Receive and receiveCount + 1 or receiveCount
    if state == UIChapterGlobal.RewardState.Finish then
      finishCount = finishCount + 1
    end
    rewardItem:SetData(chapterData, stars, state, i, rewardList, self.isDifficult)
    table.insert(self.rewardList, rewardItem)
  end
  self.ui.mText_Progress.text = stars
  self.ui.mScrollRect_TargetList.verticalNormalizedPosition = 1
end
function UIChapterRewardPanel:OnReceiveItem()
  local chapterData
  local rewardCount = 0
  if self.isDifficult then
    chapterData = TableData.listDifficultyChapterDatas:GetDataById(self.chapterId)
  else
    chapterData = TableData.listChapterDatas:GetDataById(self.chapterId)
  end
  rewardCount = chapterData.chapter_reward_value.Count
  local total = {}
  for i = 1, rewardCount do
    local state
    if self.isDifficult then
      state = NetCmdDungeonData:GetCurStateByDifficultChapterID(self.chapterId, i)
    else
      state = NetCmdDungeonData:GetCurStateByChapterID(self.chapterId, i)
    end
    if state == UIChapterGlobal.RewardState.Receive then
      for itemId, itemNum in pairs(chapterData["chapter_reward_" .. i]) do
        if total[itemId] == nil then
          total[itemId] = itemNum
        else
          total[itemId] = total[itemId] + itemNum
        end
      end
    end
  end
  for itemId, num in pairs(total) do
    if TipsManager.CheckItemIsOverflowAndStop(itemId, num) then
      return
    end
  end
  NetCmdDungeonData:CheckCanGetReward(self.chapterId, self.isDifficult, function()
    self:TakeQuestRewardCallBack()
  end)
end
function UIChapterRewardPanel:TakeQuestRewardCallBack()
  UIManager.OpenUI(UIDef.UICommonReceivePanel)
  MessageSys:SendMessage(CS.GF2.Message.UIEvent.RefreshChapterInfo, nil)
end
function UIChapterRewardPanel:CloseFunction()
  UIManager.CloseUI(UIDef.UIChapterRewardPanel)
end
