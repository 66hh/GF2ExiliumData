require("UI.ChapterPanel.UIChapterGlobal")
require("UI.UIBaseCtrl")
UIHardChapterDetailItem = class("UIHardChapterDetailItem", UIBaseCtrl)
UIHardChapterDetailItem.__index = UIHardChapterDetailItem
function UIHardChapterDetailItem:__InitCtrl()
  for i = 1, UIChapterGlobal.MaxChallengeNum do
    local challenge = {}
    local obj = self:GetRectTransform("GrpInfo/GrpIcon/GrpIcon" .. i)
    challenge.obj = obj
    challenge.tranOff = UIUtils.GetRectTransform(obj, "ImgOff")
    challenge.tranOn = UIUtils.GetRectTransform(obj, "ImgOn")
    table.insert(self.challengeList, challenge)
  end
end
function UIHardChapterDetailItem:InitCtrl(parent)
  local com = parent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(com.childItem)
  CS.LuaUIUtils.SetParent(instObj.gameObject, parent.gameObject)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.challengeList = {}
  self.isUnlock = false
  self.preStory = nil
  self.nextStory = nil
  self:__InitCtrl()
  self.difficultyStoryData = nil
  self.hasAnalysis = false
  self.ui.mAnimator_Self.keepAnimatorControllerStateOnDisable = true
end
function UIHardChapterDetailItem:SetData(data)
  self.difficultyStoryData = data
  self:SetActive(data ~= nil)
  if data ~= nil then
    self:UpdateItem()
  else
    self.preStory = nil
    self.nextStory = nil
  end
end
function UIHardChapterDetailItem:UpdateItem()
  self:UpdateStage()
end
function UIHardChapterDetailItem:UpdateStage()
  local stageData = TableData.GetStageData(self.difficultyStoryData.id)
  local stageRecord = NetCmdStageRecordData:GetStageRecordById(self.difficultyStoryData.id, false)
  local isNext = stageRecord == nil and true or stageRecord.first_pass_time <= 0
  if stageData ~= nil then
    self.ui.mText_StageName.text = self.difficultyStoryData.name.str
    self.isUnlock = NetCmdDungeonData:IsUnLockDifficultStory(self.difficultyStoryData.id)
    setactive(self.ui.mTrans_Star, self.difficultyStoryData.type ~= GlobalConfig.StoryType.StoryBattle and 0 < stageData.challenge_list.Count)
    self.ui.mAnimator_Self:SetBool("Unlock", self.isUnlock)
  end
  if self.difficultyStoryData ~= nil and self.difficultyStoryData.unlock == false then
    self.hasAnalysis = true
  end
  self:UpdateChallenge(stageRecord)
end
function UIHardChapterDetailItem:RefreshStage()
  if self.difficultyStoryData then
    self:UpdateStage()
  end
end
function UIHardChapterDetailItem:UpdateChallenge(cmdData)
  local finishNum = 0
  if cmdData then
    for i, obj in ipairs(self.challengeList) do
      local isFinish = cmdData ~= nil and i <= cmdData.ChallengeNum
      setactive(obj.tranOn, isFinish)
      if isFinish then
        finishNum = finishNum + 1
      end
    end
  else
    for i, obj in ipairs(self.challengeList) do
      setactive(obj.tranOn, false)
    end
  end
  local canShow = self.hasAnalysis
  self.ui.mAnimator_Self:SetBool("Start", canShow)
  self.ui.mArchivesUtil_Cast.canRotate = canShow
  self.ui.mArchivesUtil_Cast.animLayer = 3
  setactive(self.ui.mTrans_Finish, finishNum == #self.challengeList)
  setactive(self.ui.mTrans_UnFinish, finishNum < #self.challengeList)
end
function UIHardChapterDetailItem:SetSelected(isSelect)
  self.ui.mBtn_Self.interactable = not isSelect
end
function UIHardChapterDetailItem:SetIsCurrentStage(isSelect)
  setactive(self.ui.mTrans_ImgArrow, isSelect)
end
function UIHardChapterDetailItem:SetIsLastStory(isLast)
  self.isLast = isLast
end
