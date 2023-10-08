require("UI.UIBasePanel")
require("UI.SimCombatPanelV2.Items.UISimCombatMythicStageLevelDetailItem")
UISimCombatMythicStageLevelDetailPanel = class("UISimCombatMythicStageLevelDetailPanel", UIBasePanel)
UISimCombatMythicStageLevelDetailPanel.__index = UISimCombatMythicStageLevelDetailPanel
local self = UISimCombatMythicStageLevelDetailPanel
function UISimCombatMythicStageLevelDetailPanel:ctor(obj)
  UISimCombatMythicStageLevelDetailPanel.super.ctor(self, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicStageLevelDetailPanel:OnInit(root, params)
  self.super.SetRoot(UISimCombatMythicStageLevelDetailPanel, root)
  self.ui = {}
  self.groupId = params[1]
  self.stageLevelId = params[2]
  self.stageLevelIndex = params[3]
  self:LuaUIBindTable(root, self.ui)
  self.isShow = false
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicStageLevelDetailPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicStageLevelDetailPanel)
  end
  self.scrollFade = self.ui.mScrollListChild_Content:GetComponent(typeof(CS.ScrollFade))
  self:InitData()
  self:InitItems()
end
function UISimCombatMythicStageLevelDetailPanel:InitData()
  self.LevelItems = {}
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
function UISimCombatMythicStageLevelDetailPanel:InitItems()
  local finishTaskIndex = NetCmdSimCombatMythicData:GetStageLevelFinishTaskIndex(self.groupId, self.stageLevelIndex)
  for k, v in ipairs(self.stageLevelTaskData) do
    local item
    if self.LevelItems[k] == nil then
      item = UISimCombatMythicStageLevelDetailItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Content)
      table.insert(self.LevelItems, item)
    else
      item = self.LevelItems[k]
    end
    local isFinish = k <= finishTaskIndex
    item:SetData(v, k, isFinish)
  end
end
function UISimCombatMythicStageLevelDetailPanel:OnShowFinish()
  if self.isShow then
    return
  end
  self.scrollFade:SetOnEnableScrollFade(true)
  self.scrollFade.enabled = false
  self.scrollFade.enabled = true
  self.isShow = true
end
function UISimCombatMythicStageLevelDetailPanel:OnHide()
  self.isShow = false
end
function UISimCombatMythicStageLevelDetailPanel:OnClose()
  self:ReleaseCtrlTable(self.LevelItems)
  self.isShow = false
end
