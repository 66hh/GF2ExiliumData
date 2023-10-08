require("UI.UIBasePanel")
require("UI.SimCombatPanelV2.Items.SimCombatMythicStageLevelItem")
require("UI.SimCombatPanelV2.Items.UISimCombatMythicStageLevelDotItem")
require("UI.SimCombatPanelV2.SimCombatMythicStageTaskChooseItem")
require("UI.SimCombatPanelV2.SimCombatMythicConfig")
require("UI.CombatLauncherPanel.Item.UICommonEnemyItem")
require("UI.Common.UICommonItem")
UISimCombatMythicStageGroupDetailPanel = class("UISimCombatMythicStageGroupDetailPanel", UIBasePanel)
UISimCombatMythicStageGroupDetailPanel.__index = UISimCombatMythicStageGroupDetailPanel
local self = UISimCombatMythicStageGroupDetailPanel
function UISimCombatMythicStageGroupDetailPanel:ctor(obj)
  UISimCombatMythicStageGroupDetailPanel.super.ctor(self)
end
function UISimCombatMythicStageGroupDetailPanel:OnInit(root, groupId)
  self.super.SetRoot(UISimCombatMythicStageGroupDetailPanel, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.groupID = groupId
  self.selectedStageId = 0
  self:InitData()
  self:InitTopBar()
  self:InitTopInfo()
  self:InitLeftTab()
  self:InitRightTab()
  self:UpdatePanel()
  self:AddListener()
end
function UISimCombatMythicStageGroupDetailPanel:InitData()
  local curStageGroupId = NetCmdSimCombatMythicData:GetStageGroupLevelGroupId(self.groupID)
  local stageConfig = TableData.listSimCombatMythicConfigDatas:GetDataById(curStageGroupId)
  self.groupConfigData = TableData.listSimCombatMythicGroupDatas:GetDataById(self.groupID)
  self.stagesLevels = stageConfig.stage
  self.stageLevelsItemList = {}
  self.stageTaskChooseItemList = {}
  self.stageLevelTaskData = {}
  self.curSelectedStageLevelId = 0
  self.curSelectedStageLevelIndex = 0
  self.curSelectedStageLevelItem = nil
  self.curSelectedStageTask = 0
  self.enemyIconItems = {}
  self.rewardIconItems = {}
  function self.OnLoadingEnd()
    self:OnLoadingOver()
  end
end
function UISimCombatMythicStageGroupDetailPanel:InitTopBar()
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UISimCombatMythicStageGroupDetailPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function UISimCombatMythicStageGroupDetailPanel:InitTopInfo()
  self.ui.mText_TopTitle.text = self.groupConfigData.goup_name.str
  self.ui.mText_TopContent.text = self.groupConfigData.group_desc.str
  self.ui.mImage_TopBg.sprite = IconUtils.GetRogueIcon(self.groupConfigData.group_bg .. "_Detail")
end
function UISimCombatMythicStageGroupDetailPanel:InitLeftTab()
  for i = 1, self.stagesLevels.Length do
    do
      local item
      if self.stageLevelsItemList[i] == nil then
        item = SimCombatMythicStageLevelItem.New()
        item:InitCtrl(self.ui.mScrollListChild_GrpLeftList)
        item:SetClickCallBack(function()
          SimCombatMythicConfig.CurSelectedStageLevelTaskIndex = 0
          self:OnClickStageLevelItem(item)
        end)
        table.insert(self.stageLevelsItemList, item)
      else
        item = self.stageLevelsItemList[i]
      end
      item:SetData(self.groupID, self.stagesLevels[i - 1], i)
    end
  end
  self.ui.mScrollListChild_GrpLeftList.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = false
  self.ui.mScrollListChild_GrpLeftList.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = true
end
function UISimCombatMythicStageGroupDetailPanel:UpdateLeftTab()
end
function UISimCombatMythicStageGroupDetailPanel:InitRightTab()
  UIUtils.GetButtonListener(self.ui.mBtn_BtnStart.gameObject).onClick = function()
    SceneSys:OpenBattleSceneForMythic(self.groupID, self.curSelectedStageLevelIndex, self.curSelectedStageTaskIndex, self.curSelectedStageTask)
    NetCmdSimCombatMythicData:SetStageGroupTaskIsNew(self.groupID, self.curSelectedStageLevelIndex, self.curSelectedStageTaskIndex)
  end
end
function UISimCombatMythicStageGroupDetailPanel:UpdateRightPanel()
  local stageLevelConfig = TableData.listSimCombatMythicLevelDatas:GetDataById(self.curSelectedStageLevelId)
  self.ui.mText_StageLevelContent.text = stageLevelConfig.level_desc
  self.ui.mText_RecommendLv.text = string_format(TableData.GetHintById(103113), stageLevelConfig.recommend_level)
  self.ui.mImage_EnemyIcon.sprite = IconUtils.GetCharacterHeadFullName(stageLevelConfig.main_enemy)
  local taskData = {}
  local stageLevelConfig = TableData.listSimCombatMythicLevelDatas:GetDataById(self.curSelectedStageLevelId)
  local baseReq = stageLevelConfig.base_require
  table.insert(taskData, baseReq)
  local stageTaskIndex = 1
  local stageTaskId = taskData[stageTaskIndex]
  local mythicStageConfig = TableData.listSimCombatMythicStagesDatas:GetDataById(stageTaskId)
  self.ui.mText_TaskDesc.text = mythicStageConfig.require_desc.str
  self.curSelectedStageTask = stageTaskId
  self.curSelectedStageTaskIndex = stageTaskIndex
  local state = NetCmdSimCombatMythicData:GetStageLevelState(self.groupID, self.curSelectedStageLevelIndex)
  local isLock = state == SimCombatMythicConfig.StageLevelState.LOCK
  self:SetTaskEnemyInfo(stageTaskId)
  self:SetTaskRewardInfo(stageTaskId)
  self:UpdateTaskIsNew(isLock, stageTaskIndex)
  self:UpdateRightBottom()
end
function UISimCombatMythicStageGroupDetailPanel:UpdateTaskIsNew(isLock, stageTaskIndex)
  if isLock then
    setactive(self.ui.mTran_TaskNewMark.gameObject, false)
  else
    local isNew = NetCmdSimCombatMythicData:CheckStageGroupTaskIsNew(self.groupID, self.curSelectedStageLevelIndex, stageTaskIndex)
    setactive(self.ui.mTran_TaskNewMark.gameObject, isNew)
  end
end
function UISimCombatMythicStageGroupDetailPanel:SetTaskEnemyInfo(stageTaskId)
  local stageData = TableData.listStageDatas:GetDataById(stageTaskId)
  local stageConfig = TableData.listStageConfigDatas:GetDataById(stageData.stage_config)
  local enemiesCount = stageConfig.enemies.Count
  for i = 1, enemiesCount do
    do
      local item
      if self.enemyIconItems[i] == nil then
        item = UICommonEnemyItem.New()
        item:InitCtrl(self.ui.mScrollListChild_Enemy.gameObject)
        table.insert(self.enemyIconItems, item)
      else
        item = self.enemyIconItems[i]
      end
      local enemyId = stageConfig.enemies[i - 1]
      local enemyData = TableData.GetEnemyData(enemyId)
      item:SetData(enemyData, stageData.stage_class)
      item:EnableLv(true)
      UIUtils.GetButtonListener(item.mBtn_OpenDetail.gameObject).onClick = function()
        CS.RoleInfoCtrlHelper.Instance:InitSysEnemyData(enemyData, stageData.stage_class + enemyData.add_level)
      end
    end
  end
end
function UISimCombatMythicStageGroupDetailPanel:SetTaskRewardInfo(stageTaskId)
  local mythicStageTaskConfig = TableData.listSimCombatMythicStagesDatas:GetDataById(stageTaskId)
  local reward = UIUtils.GetKVSortItemTable(mythicStageTaskConfig.reward)
  local index = 1
  for k, v in pairs(reward) do
    local item
    if self.rewardIconItems[index] == nil then
      item = UICommonItem.New()
      item:InitCtrl(self.ui.mScrollListChild_Reward.gameObject, true)
      table.insert(self.rewardIconItems, item)
    else
      item = self.rewardIconItems[index]
    end
    item:SetItemData(v.id, v.num, false, false)
    index = index + 1
  end
end
function UISimCombatMythicStageGroupDetailPanel:UpdateRightTabs()
  self.stageLevelTaskData = {}
  local stageLevelConfig = TableData.listSimCombatMythicLevelDatas:GetDataById(self.curSelectedStageLevelId)
  self.ui.mText_StageLevelContent.text = stageLevelConfig.level_desc
  self.ui.mText_RecommendLv.text = string_format(TableData.GetHintById(103113), stageLevelConfig.recommend_level)
  self.ui.mImage_EnemyIcon.sprite = IconUtils.GetCharacterHeadFullName(stageLevelConfig.main_enemy)
  local stageLevelState = NetCmdSimCombatMythicData:GetStageLevelState(self.groupID, self.curSelectedStageLevelIndex)
  local baseReq = stageLevelConfig.base_require
  table.insert(self.stageLevelTaskData, baseReq)
  local levelIndex = self.curSelectedStageLevelItem:GetStageLevelIndex()
  for k, v in ipairs(self.stageLevelTaskData) do
    local item
    if self.stageTaskChooseItemList[k] == nil then
      item = SimCombatMythicStageTaskChooseItem.New()
      item:InitCtrl(self.ui.mScrollListChild_GrpList)
      item:SetClickCallBack(function()
        self:OnClickStageTaskItem(item)
      end)
      table.insert(self.stageTaskChooseItemList, item)
    else
      item = self.stageTaskChooseItemList[k]
    end
    item:SetActive(true)
    item:SetData(self.groupID, levelIndex, k, v)
  end
  self:SetSelectedDefaultTask(stageLevelState)
  self:UpdateRightBottom(stageLevelState)
end
function UISimCombatMythicStageGroupDetailPanel:SetSelectedDefaultTask(state)
  if state == SimCombatMythicConfig.StageLevelState.LOCK or state == SimCombatMythicConfig.StageLevelState.FINISH_ADVANCE then
    return
  end
  local defaultIndex = 1
  if SimCombatMythicConfig.CurSelectedStageLevelTaskIndex ~= 0 then
    defaultIndex = SimCombatMythicConfig.CurSelectedStageLevelTaskIndex
    local autoSlc = NetCmdSimCombatMythicData:GetDefaultTaskIndex(self.groupID, self.curSelectedStageLevelIndex)
    if defaultIndex < autoSlc then
      defaultIndex = autoSlc
    end
  else
    defaultIndex = NetCmdSimCombatMythicData:GetDefaultTaskIndex(self.groupID, self.curSelectedStageLevelIndex)
  end
  if defaultIndex > #self.stageTaskChooseItemList then
    return
  end
  self:OnClickStageTaskItem(self.stageTaskChooseItemList[defaultIndex])
end
function UISimCombatMythicStageGroupDetailPanel:UpdateRightBottom(state)
  local state = NetCmdSimCombatMythicData:GetStageLevelState(self.groupID, self.curSelectedStageLevelIndex)
  local finishAll = state == SimCombatMythicConfig.StageLevelState.FINISH_ADVANCE
  local isLock = state == SimCombatMythicConfig.StageLevelState.LOCK
  if isLock then
    setactive(self.ui.mTran_State.gameObject, true)
    setactive(self.ui.mTran_StateLock.gameObject, true)
    setactive(self.ui.mTran_StateFinish.gameObject, false)
    setactive(self.ui.mBtn_BtnStart.gameObject, false)
  elseif finishAll then
    setactive(self.ui.mTran_State.gameObject, true)
    setactive(self.ui.mTran_StateLock.gameObject, false)
    setactive(self.ui.mTran_StateFinish.gameObject, true)
    setactive(self.ui.mBtn_BtnStart.gameObject, false)
  else
    setactive(self.ui.mTran_State.gameObject, false)
    setactive(self.ui.mBtn_BtnStart.gameObject, true)
  end
end
function UISimCombatMythicStageGroupDetailPanel:UpdatePanel()
  local autoSlcItem = self:GetAutoSelectedLevelItem()
  if autoSlcItem ~= nil then
    self:OnClickStageLevelItem(autoSlcItem)
  end
end
function UISimCombatMythicStageGroupDetailPanel:OnShowFinish()
  self:CheckShowUnLockDialog()
end
function UISimCombatMythicStageGroupDetailPanel:CheckShowUnLockDialog()
  local unlockState = NetCmdSimCombatMythicData:GetStageGroupUnLockType()
  if unlockState ~= 0 and unlockState ~= 3 then
    local message = NetCmdSimCombatMythicData:GetUnLockMessage()
    UIManager.OpenUIByParam(UIDef.UISimCombatMythicUnlockDialog, message)
    NetCmdSimCombatMythicData:ClearGroupStageLevelUnLockType()
  end
end
function UISimCombatMythicStageGroupDetailPanel:GetAutoSelectedLevelItem()
  local slcItemIndex
  local slcItemIndex = self:GetAutoSelectedLevelIndex()
  local autoSlcItem = self.stageLevelsItemList[slcItemIndex]
  return autoSlcItem
end
function UISimCombatMythicStageGroupDetailPanel:GetAutoSelectedLevelIndex()
  return NetCmdSimCombatMythicData:GetAutoSelectedLevelIndex(self.groupID)
end
function UISimCombatMythicStageGroupDetailPanel:OnClickStageLevelItem(item)
  if item == nil then
    return
  end
  if self.curSelectedStageLevelItem ~= nil then
    self.curSelectedStageLevelItem:SetSelected(false)
  end
  item:SetSelected(true)
  self.ui.mAnimator:SetTrigger("Tab_FadeIn")
  self.curSelectedStageLevelItem = item
  self.curSelectedStageLevelId = item:GetStageLevelId()
  self.curSelectedStageLevelIndex = item:GetStageLevelIndex()
  self:UpdateRightPanel()
end
function UISimCombatMythicStageGroupDetailPanel:OnClickStageTaskItem(item)
  if item == nil then
    return
  end
  self.curSelectedStageTask = item:GetStageTaskId()
  self.curSelectedStageTaskIndex = item:GetStageTaskIndex()
  SimCombatMythicConfig.CurSelectedStageLevelTaskIndex = self.curSelectedStageTaskIndex
  for k, v in ipairs(self.stageLevelTaskData) do
    local isBefore = false
    local chooseItem = self.stageTaskChooseItemList[k]
    if self.curSelectedStageTaskIndex > chooseItem:GetStageTaskIndex() then
      isBefore = true
    end
    chooseItem:SetSelected(isBefore)
  end
  item:SetSelected(true)
end
function UISimCombatMythicStageGroupDetailPanel:AddListener()
  MessageSys:AddListener(UIEvent.OnLoadingEnd, self.OnLoadingEnd)
end
function UISimCombatMythicStageGroupDetailPanel:RemoveListener()
  MessageSys:RemoveListener(UIEvent.OnLoadingEnd, self.OnLoadingEnd)
end
function UISimCombatMythicStageGroupDetailPanel:OnLoadingOver()
end
function UISimCombatMythicStageGroupDetailPanel:OnHide()
  self.isHide = true
end
function UISimCombatMythicStageGroupDetailPanel:OnClose()
  self:ReleaseCtrlTable(self.stageLevelsItemList)
  self:ReleaseCtrlTable(self.stageTaskChooseItemList)
  self:ReleaseCtrlTable(self.rewardIconItems, true)
  self:ReleaseCtrlTable(self.enemyIconItems)
  self:RemoveListener()
end
