require("UI.UIBasePanel")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
UISimCombatMythicWeeklyStartPanel = class("UISimCombatMythicWeeklyStartPanel", UIBasePanel)
UISimCombatMythicWeeklyStartPanel.__index = UISimCombatMythicWeeklyStartPanel
local self = UISimCombatMythicWeeklyStartPanel
function UISimCombatMythicWeeklyStartPanel:ctor(obj)
  UISimCombatMythicWeeklyStartPanel.super.ctor(self, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicWeeklyStartPanel:OnInit(root)
  self.super.SetRoot(UISimCombatMythicWeeklyStartPanel, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  setactive(self.ui.mText_Time.gameObject, false)
  local reward = NetCmdSimCombatMythicData:GetFinishReward()
  local rewardCount = reward.Count
  setactive(self.ui.mTran_RewardTip.gameObject, 0 < rewardCount)
  setactive(self.ui.mTran_NoRewardTip.gameObject, rewardCount == 0)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicWeeklyStartPanel)
    local reward = NetCmdSimCombatMythicData:GetFinishReward()
    if reward.Count > 0 then
      local data = {}
      local itemTable = {}
      data[1] = itemTable
      for k, v in pairs(reward) do
        table.insert(itemTable, {ItemId = k, ItemNum = v})
      end
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, data)
    end
    SimCombatMythicConfig.IsReadyToStartTutorial = true
  end
  SimCombatMythicConfig.ShowWeeklyReset.IsShow = true
  if 0 < rewardCount then
    SimCombatMythicConfig.ShowWeeklyReset.ShowType = 1
  elseif not NetCmdSimCombatMythicData:IsEnteredMythic() then
    NetCmdSimCombatMythicData:SetEnteredEndMythic()
    SimCombatMythicConfig.ShowWeeklyReset.ShowType = -1
  else
    SimCombatMythicConfig.ShowWeeklyReset.ShowType = 0
  end
end
function UISimCombatMythicWeeklyStartPanel:OnShowFinish()
  local time = NetCmdSimCombatMythicData:GetNextWeeklyStartTimeOffset()
  if 0 < time then
    local timeStr = CS.TimeUtils.LeftTimeToShowFormat(time)
    self.ui.mText_Time.text = string_format(TableData.GetHintById(103130), timeStr)
    setactive(self.ui.mText_Time.gameObject, true)
  else
    setactive(self.ui.mText_Time.gameObject, false)
  end
end
function UISimCombatMythicWeeklyStartPanel:OnHide()
end
function UISimCombatMythicWeeklyStartPanel:OnClose()
end
