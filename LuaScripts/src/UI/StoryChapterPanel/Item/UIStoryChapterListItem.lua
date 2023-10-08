require("UI.StoryChapterPanel.Item.UIRewardBubbleItem")
require("UI.UIBaseCtrl")
UIStoryChapterListItem = class("UIStoryChapterListItem", UIBaseCtrl)
UIStoryChapterListItem.__index = UIStoryChapterListItem
function UIStoryChapterListItem:__InitCtrl()
  for i = 1, UIChapterGlobal.MaxChallengeNum do
    local challenge = {}
    local obj = self:GetRectTransform("Root/GrpStar/Star_" .. i)
    challenge.obj = obj
    challenge.tranOff = UIUtils.GetRectTransform(obj, "Star_Off")
    challenge.tranOn = UIUtils.GetRectTransform(obj, "Star_On")
    table.insert(self.challengeList, challenge)
  end
end
function UIStoryChapterListItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("story/Btn_StoryChapterListItem.prefab", self))
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
  self.ui.mText_RandomNum.text = UIChapterGlobal:GetRandomNum()
end
function UIStoryChapterListItem:SetData(data)
  self.storyData = data
  if data ~= nil then
    setactive(self.mUIRoot, not data.hide_point)
    self:UpdateItem()
  else
    self.preStory = nil
    self.nextStory = nil
    self.nextBranchStory = nil
    setactive(self.mUIRoot, false)
  end
end
function UIStoryChapterListItem:UpdateItem()
  self:UpdateStage()
  self.branchList = NetCmdDungeonData:GetMainStoryBranchs(self.storyData.id)
end
function UIStoryChapterListItem:UpdateStage()
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
    self.ui.mText_StageName.text = self.storyData.name.str
    self.isUnlock = NetCmdDungeonData:IsUnLockStory(self.storyData.id) and AccountNetCmdHandler:GetLevel() >= self.storyData.unlock_level
    self.ui.mAnimator:SetBool("Locked", not self.isUnlock)
    if not self.isUnlock then
      self.ui.mAnimator.enabled = true
      self.ui.mAnimator:Play("T", 1, 1)
      setactivewithcheck(self.ui.mText_Title, true)
    end
    local showTitle = 0 < stageData.level_difficulty
    if showTitle then
      self.ui.mText_Title.text = TableData.GetHintById(stageData.level_difficulty)
    end
    setactivewithcheck(self.ui.mText_Title.transform.parent, showTitle)
    setactive(self.ui.mTrans_NowProgress, isNext and self.isUnlock)
    setactive(self.ui.mTrans_Star, self.storyData.type ~= GlobalConfig.StoryType.StoryBattle and 0 < stageData.challenge_list.Count)
    if self.isUnlock then
      if stageRecord then
        if self.storyData.type == GlobalConfig.StoryType.StoryBattle then
          setactive(self.ui.mTrans_Complete, true)
        else
          setactive(self.ui.mTrans_Complete, stageRecord.ChallengeNum >= UIChapterGlobal.MaxChallengeNum)
        end
      else
        setactive(self.ui.mTrans_Complete, false)
      end
    else
      setactive(self.ui.mTrans_Complete, false)
    end
    setactive(self.ui.mTrans_Treasure, self.storyData.extra_bonus ~= "" and (stageRecord == nil or not stageRecord.BounsIsOpen))
    self:UpdateChallenge(stageRecord)
  end
end
function UIStoryChapterListItem:RefreshStage()
  if self.storyData then
    self:UpdateStage()
  end
end
function UIStoryChapterListItem:UpdateChallenge(cmdData)
  local stageData = TableData.GetStageData(self.storyData.stage_id)
  if cmdData then
    for i, obj in ipairs(self.challengeList) do
      if cmdData ~= nil and i <= cmdData.ChallengeNum then
        setactive(obj.tranOn, true)
        setactive(obj.tranOff, false)
      else
        setactive(obj.tranOn, false)
        setactive(obj.tranOff, true)
      end
      if i > stageData.ChallengeList.Count then
        setactive(obj.obj, false)
      else
        setactive(obj.obj, true)
      end
    end
  else
    for i, obj in ipairs(self.challengeList) do
      setactive(obj.tranOff, true)
      setactive(obj.tranOn, false)
      if i > stageData.ChallengeList.Count then
        setactive(obj.obj, false)
      else
        setactive(obj.obj, true)
      end
    end
  end
end
function UIStoryChapterListItem:UpdateStagePos(delta)
  if self.storyData then
    self.ui.mTrans_Self.anchoredPosition = Vector2(self.storyData.mSfxPos.x + delta, self.storyData.mSfxPos.y)
  end
end
function UIStoryChapterListItem:GetIndexOfBranch(storyId)
  if self.branchList and self.branchList.Count then
    for i = 0, self.branchList.Count - 1 do
      if self.branchList[i] == storyId then
        return i
      end
    end
  end
  return -1
end
function UIStoryChapterListItem:SetSelected(isSelect)
  self.ui.mBtn_Stage.interactable = not isSelect
end
function UIStoryChapterListItem:SetLine(startPos, endPos)
  if self.lineItem then
    self.lineItem:SetLinePos(startPos, endPos)
  end
  self:UpdatePoint()
end
function UIStoryChapterListItem:SetBranchLine(startPos, endPos)
  if self.branchLineItem then
    self.branchLineItem:SetBranchLine(startPos, endPos)
  end
  self:UpdatePoint()
end
function UIStoryChapterListItem:UpdatePoint()
  if self.lineItem and self.nextStory then
    self.lineItem:UpdateLineColor(self.nextStory.isUnlock)
  end
  if self.branchLineItem and self.nextBranchStory then
    self.branchLineItem:UpdateLineColor(self.nextBranchStory.isUnlock)
  end
end
