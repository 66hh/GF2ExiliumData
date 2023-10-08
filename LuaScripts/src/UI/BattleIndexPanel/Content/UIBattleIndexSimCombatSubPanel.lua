require("UI.BattleIndexPanel.Item.UIBattleIndexSimCombatItem")
UIBattleIndexSimCombatSubPanel = class("UIBattleIndexSimCombatSubPanel", UIBaseView)
UIBattleIndexSimCombatSubPanel.__index = UIBattleIndexSimCombatSubPanel
UIBattleIndexSimCombatSubPanel.CurSimType = nil
UIBattleIndexSimCombatSubPanel.tabList = {}
function UIBattleIndexSimCombatSubPanel:__InitCtrl()
end
function UIBattleIndexSimCombatSubPanel:InitCtrl(root)
  self.ui = {}
  self:SetRoot(root)
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
  self.chapterList = TableData.GetStageIndexSimCombatList()
  self:InitTabs()
end
function UIBattleIndexSimCombatSubPanel:InitTabs()
  for i = 0, self.chapterList.Count - 1 do
    do
      local data = self.chapterList[i]
      local item
      if self.tabList[i + 1] == nil then
        item = UIBattleIndexSimCombatItem.New()
        item:InitCtrl(self.ui.mTrans_Content)
        table.insert(self.tabList, item)
      else
        item = self.tabList[i + 1]
      end
      item:SetData(data)
      UIUtils.GetButtonListener(item.ui.mBtn_Root.gameObject).onClick = function()
        self:OnClickSimCombat(data.id, data.unlock)
      end
    end
  end
end
function UIBattleIndexSimCombatSubPanel:RefreshTabs()
  self.ui.mVirtualListEx_List.horizontalNormalizedPosition = self.contentPos
  for i = 0, self.chapterList.Count - 1 do
    local data = self.chapterList[i]
    if self.tabList[i + 1] ~= nil then
      self.tabList[i + 1]:SetData(data)
    end
  end
end
function UIBattleIndexSimCombatSubPanel:OnClickSimCombat(simType, unlockType)
  if TipsManager.NeedLockTips(unlockType) then
    return
  end
  local eType = StageType.__CastFrom(simType)
  if eType == StageType.NrtpvpStage then
    self:OnClickPVP()
  elseif eType == StageType.DifficultStage then
    self:OnClickHardChapter()
  else
    NetCmdStageRecordData:RequestStageRecordByType(eType, function(ret)
      if ret == ErrorCodeSuc then
        self:OpenSimCombatUI(simType)
      end
    end)
  end
end
function UIBattleIndexSimCombatSubPanel:OpenSimCombatUI(simType)
  self.contentPos = self.ui.mVirtualListEx_List.horizontalNormalizedPosition
  local eType = StageType.__CastFrom(simType)
  UIBattleIndexSimCombatSubPanel.CurSimType = simType
  if eType == StageType.DailyStage then
    UIManager.OpenUIByParam(UIDef.UISimCombatDailyPanel, simType)
  elseif eType == StageType.TowerStage then
    UIManager.OpenUIByParam(UIDef.UISimCombatTrainingPanel, simType)
  elseif eType == StageType.WeeklyStage then
    local curPlan = NetCmdSimulateBattleData:GetPlanByType(1)
    NetCmdSimulateBattleData:ReqSimCombatWeeklyPlanInfo(function()
      if curPlan ~= nil and curPlan.Id ~= NetCmdSimulateBattleData:GetPlanByType(1).Id then
        NetCmdSimulateBattleData:ReqSimCombatWeeklyInfo(function()
          self:OpenWeekly(NetCmdSimulateBattleData:GetPlanByType(1), simType)
        end)
      else
        self:OpenWeekly(curPlan, simType)
      end
    end)
  elseif eType == StageType.MythicStage then
    UIManager.OpenUIByParam(UIDef.UISimCombatMythicMainPanelV2, {})
  elseif eType == StageType.DutyStage then
    UIManager.OpenUIByParam(UIDef.UISimCombatProTalentPanel, simType)
  elseif eType == StageType.TutorialStage then
    UIManager.OpenUIByParam(UIDef.UISimCombatTutorialEntrancePanel, simType)
  end
end
function UIBattleIndexSimCombatSubPanel:OpenWeekly(plan, simType)
  if plan == nil then
    gfwarning("Invalid plan !!!!!!!!!!!!!")
    return
  end
  if CGameTime:GetTimestamp() > plan.CloseTime then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(108064))
    for i = 1, 3 do
      local key = AccountNetCmdHandler:GetUID() .. "_SimCombatWeeklyTeam" .. string.char(string.byte("A") + i - 1)
      PlayerPrefs.SetString(key, "")
    end
    return
  end
  UIManager.OpenUIByParam(UIDef.UIWeeklyEnterPanel, simType)
end
function UIBattleIndexSimCombatSubPanel:OnClickPVP()
  if not NetCmdPVPData.PVPIsOpen then
    NetCmdSimulateBattleData:ReqPlanData(3, function(ret)
      if ret then
        NetCmdPVPData:SetPvpSeason()
        if not NetCmdPVPData.PVPIsOpen then
          CS.PopupMessageManager.PopupString(TableData.GetHintById(226))
        end
      end
    end)
    return
  end
  NetCmdPVPData:RequestPVPInfo(function()
    UIManager.OpenUI(UIDef.UINRTPVPPanel)
    NetCmdPVPData:SetUnLockRedPoint(0)
  end)
end
function UIBattleIndexSimCombatSubPanel:OnClickHardChapter()
  UIManager.OpenUI(UIDef.UIHardChapterSelectPanelV2)
end
function UIBattleIndexSimCombatSubPanel:OnRelease()
  self.CurSimType = nil
  self.contentPos = nil
  for _, obj in pairs(UIBattleIndexSimCombatSubPanel.tabList) do
    gfdestroy(obj:GetRoot())
  end
  UIBattleIndexSimCombatSubPanel.tabList = {}
end
