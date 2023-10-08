require("UI.UIBaseCtrl")
ActivityTourStageStepItem = class("ActivityTourStageStepItem", UIBaseCtrl)
ActivityTourStageStepItem.__index = ActivityTourStageStepItem
local AnimType = {
  FadeIn = 0,
  FadeOut = 1,
  Complete = 2,
  CompleteToNormal = 3,
  CompleteFadeIn = 4,
  CompleteFadeOut = 5
}
function ActivityTourStageStepItem:ctor()
  self.super.ctor(self)
end
function ActivityTourStageStepItem:InitCtrl(itemPrefab, parent, isFailedTask)
  self.mIsFailedTask = isFailedTask
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self.isComplete = false
  self.ui.mAnimator_Root.keepAnimatorControllerStateOnDisable = true
  if self.mIsFailedTask then
    function self.ui.mAnimKeyEvent_Refresh.onAnimationEvent(eventName)
      self:RefreshContent()
    end
  end
end
function ActivityTourStageStepItem:SetData(taskId, isPlayFadeIn)
  self.mData = TableData.listMonopolyWinConditionDatas:GetDataById(taskId)
  if self.mData == nil then
    print_error("MonopolyWinCondition表中没有找到ID：" .. tostring(taskId) .. "的数据")
    return
  end
  self.mProgressData = MonopolyWorld.MpData:GetTaskData(taskId)
  self:Refresh(isPlayFadeIn)
end
function ActivityTourStageStepItem:Refresh(isPlayFadeIn)
  self.mCurNum = math.max(self.mProgressData.Num, 0)
  self.mMaxNum = self.mData.condition_num
  local oldIsComplete = self.isComplete
  self.isComplete = self.mCurNum >= self.mMaxNum
  local newComplete = not isPlayFadeIn and not oldIsComplete and self.isComplete
  local delayRefresh = self.mIsFailedTask and newComplete
  if not delayRefresh then
    self:RefreshContent()
  end
  if isPlayFadeIn then
    if self.isComplete then
      self:PlayAnimator(AnimType.CompleteFadeIn)
    else
      self:PlayAnimator(AnimType.FadeIn)
    end
    return
  end
  if newComplete then
    self:PlayAnimator(AnimType.Complete)
  end
end
function ActivityTourStageStepItem:RefreshContent()
  if self.mData == nil then
    return
  end
  self.ui.mText_Desc.text = UIUtils.StringFormatWithHintId(270155, self.mData.name.str, self.mCurNum, self.mMaxNum)
end
function ActivityTourStageStepItem:FadeOut()
  if self.isComplete then
    self:PlayAnimator(AnimType.CompleteFadeOut)
  else
    self:PlayAnimator(AnimType.FadeOut)
  end
end
function ActivityTourStageStepItem:PlayAnimator(switch)
  if not self.mIsFailedTask then
    self.ui.mAnimator_Root:SetInteger("Switch", switch)
    return
  end
  if switch == AnimType.FadeIn or switch == AnimType.CompleteFadeIn then
    UIUtils.AnimatorFadeIn(self.ui.mAnimator_Root)
  elseif switch == AnimType.FadeOut or switch == AnimType.CompleteFadeOut then
    UIUtils.AnimatorFadeOut(self.ui.mAnimator_Root)
  else
    self.ui.mAnimator_Root:ResetTrigger("FadeIn")
    self.ui.mAnimator_Root:ResetTrigger("FadeIn")
    self.ui.mAnimator_Root:SetTrigger("Done")
  end
end
