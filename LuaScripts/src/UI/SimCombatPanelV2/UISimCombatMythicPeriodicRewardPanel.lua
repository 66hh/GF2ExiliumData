require("UI.UIBasePanel")
require("UI.SimCombatPanelV2.Items.SimCombatMythicPeriodicRewardItem")
UISimCombatMythicPeriodicRewardPanel = class("UISimCombatMythicPeriodicRewardPanel", UIBasePanel)
UISimCombatMythicPeriodicRewardPanel.__index = UISimCombatMythicPeriodicRewardPanel
local self = UISimCombatMythicPeriodicRewardPanel
function UISimCombatMythicPeriodicRewardPanel:ctor(obj)
  UISimCombatMythicPeriodicRewardPanel.super.ctor(self, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicPeriodicRewardPanel:OnInit(root)
  self.super.SetRoot(UISimCombatMythicPeriodicRewardPanel, root)
  self.ui = {}
  self.isShow = false
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicPeriodicRewardPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicPeriodicRewardPanel)
  end
  self.scrollFade = self.ui.mScrollListChild_Content:GetComponent(typeof(CS.ScrollFade))
  self.scrollFade.enabled = false
  self.fadeInTimer = nil
  self:InitData()
  self:InitPeriodicRewardItems()
end
function UISimCombatMythicPeriodicRewardPanel:InitData()
  self.periodicRewardItems = {}
  self.itemTemplate = self.ui.mTrans_RewardItem
end
function UISimCombatMythicPeriodicRewardPanel:InitPeriodicRewardItems()
  self.ItemCount = TableData.listSimCombatMythicGroupDatas.Count
  for i = 1, self.ItemCount do
    local item
    if self.periodicRewardItems[i] == nil then
      item = SimCombatMythicPeriodicRewardItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Content)
      table.insert(self.periodicRewardItems, item)
    else
      item = self.periodicRewardItems[i]
    end
    local data = TableData.listSimCombatMythicGroupDatas:GetDataByIndex(i - 1)
    item:SetData(data)
  end
end
function UISimCombatMythicPeriodicRewardPanel:OnShowFinish()
  if self.isShow then
    return
  end
  self:StartPlayFadeIn()
  self.isShow = true
end
function UISimCombatMythicPeriodicRewardPanel:StartPlayFadeIn()
  self.fadeInTimer = TimerSys:DelayCall(0.1, function()
    self:ItemFadeIn(1)
  end)
end
function UISimCombatMythicPeriodicRewardPanel:ItemFadeIn(index)
  if index > self.ItemCount then
    return
  end
  local item = self.periodicRewardItems[index]
  item:PlayFadeIn()
  local itemFadeInTime = item:GetFadeInTime()
  self.fadeInTimer = TimerSys:DelayCall(itemFadeInTime, function()
    self:ItemFadeIn(index + 1)
  end)
end
function UISimCombatMythicPeriodicRewardPanel:CloseFadeInTime()
  if self.fadeInTimer ~= nil then
    self.fadeInTimer:Abort()
    self.fadeInTimer = nil
  end
end
function UISimCombatMythicPeriodicRewardPanel:OnHide()
  self.isShow = false
  self:CloseFadeInTime()
end
function UISimCombatMythicPeriodicRewardPanel:OnClose()
  self:ReleaseCtrlTable(self.periodicRewardItems)
  self:CloseFadeInTime()
  self.isShow = false
end
