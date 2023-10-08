require("UI.UIBaseCtrl")
UIBranchChapterListItem = class("UIBranchChapterListItem", UIBaseCtrl)
UIBranchChapterListItem.__index = UIBranchChapterListItem
function UIBranchChapterListItem:__InitCtrl()
  for i = 1, UIChapterGlobal.MaxChallengeNum do
    local challenge = {}
    local obj = self:GetRectTransform("Root/GrpStar/Star_" .. i)
    challenge.obj = obj
    challenge.tranOff = UIUtils.GetRectTransform(obj, "Star_Off")
    challenge.tranOn = UIUtils.GetRectTransform(obj, "Star_On")
    table.insert(self.challengeList, challenge)
  end
end
function UIBranchChapterListItem:InitCtrl(parent)
  local instObj = instantiate(UIUtils.GetGizmosPrefab("story/Btn_BranchChapterListItem.prefab", self))
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
function UIBranchChapterListItem:SetData(data)
  self.storyData = data
  if data ~= nil then
    if self.storyData.type == GlobalConfig.StoryType.Hide then
      local isUnlockHide = NetCmdDungeonData:IsUnlockHideStory(self.storyData.chapter)
      if not isUnlockHide then
        self.ui.mAnimator:SetBool("Locked", false)
      end
      setactive(self.mUIRoot, isUnlockHide)
    else
      setactive(self.mUIRoot, true)
    end
    self:UpdateItem()
  else
    self.preStory = nil
    self.nextStory = nil
    self.nextBranchStory = nil
    self.ui.mAnimator:SetBool("Locked", false)
    if not self.isUnlock then
      self.ui.mAnimator.enabled = true
      self.ui.mAnimator:Play("T", 1, 1)
    end
    setactive(self.mUIRoot, false)
  end
end
function UIBranchChapterListItem:UpdateItem()
  self:UpdateBranch()
  self.branchList = NetCmdDungeonData:GetMainStoryBranchs(self.storyData.id)
end
function UIBranchChapterListItem:UpdateBranch()
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
    local showTitle = 0 < stageData.level_difficulty
    if showTitle then
      self.ui.mText_Title.text = TableData.GetHintById(stageData.level_difficulty)
    end
    setactivewithcheck(self.ui.mText_Title.transform.parent, showTitle)
    self.ui.mText_BranchName.text = self.storyData.name.str
    self.isUnlock = NetCmdDungeonData:IsUnLockStory(self.storyData.id)
    self.ui.mAnimator:SetBool("Locked", not self.isUnlock)
    if not self.isUnlock then
      self.ui.mAnimator.enabled = true
      self.ui.mAnimator:Play("T", 1, 1)
    end
    setactive(self.ui.mTrans_NowProgress, false)
    setactive(self.ui.mTrans_Star, self.storyData.type ~= GlobalConfig.StoryType.StoryBattle and 0 < stageData.challenge_list.Count)
    if self.isUnlock then
      if stageRecord then
        setactive(self.ui.mTrans_Complete, stageRecord.ChallengeNum >= UIChapterGlobal.MaxChallengeNum)
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
function UIBranchChapterListItem:UpdateChallenge(cmdData)
  local stageData = TableData.GetStageData(self.storyData.stage_id)
  if cmdData then
    for i, obj in ipairs(self.challengeList) do
      UIUtils.SetAlpha(obj.imgBg, cmdData ~= nil and i <= cmdData.ChallengeNum and 1 or 0.5)
      setactive(obj.tranOn, cmdData ~= nil and i <= cmdData.ChallengeNum)
      if i > stageData.ChallengeList.Count then
        setactive(obj.obj, false)
      else
        setactive(obj.obj, true)
      end
    end
  else
    for i, obj in ipairs(self.challengeList) do
      UIUtils.SetAlpha(obj.imgBg, 0.5)
      setactive(obj.tranOn, false)
      if i > stageData.ChallengeList.Count then
        setactive(obj.obj, false)
      else
        setactive(obj.obj, true)
      end
    end
  end
end
function UIBranchChapterListItem:UpdateStagePos(delta)
  if self.storyData then
    self.ui.mTrans_Self.anchoredPosition = Vector2(self.storyData.mSfxPos.x + delta, self.storyData.mSfxPos.y)
  end
end
function UIBranchChapterListItem:CheckSimCombatIsUnLock()
  local isUnLock = AccountNetCmdHandler:CheckSystemIsUnLock(self.mData.unlock)
  setactive(self.ui.mTrans_GrpLocked, not isUnLock)
  setactive(self.ui.mTrans_GrpOpen, isUnLock)
end
function UIBranchChapterListItem:RefreshStage()
  if self.storyData then
    self:UpdateBranch()
  end
end
function UIBranchChapterListItem:SetSelected(isSelect)
  self.ui.mBtn_Stage.interactable = not isSelect
end
function UIBranchChapterListItem:SetLine(startPos, endPos)
  if self.lineItem then
    self.lineItem:SetLinePos(startPos, endPos)
  end
  self:UpdatePoint()
end
function UIBranchChapterListItem:SetBranchLine(startPos, endPos)
  if self.branchLineItem then
    self.branchLineItem:SetBranchLine(startPos, endPos)
  end
  self:UpdatePoint()
end
function UIBranchChapterListItem:GetIndexOfBranch(storyId)
  if self.branchList and self.branchList.Count then
    for i = 0, self.branchList.Count - 1 do
      if self.branchList[i] == storyId then
        return i
      end
    end
  end
  return -1
end
function UIBranchChapterListItem:UpdatePoint()
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
