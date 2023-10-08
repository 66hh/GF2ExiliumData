require("UI.UIBasePanel")
ActivityTourSettlementBase = class("ActivityTourSettlementBase", UIBasePanel)
ActivityTourSettlementBase.__index = ActivityTourSettlementBase
function ActivityTourSettlementBase:ctor(csPanel)
  ActivityTourSettlementBase.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourSettlementBase:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
  self.listTask = {}
  self.listReward = {}
end
function ActivityTourSettlementBase:OnInit(root, data)
  self.canClickClose = false
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
end
function ActivityTourSettlementBase:OnShowStart()
  self:Refresh()
end
function ActivityTourSettlementBase:OnClose()
  self.canClickClose = false
  self:ReleaseCtrlTable(self.listTask, true)
  self:ReleaseCtrlTable(self.listReward, true)
end
function ActivityTourSettlementBase:OnRelease()
  self.ui = nil
end
function ActivityTourSettlementBase:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnBtnClose()
  end
end
function ActivityTourSettlementBase:GetTipAnimLength()
  return LuaUtils.GetAnimationClipLength(self.ui.mAnimator_Root, "GrpTips_FadeInOut")
end
function ActivityTourSettlementBase:OnBtnClose()
  if not self.canClickClose then
    return
  end
  self.ui.mAnimator_Root:SetTrigger("GrpBg_FadeOut")
  self.ui.mAnimator_Root:SetTrigger("GrpInfo_FadeOut")
  self.canClickClose = false
  local length = LuaUtils.GetAnimationClipLength(self.ui.mAnimator_Root, "GrpBg_FadeOut")
  TimerSys:DelayCall(length, function()
    self:CloseSelf()
  end)
end
function ActivityTourSettlementBase:CloseSelf()
  UIManager.CloseUI(UIDef.ActivityTourSettlementBase)
end
function ActivityTourSettlementBase:RefreshReason()
end
function ActivityTourSettlementBase:Refresh()
  self:RefreshReason()
  setactive(self.ui.mTrans_Tip.gameObject, true)
  setactive(self.ui.mTrans_Info.gameObject, false)
  local length = self:GetTipAnimLength()
  TimerSys:DelayCall(length, function()
    setactive(self.ui.mTrans_Tip.gameObject, false)
    setactive(self.ui.mTrans_Info.gameObject, true)
    self:RefreshInfo()
  end)
end
function ActivityTourSettlementBase:RefreshInfo()
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
  self.ui.mAnimator_Root:SetTrigger("GrpBg_FadeIn")
  self.ui.mAnimator_Root:SetTrigger("GrpInfo_FadeIn")
  local time = LuaUtils.GetAnimationClipLength(self.ui.mAnimator_Root, "GrpBg_FadeIn")
  time = time + 1
  TimerSys:DelayCall(time, function()
    self.canClickClose = true
  end)
  self:RefreshTaskInfo()
  self:RefreshRewardInfo()
  self:RefreshChr()
end
function ActivityTourSettlementBase:RefreshTaskInfo()
  local config = MonopolyWorld:GetLevelData()
  if not config then
    return
  end
  if config.quest_id.Count <= 0 then
    setactive(self.ui.mTrans_Task.gameObject, false)
    return
  end
  setactive(self.ui.mTrans_Task.gameObject, true)
  local index = 1
  for i = 0, config.quest_id.Count - 1 do
    local taskId = config.quest_id[i]
    local conditionData = TableData.listMonopolyWinConditionDatas:GetDataById(taskId)
    if conditionData then
      local taskItem = self.listTask[index]
      if taskItem == nil then
        taskItem = ActivityTourSettlementTaskItem.New()
        taskItem:InitCtrl(self.ui.mTrans_TaskChildItem.gameObject, self.ui.mTrans_TaskChildRoot)
        table.insert(self.listTask, taskItem)
      end
      setactive(taskItem:GetRoot(), true)
      taskItem:Refresh(conditionData)
      index = index + 1
    end
  end
  for i = index, #self.listTask do
    setactive(self.listTask[i]:GetRoot(), false)
  end
end
function ActivityTourSettlementBase:RefreshRewardInfo()
  local listItem = {
    {itemId = 1, itemNum = 11},
    {itemId = 2, itemNum = 22},
    {itemId = 3, itemNum = 33}
  }
  self:RefreshRewardInfoInternal(listItem, self.listReward, self.ui.mTrans_RewardContent)
end
function ActivityTourSettlementBase:RefreshRewardInfoInternal(listItem, listReward, parent)
  if #listItem <= 0 then
    return
  end
  local index = 1
  for i = 1, #listItem do
    local itemId = listItem[i].itemId
    local itemData = TableData.GetItemData(itemId)
    if itemData then
      local rewardItem = listReward[index]
      if rewardItem == nil then
        rewardItem = UICommonItem.New()
        rewardItem:InitCtrl(parent, true)
        table.insert(listReward, rewardItem)
      end
      setactive(rewardItem:GetRoot(), true)
      rewardItem:SetItemData(itemId, listItem[i].itemNum, false)
      index = index + 1
    end
  end
  for i = index, #listReward do
    setactive(listReward[i]:GetRoot(), false)
  end
end
function ActivityTourSettlementBase:RefreshChr()
end
