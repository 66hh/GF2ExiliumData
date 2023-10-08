require("UI.UIBasePanel")
require("UI.SimCombatPanel.UISimCombatRunesPanelView")
require("UI.SimCombatPanel.Item.SimCombatRuneItem")
require("UI.SimCombatPanel.Item.UISimCombatTabButtonItem")
require("UI.BattleIndexPanel.UIBattleDetailDialog")
UISimCombatRunesPanel = class("UISimCombatRunesPanel", UIBasePanel)
UISimCombatRunesPanel.__index = UISimCombatRunesPanel
UISimCombatRunesPanel.mView = nil
UISimCombatRunesPanel.typeDataList = nil
UISimCombatRunesPanel.stageDataList = {}
UISimCombatRunesPanel.labelList = {}
UISimCombatRunesPanel.stageList = {}
UISimCombatRunesPanel.curLabel = nil
UISimCombatRunesPanel.curStage = nil
UISimCombatRunesPanel.lastIndex = 0
UISimCombatRunesPanel.curLabelId = -1
function UISimCombatRunesPanel:ctor()
  UISimCombatRunesPanel.super.ctor(self)
end
function UISimCombatRunesPanel:OnHide()
  self:Show(false)
end
function UISimCombatRunesPanel:OnInit(root, data)
  self:SetRoot(root)
  UISimCombatRunesPanel.mData = data
  UISimCombatRunesPanel.mView = UISimCombatRunesPanelView
  UISimCombatRunesPanel.mView:InitCtrl(root)
  UISimCombatRunesPanel.typeDataList = nil
  UISimCombatRunesPanel.stageDataList = {}
  UISimCombatRunesPanel.labelList = {}
  UISimCombatRunesPanel.stageList = {}
  UISimCombatRunesPanel.curLabel = nil
  UISimCombatRunesPanel.curStage = nil
  UIUtils.GetButtonListener(self.mView.mBtn_Close.gameObject).onClick = function(gObj)
    UISimCombatRunesPanel:onClickExit()
  end
  UIUtils.GetButtonListener(self.mView.mBtn_CommanderCenter.gameObject).onClick = function()
    UIBattleIndexPanelV2.currentType = -1
    UIManager.JumpToMainPanel()
  end
  self:InitData()
  self:UpdatePanel()
end
function UISimCombatRunesPanel:OnReleaseUISimCombatRunesPanel()
  self.typeDataList = nil
  self.stageDataList = {}
  self.labelList = {}
  self.stageList = {}
  self.curLabel = nil
  self.curStage = nil
end
function UISimCombatRunesPanel.ClearUIRecordData()
  UISimCombatRunesPanel.curLabelId = -1
  UIBattleIndexPanel.currentType = -1
  UIChapterInfoPanel.curDiff = 1
end
function UISimCombatRunesPanel:InitData()
  self.typeDataList = NetCmdSimulateBattleData:GetSimulateLabelByType(self.mData)
  for i = 0, TableData.listSimCombatRunesDatas.Count - 1 do
    local data = TableData.listSimCombatRunesDatas[i]
    if data then
      if self.stageDataList[data.type] == nil then
        self.stageDataList[data.type] = {}
      end
      table.insert(self.stageDataList[data.type], data)
    end
  end
  for _, item in ipairs(self.stageDataList) do
    if next(item) then
      table.sort(item, function(a, b)
        return tonumber(a.sequence) < tonumber(b.sequence)
      end)
    end
  end
  local data = TableData.listSimCombatEntranceDatas:GetDataById(self.mData)
end
function UISimCombatRunesPanel:UpdatePanel()
  self:UpdateLabel()
