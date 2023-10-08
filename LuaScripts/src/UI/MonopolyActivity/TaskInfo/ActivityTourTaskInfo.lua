require("UI.UIBaseCtrl")
require("UI.MonopolyActivity.TaskInfo.ActivityTourStageStepItem")
ActivityTourTaskInfo = class("ActivityTourTaskInfo", UIBaseCtrl)
ActivityTourTaskInfo.__index = ActivityTourTaskInfo
function ActivityTourTaskInfo:ctor()
  self.super.ctor(self)
end
function ActivityTourTaskInfo:InitCtrl(ui)
  self.ui = ui
  self.mTaskItem = {}
  self.mFailedTaskItem = {}
  self:RefreshAll()
end
function ActivityTourTaskInfo:RegisterMessage()
end
function ActivityTourTaskInfo:UnRegisterMessage()
end
function ActivityTourTaskInfo:Show(isShow)
  if isShow then
    self:RefreshAll()
  else
    self:FadeOutWinTask()
    self:FadeOutFailedTask()
  end
  UIUtils.AnimatorFadeInOut(self.ui.mAnimator_TaskTitle, isShow)
  UIUtils.AnimatorFadeInOut(self.ui.mAnimator_TaskRoot, isShow)
end
function ActivityTourTaskInfo:RefreshAll()
  self:RefreshRoundInfo()
  self:RefreshWinTaskList()
  self:RefreshFailedTaskList()
end
function ActivityTourTaskInfo:RefreshRoundInfo()
  if MonopolyWorld.IsGmMode then
    return
  end
  self.ui.mText_TaskProgress.text = UIUtils.StringFormatWithHintId(112016, NetCmdMonopolyData.currentRound, MonopolyWorld.MpData.levelData.max_round)
end
function ActivityTourTaskInfo:RefreshWinTaskList(refreshTaskId)
  local taskList = MonopolyWorld.MpData.taskList
  for i = 0, taskList.Count - 1 do
    local taskItem = self.mTaskItem[i]
    if not taskItem then
      taskItem = ActivityTourStageStepItem.New()
      taskItem:InitCtrl(self.ui.mScrollListChild_Task.childItem, self.ui.mScrollListChild_Task.transform, false)
      self.mTaskItem[i] = taskItem
    end
    local taskId = taskList[i]
    local needRefresh = true
    if refreshTaskId ~= nil then
      needRefresh = refreshTaskId == taskId
    end
    if needRefresh then
      taskItem:SetData(taskId, refreshTaskId == nil)
    end
  end
end
function ActivityTourTaskInfo:RefreshFailedTaskList(refreshTaskId)
  local taskList = MonopolyWorld.MpData.failedTaskList
  local taskCount = taskList.Count
  setactive(self.ui.mTrans_FailedTaskRoot, 0 < taskCount)
  if taskCount <= 0 then
    return
  end
  for i = 0, taskCount - 1 do
    local taskItem = self.mFailedTaskItem[i]
    if not taskItem then
      taskItem = ActivityTourStageStepItem.New()
      taskItem:InitCtrl(self.ui.mSCL_FailedTask.childItem, self.ui.mSCL_FailedTask.transform, true)
      self.mFailedTaskItem[i] = taskItem
    end
    local taskId = taskList[i]
    local needRefresh = true
    if refreshTaskId ~= nil then
      needRefresh = refreshTaskId == taskId
    end
    if needRefresh then
      taskItem:SetData(taskId, refreshTaskId == nil)
    end
  end
end
function ActivityTourTaskInfo:FadeOutWinTask()
  for i, taskItem in pairs(self.mTaskItem) do
    if taskItem then
      taskItem:FadeOut()
    end
  end
end
function ActivityTourTaskInfo:FadeOutFailedTask()
  for i, taskItem in pairs(self.mFailedTaskItem) do
    if taskItem then
      taskItem:FadeOut()
    end
  end
end
function ActivityTourTaskInfo:Release()
  self:UnRegisterMessage()
  self:ReleaseCtrlTable(self.mTaskItem, true)
  self.mTaskItem = nil
  self:ReleaseCtrlTable(self.mFailedTaskItem, true)
  self.mFailedTaskItem = nil
  self:OnRelease(true)
end
