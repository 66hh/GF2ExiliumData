require("UI.UIBaseCtrl")
UIStoryChapterPlotListItem = class("UIStoryChapterPlotListItem", UIBaseCtrl)
UIStoryChapterPlotListItem.__index = UIStoryChapterPlotListItem
function UIStoryChapterPlotListItem:__InitCtrl()
end
function UIStoryChapterPlotListItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("story/Btn_StoryChapterPlotListItem.prefab", self))
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.challengeList = {}
  self.isUnlock = false
  self.preStory = nil
  self.nextStory = nil
  self.nextBranchStory = nil
  self:__InitCtrl()
end
function UIStoryChapterPlotListItem:SetData(data)
  self.storyData = data
  if data ~= nil then
    setactive(self.mUIRoot, true)
    self:UpdateItem()
  else
    self.preStory = nil
    self.nextStory = nil
    self.nextBranchStory = nil
    setactive(self.mUIRoot, false)
  end
end
function UIStoryChapterPlotListItem:UpdateItem()
  self:UpdateStory()
  self.branchList = NetCmdDungeonData:GetMainStoryBranchs(self.storyData.id)
end
function UIStoryChapterPlotListItem:UpdateStagePos(delta)
  if self.storyData then
    self.ui.mTrans_Self.anchoredPosition = Vector2(self.storyData.mSfxPos.x + delta, self.storyData.mSfxPos.y)
  end
end
function UIStoryChapterPlotListItem:UpdateStory()
  local stageData = TableData.GetStageData(self.storyData.stage_id)
  local stageRecord = NetCmdDungeonData:GetCmdStoryData(self.storyData.id)
  local isNext = stageRecord == nil and true or stageRecord.first_pass_time <= 0
  if stageData ~= nil then
    setactive(self.ui.mTrans_RewardIcon, 0 < stageData.reward_show and isNext)
    if 0 < stageData.reward_show then
      local rewardBubbleItem = UIRewardBubbleItem.New()
      rewardBubbleItem:InitObj(self.ui.mObj_RewardIcon)
      rewardBubbleItem:SetData(stageData.reward_show)
    end
    self.ui.mText_StoryName.text = self.storyData.name.str
    self.isUnlock = NetCmdDungeonData:IsUnLockStory(self.storyData.id) and AccountNetCmdHandler:GetLevel() >= self.storyData.unlock_level
    local showTitle = 0 < stageData.level_difficulty
    if showTitle then
      self.ui.mText_Title.text = TableData.GetHintById(stageData.level_difficulty)
    end
    setactivewithcheck(self.ui.mText_Title.transform.parent, showTitle)
    self.ui.mAnimator:SetBool("Locked", not self.isUnlock)
    if not self.isUnlock then
      self.ui.mAnimator.enabled = true
      self.ui.mAnimator:Play("T", 1, 1)
    else
    end
    setactive(self.ui.mTrans_NowProgress, isNext and self.isUnlock)
    if self.isUnlock then
      setactive(self.ui.mTrans_Complete, stageRecord ~= nil)
    else
      setactive(self.ui.mTrans_Complete, false)
    end
  end
end
function UIStoryChapterPlotListItem:RefreshStage()
  if self.storyData then
    self:UpdateStory()
  end
end
function UIStoryChapterPlotListItem:SetSelected(isSelect)
  self.ui.mBtn_Stage.interactable = not isSelect
end
function UIStoryChapterPlotListItem:SetLine(startPos, endPos)
  if self.lineItem then
    self.lineItem:SetLinePos(startPos, endPos)
  end
  self:UpdatePoint()
end
function UIStoryChapterPlotListItem:SetBranchLine(startPos, endPos)
  if self.branchLineItem then
    self.branchLineItem:SetBranchLine(startPos, endPos)
  end
  self:UpdatePoint()
end
function UIStoryChapterPlotListItem:GetIndexOfBranch(storyId)
  if self.branchList and self.branchList.Count then
    for i = 0, self.branchList.Count - 1 do
      if self.branchList[i] == storyId then
        return i
      end
    end
  end
  return -1
end
function UIStoryChapterPlotListItem:UpdatePoint()
  if self.lineItem and self.nextStory then
    self.lineItem:UpdateLineColor(self.nextStory.isUnlock)
  end
  if self.branchLineItem and self.nextBranchStory then
    self.branchLineItem:UpdateLineColor(self.nextBranchStory.isUnlock)
  end
end
