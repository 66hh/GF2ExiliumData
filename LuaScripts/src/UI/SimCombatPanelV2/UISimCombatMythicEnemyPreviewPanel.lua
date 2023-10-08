require("UI.UIBasePanel")
require("UI.SimCombatPanelV2.SimCombatMythicEnemyPreviewItem")
UISimCombatMythicEnemyPreviewPanel = class("UISimCombatMythicEnemyPreviewPanel", UIBasePanel)
UISimCombatMythicEnemyPreviewPanel.__index = UISimCombatMythicEnemyPreviewPanel
local self = UISimCombatMythicEnemyPreviewPanel
function UISimCombatMythicEnemyPreviewPanel:ctor(obj)
  UISimCombatMythicEnemyPreviewPanel.super.ctor(self, obj)
  obj.Type = UIBasePanelType.Dialog
end
function UISimCombatMythicEnemyPreviewPanel:OnInit(root, params)
  self.super.SetRoot(UISimCombatMythicEnemyPreviewPanel, root)
  self.ui = {}
  self.groupId = params[1]
  self.stageLevelId = params[2]
  self.stageLevelIndex = params[3]
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicEnemyPreviewPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicEnemyPreviewPanel)
  end
  self.scrollFade = self.ui.mScrollListChild_Content:GetComponent(typeof(CS.ScrollFade))
  self:InitData()
  self:InitEnemyItems()
end
function UISimCombatMythicEnemyPreviewPanel:InitData()
  self.enemyItems = {}
  self.itemTemplate = self.ui.mTran_EnemyItem
  local stageLevelConfig = TableData.listSimCombatMythicLevelDatas:GetDataById(self.stageLevelId)
  local baseReq = stageLevelConfig.base_require
  local advanceReq = stageLevelConfig.advance_require
  self.stageLevelTaskData = {}
  table.insert(self.stageLevelTaskData, baseReq)
  for i = 1, advanceReq.Length do
    table.insert(self.stageLevelTaskData, advanceReq[i - 1])
  end
end
function UISimCombatMythicEnemyPreviewPanel:InitEnemyItems()
  local finishTaskIndex = NetCmdSimCombatMythicData:GetStageLevelFinishTaskIndex(self.groupId, self.stageLevelIndex)
  for k, v in ipairs(self.stageLevelTaskData) do
    local item
    if self.enemyItems[k] == nil then
      item = SimCombatMythicEnemyPreviewItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Content)
      table.insert(self.enemyItems, item)
    else
      item = self.enemyItems[k]
    end
    local isUnlock = k <= finishTaskIndex
    item:SetData(v, k, isUnlock)
  end
end
function UISimCombatMythicEnemyPreviewPanel:OnShowFinish()
  self.scrollFade:SetOnEnableScrollFade(true)
  self.scrollFade.enabled = false
  self.scrollFade.enabled = true
end
function UISimCombatMythicEnemyPreviewPanel:OnHide()
end
function UISimCombatMythicEnemyPreviewPanel:OnClose()
  self:ReleaseCtrlTable(self.enemyItems)
end