end
function UISimCombatRunesPanel:UpdateLabel()
  if self.typeDataList == nil then
    return
  end
  local label = self.typeDataList
  local tempCurLabel, prefab
  if #self.labelList < label.Count then
    prefab = UIUtils.GetGizmosPrefab("SimCombat/SimCombatRunesTabListItemV2.prefab", self)
  end
  for i = 0, label.Count - 1 do
    local data = label[i]
    local item
    if i + 1 <= #self.labelList then
      item = self.labelList[i + 1]
    elseif prefab then
      local obj = instantiate(prefab)
      item = UISimCombatTabButtonItem.New()
      UIUtils.AddListItem(obj, self.mView.mTrans_RuneType.transform)
      item:InitCtrl(obj.transform)
      UIUtils.GetButtonListener(item:GetSelfButton().gameObject).onClick = function(gObj)
        self:OnClickLabel(item)
      end
      table.insert(self.labelList, item)
    end
    item:SetName(data.id, data.label_name.str, "")
    if data.id == self.curLabelId then
      tempCurLabel = item
    end
  end
  if tempCurLabel then
    self:OnClickLabel(tempCurLabel)
  else
    self:OnClickLabel(self.labelList[1])
  end
end
function UISimCombatRunesPanel:OnClickLabel(item)
  if not item then
    return
  end
  if self.curLabel ~= nil then
    if item.tagId ~= self.curLabel.tagId then
      self.curLabel:SetItemState(false)
    else
      return
    end
  end
  item:SetItemState(true)
  self.curLabel = item
  self.curLabelId = item.tagId
  self:onClickCloseLauncher()
  TimerSys:DelayCall(0.1, function(obj)
    self:UpdateStageList(self.curLabel.tagId)
    self.mView.mAnimator:SetTrigger("Next")
    self.mView.mScroll:ScrollToCell(tonumber(self.lastIndex), 3500)
  end)
end
function UISimCombatRunesPanel:UpdateStageList(tagId)
  local stage = self.stageDataList[tagId]
  local labelData = self:GetLabelDataById(tagId)
  if not next(stage) then
    return
  end
  local prefab
  if #self.stageList < #stage then
    prefab = UIUtils.GetGizmosPrefab("SimCombat/SimCombatRunesChapterSelListItemV2.prefab", self)
  end
  for _, item in ipairs(self.stageList) do
    item:SetData(nil)
  end
  for i, data in ipairs(stage) do
    local item
    if i <= #self.stageList then
      item = self.stageList[i]
    elseif prefab then
      local obj = instantiate(prefab)
      item = SimCombatRuneItem.New()
      UIUtils.AddListItem(obj, self.mView.mTrans_RuneList.transform)
      item:InitCtrl(obj.transform)
      if i % 2 == 1 then
        item.mTrans_Root.localPosition = Vector3(0, -140, 0)
      end
      table.insert(self.stageList, item)
    end
    item:SetData(data, labelData, i == #stage)
    UIUtils.GetButtonListener(item.mBtn_Equip.gameObject).onClick = function(gObj)
      self:OnClickStage(item)
    end
    if item.isUnLock then
      self.lastIndex = item.mData.sequence
    end
  end
end
function UISimCombatRunesPanel:OnClickStage(item)
  if item then
    if self.curStage and self.curStage.mData.id == item.mData.id then
      return
    end
    local record = NetCmdStageRecordData:GetStageRecordById(item.stageData.id)
    self:ShowStageInfo(item.stageData, record, item)
  end
end
function UISimCombatRunesPanel:ShowStageInfo(stageData, stageRecord, item)
  if self.curStage then
    self.curStage:UpdateState(false)
  end
  item:UpdateState(true)
  self.curStage = item
  UIBattleDetailDialog.OpenBySimCombatData(UIDef.UISimCombatRunesPanel, stageData, stageRecord, item.mData, item.isUnLock, function()
    UISimCombatRunesPanel:onClickCloseLauncher()
  end)
end
function UISimCombatRunesPanel:onClickCloseLauncher()
  if self.curStage then
    self.curStage:UpdateState(false)
    self.curStage = nil
  end
end
function UISimCombatRunesPanel:GetLabelDataById(id)
  for i = 0, self.typeDataList.Count - 1 do
    if self.typeDataList[i].id == id then
      return self.typeDataList[i]
    end
  end
end
function UISimCombatRunesPanel:onClickExit()
  self.curLabelId = -1
  UIManager.CloseUI(UIDef.UISimCombatRunesPanel)
  self:OnReleaseUISimCombatRunesPanel()
end
