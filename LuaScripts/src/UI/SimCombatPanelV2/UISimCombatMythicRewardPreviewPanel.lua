require("UI.UIBasePanel")
require("UI.SimCombatPanelV2.SimCombatMythicRewardPreviewItem")
UISimCombatMythicRewardPreviewPanel = class("UISimCombatMythicRewardPreviewPanel", UIBasePanel)
UISimCombatMythicRewardPreviewPanel.__index = UISimCombatMythicRewardPreviewPanel
local self = UISimCombatMythicRewardPreviewPanel
function UISimCombatMythicRewardPreviewPanel:ctor(obj)
  UISimCombatMythicRewardPreviewPanel.super.ctor(self, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicRewardPreviewPanel:OnInit(root, params)
  self.super.SetRoot(UISimCombatMythicRewardPreviewPanel, root)
  self.ui = {}
  self.groupId = params[1]
  self.stageLevelId = params[2]
  self.stageLevelIndex = params[3]
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicRewardPreviewPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicRewardPreviewPanel)
  end
  self.scrollFade = self.ui.mScrollListChild_Content:GetComponent(typeof(CS.ScrollFade))
  self:InitData()
  self:InitRewardItems()
end
function UISimCombatMythicRewardPreviewPanel:InitData()
  self.rewardItems = {}
  self.itemTemplate = self.ui.mTran_RewardItem
  local stageLevelConfig = TableData.listSimCombatMythicLevelDatas:GetDataById(self.stageLevelId)
  local baseReq = stageLevelConfig.base_require
  local advanceReq = stageLevelConfig.advance_require
  self.stageLevelTaskData = {}
  table.insert(self.stageLevelTaskData, baseReq)
  for i = 1, advanceReq.Length do
    table.insert(self.stageLevelTaskData, advanceReq[i - 1])
  end
end
function UISimCombatMythicRewardPreviewPanel:InitRewardItems()
  local finishTaskIndex = NetCmdSimCombatMythicData:GetStageLevelFinishTaskIndex(self.groupId, self.stageLevelIndex)
  for k, v in ipairs(self.stageLevelTaskData) do
    local item
    if self.rewardItems[k] == nil then
      item = SimCombatMythicRewardPreviewItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Content)
      table.insert(self.rewardItems, item)
    else
      item = self.rewardItems[k]
    end
    local isFinish = k <= finishTaskIndex
    item:SetData(v, k, isFinish)
  end
end
function UISimCombatMythicRewardPreviewPanel:OnShowFinish()
  self.scrollFade:SetOnEnableScrollFade(true)
  self.scrollFade.enabled = false
  self.scrollFade.enabled = true
end
function UISimCombatMythicRewardPreviewPanel:OnHide()
end
function UISimCombatMythicRewardPreviewPanel:OnClose()
  self:ReleaseCtrlTable(self.rewardItems)
end
