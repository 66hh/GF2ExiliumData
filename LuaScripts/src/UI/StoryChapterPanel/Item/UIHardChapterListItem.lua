require("UI.UIBaseCtrl")
UIHardChapterListItem = class("UIHardChapterListItem", UIBaseCtrl)
UIHardChapterListItem.__index = UIHardChapterListItem
function UIHardChapterListItem:__InitCtrl()
  for i = 1, UIChapterGlobal.MaxChallengeNum do
    local challenge = {}
    local obj = self:GetRectTransform("Root/GrpStar/Star_" .. i)
    challenge.obj = obj
    challenge.tranOff = UIUtils.GetRectTransform(obj, "Star_Off")
    challenge.tranOn = UIUtils.GetRectTransform(obj, "Star_On")
    table.insert(self.challengeList, challenge)
  end
end
function UIHardChapterListItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("story/Btn_HardChapterListItem.prefab", self))
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
function UIHardChapterListItem:SetData(data)
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
function UIHardChapterListItem:UpdateItem()
  self:UpdateStage()
  self.branchList = NetCmdDungeonData:GetMainStoryBranchs(self.storyData.id)
end
function UIHardChapterListItem:UpdateStage()
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
    self.isUnlock = NetCmdDungeonData:IsUnLockStory(self.storyData.id)
    setactive(self.ui.mTrans_Locked, not self.isUnlock)
    local leftTimes = self.storyData.daily_times - NetCmdDungeonData:DailyTimes(self.storyData.id)
    if 0 < leftTimes then
      self.ui.mText_Num.text = leftTimes .. "/" .. self.storyData.daily_times
    else
      self.ui.mText_Num.text = "<color=#FF5E41>" .. leftTimes .. "</color>/" .. self.storyData.daily_times
    end
    setactive(self.ui.mTrans_TextNum, self.storyData.daily_times ~= 0)
    setactive(self.ui.mTrans_NowProgress, isNext and self.isUnlock)
    setactive(self.ui.mTrans_Star, self.storyData.type ~= GlobalConfig.StoryType.StoryBattle and 0 < stageData.challenge_list.Count)
    self.ui.mAnimator:SetBool("Locked", not self.isUnlock)
    if not self.isUnlock then
      self.ui.mText_Title.text = TableData.GetHintById(900009)
      self.ui.mAnimator.enabled = true
      self.ui.mAnimator:Play("T", 1, 1)
      setactive(self.ui.mTrans_Complete, false)
    else
      self.ui.mText_Title.text = TableData.GetHintById(28)
      if stageRecord then
        if self.storyData.type == GlobalConfig.StoryType.StoryBattle then
          setactive(self.ui.mTrans_Complete, true)
        else
          setactive(self.ui.mTrans_Complete, stageRecord.ChallengeNum >= UIChapterGlobal.MaxChallengeNum)
        end
      else
        setactive(self.ui.mTrans_Complete, false)
      end
    end
    self:UpdateChallenge(stageRecord)
  end
end
function UIHardChapterListItem:RefreshStage()
  if self.storyData then
    self:UpdateStage()
    self:UpdatePoint(self.isUnlock)
  end
end
function UIHardChapterListItem:UpdateChallenge(cmdData)
  if cmdData then
    for i, obj in ipairs(self.challengeList) do
      UIUtils.SetAlpha(obj.imgBg, cmdData ~= nil and i <= cmdData.ChallengeNum and 1 or 0.5)
      setactive(obj.tranOn, cmdData ~= nil and i <= cmdData.ChallengeNum)
    end
  else
    for i, obj in ipairs(self.challengeList) do
      UIUtils.SetAlpha(obj.imgBg, 0.5)
      setactive(obj.tranOn, false)
    end
  end
end
function UIHardChapterListItem:UpdateStagePos(delta)
  if self.storyData then
    self.ui.mTrans_Self.anchoredPosition = Vector2(self.storyData.mSfxPos.x + delta, self.storyData.mSfxPos.y)
  end
end
function UIHardChapterListItem:SetUpOrDownPoint()
  local temVec = self.ui.mTrans_RightPoint.anchoredPosition
  if self.ui.mTrans_Self.anchoredPosition.y >= 0 then
    temVec.y = temVec.y + self.ui.mTrans_RightPoint.sizeDelta.y / 2
  else
    temVec.y = temVec.y - self.ui.mTrans_RightPoint.sizeDelta.y / 2
  end
  self.ui.mTrans_RightPoint.anchoredPosition = temVec
end
function UIHardChapterListItem:SetLine(startPos, endPos)
  if self.lineItem then
    self.lineItem:SetLinePos(startPos, endPos)
  end
  self:UpdatePoint()
end
function UIHardChapterListItem:SetBranchLine(startPos, endPos)
  if self.branchLineItem then
    self.branchLineItem:SetBranchLine(startPos, endPos)
  end
  self:UpdatePoint()
end
function UIHardChapterListItem:GetIndexOfBranch(storyId)
  if self.branchList and self.branchList.Count then
    for i = 0, self.branchList.Count - 1 do
      if self.branchList[i] == storyId then
        return i
      end
    end
  end
  return -1
end
function UIHardChapterListItem:SetSelected(isSelect)
  self.ui.mBtn_Stage.interactable = not isSelect
end
function UIHardChapterListItem:UpdatePoint()
  if self.lineItem and self.nextStory then
    self.lineItem:UpdateLineColor(self.nextStory.isUnlock)
  end
  if self.branchLineItem and self.preStory then
    if self.preStory.nextBranchStory then
      self.branchLineItem:UpdateLineColor(self.preStory.nextBranchStory.isUnlock)
    else
      self.branchLineItem:UpdateLineColor(self.preStory.isUnlock)
    end
  end
end
