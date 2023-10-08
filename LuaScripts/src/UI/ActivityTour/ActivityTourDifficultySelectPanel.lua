require("UI.UIBasePanel")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.Common.UICommonItem")
require("UI.ActivityTour.ActivityTourDifficultySelectItem")
ActivityTourDifficultySelectPanel = class("ActivityTourDifficultySelectPanel", UIBasePanel)
ActivityTourDifficultySelectPanel.__index = ActivityTourDifficultySelectPanel
function ActivityTourDifficultySelectPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function ActivityTourDifficultySelectPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.currSelect = -1
  self.currPhase = 1
  self.rewardUIList = {}
  self.dropUIList = {}
  local planActivityId = NetCmdRecentActivityData:GetPlanActivityId(2)
  self.activityPlanData = TableData.listPlanDatas:GetDataById(planActivityId, true)
  self.needClose = false
  if self.activityPlanData == nil then
    self:SetVisible(false)
    self.needClose = true
    return
  end
  local activityEntranceData = TableData.listActivityEntranceDatas:GetDataById(self.activityPlanData.args[0])
  if not NetCmdRecentActivityData:ThemeActivityIsOpen(activityEntranceData.id) then
    self:SetVisible(false)
    self.needClose = true
    return
  end
  self.phaseLevelList = NetCmdThemeData:GetAllPhaseLevelList()
  self.monopolyData = NetCmdThemeData:GetCurrMonopolyCfg()
  self.activityId = NetCmdThemeData:GetActivityIdByModuleId(self.monopolyData.activity_submodule)
  self.messionRed = self.ui.mBtn_Mission.transform:Find("Trans_RedPoint").gameObject
  self:InitLevelPhase()
  self:ManualUI()
  self:AddBtnListen()
end
function ActivityTourDifficultySelectPanel:InitLevelPhase()
  self.levelPhaseList = {}
  self.phaseLevelCount = {}
  for i = 0, TableDataBase.listMonopolyPhaseDatas.Count - 1 do
    local data = TableDataBase.listMonopolyPhaseDatas[i]
    self.phaseLevelCount[i + 1] = data.monopoly_difficulty
    for j = 0, data.monopoly_difficulty.Count - 1 do
      self.levelPhaseList[data.monopoly_difficulty[j]] = data.id
    end
  end
end
function ActivityTourDifficultySelectPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourDifficultySelectPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Detail.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.ActivityTourMapInfoDialog, {
      openIndex = 1,
      levelStageData = self.levelStageData
    })
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Command.gameObject).onClick = function()
    UIManager.OpenUI(UIDef.ActivityTourCommandDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Mission.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.ActivityTourMissionDialog, {
      themeId = self.themeId
    })
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Start.gameObject).onClick = function()
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityTourDifficultySelectPanel)
      return
    end
    NetCmdMonopolyData:SendStartMonopoly(self.themeId, self.phaseLevelList[self.currSelect], self.levelStageData.MapId, self.levelStageData.EnemyList, function(errorCode)
      if errorCode == ErrorCodeSuc then
        NetCmdMonopolyData.MapId = self.levelStageData.MapId
        SceneSys:OpenMonoPolyScene(self.levelStageData.MapId)
      end
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Raid.gameObject).onClick = function()
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityTourDifficultySelectPanel)
      return
    end
    if self.LevelUnLock then
      UIManager.OpenUIByParam(UIDef.ActivityRaidDialog, {
        stage_id = self.levelData.id,
        sweep_cost = self.levelData.sweep_cost,
        sweep_times = self.levelData.sweep_times
      })
    else
      CS.PopupMessageManager.PopupString(self.lockText)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GiveUp.gameObject).onClick = function()
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityTourDifficultySelectPanel)
      return
    end
    UIManager.OpenUIByParam(UIDef.ActivityTourDoubleCheckDialog, {
      themeId = self.themeId
    })
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Continue.gameObject).onClick = function()
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityTourDifficultySelectPanel)
      return
    end
    NetCmdMonopolyData:SendContinueMonopoly(self.themeId, function(errorCode)
      if errorCode == ErrorCodeSuc then
        SceneSys:OpenMonoPolyScene(NetCmdMonopolyData.MapId)
      end
    end)
  end
  UIUtils.GetButtonListener(self.ui.mObj_BtnArrowL.gameObject).onClick = function()
    self:UpdateSelectIndex(self.currSelect - 1, true)
  end
  UIUtils.GetButtonListener(self.ui.mObj_BtnArrowR.gameObject).onClick = function()
    local index = self.currSelect + 1
    if index >= self.phaseLevelList.Count then
      return
    end
    local levelId = self.phaseLevelList[index]
    if not NetCmdThemeData:PhaseIsUnLock(NetCmdThemeData:GetPhaseByLevelId(levelId), self.activityId, true) then
      return
    end
    self:UpdateSelectIndex(self.currSelect + 1, true)
  end
end
function ActivityTourDifficultySelectPanel:ManualUI()
  self.stageUIList = {}
  for i = 1, self.ui.mTrans_Stage.childCount do
    local item = self.ui.mTrans_Stage:GetChild(i - 1)
    local cell = {}
    cell.Trans_Locked = item.transform:Find("Trans_Locked").gameObject
    cell.Trans_Unlock = item.transform:Find("Trans_Unlock").gameObject
    cell.Trans_OnGoing = item.transform:Find("Trans_OnGoing").gameObject
    cell.isUnlock = NetCmdThemeData:PhaseIsUnLock(i, self.activityId, false)
    table.insert(self.stageUIList, cell)
  end
  self.levelUIList = {}
  for i = 1, 4 do
    local item = self.ui.mTrans_ProgressBar.transform:Find("GrpState" .. i)
    local cell = {}
    cell.go = item.transform.gameObject
    cell.Trans_Locked = item.transform:Find("Trans_Locked").gameObject
    cell.Trans_Finished = item.transform:Find("Trans_Finished").gameObject
    cell.Trans_Selected = item.transform:Find("Trans_Selected").gameObject
    cell.Trans_Ongoing = item.transform:Find("Trans_Ongoing").gameObject
    table.insert(self.levelUIList, cell)
  end
  self.targetUIList = {}
  for i = 1, self.ui.mTrans_Content.childCount do
    local trans = self.ui.mTrans_Content:GetChild(i - 1)
    local cell = {}
    cell.go = trans.gameObject
    cell.txt = trans.transform:Find("Text_Target"):GetComponent(typeof(CS.UnityEngine.UI.Text))
    table.insert(self.targetUIList, cell)
  end
  self.teamUIList = {}
  local hintIdList = {
    270138,
    270139,
    270305,
    270141
  }
  self.iconPathList = {
    "Icon_ActivityTourDifficulty_Round",
    "Icon_ActivityTourDifficulty_Square3",
    "Icon_ActivityTourDifficulty_Square4",
    "Icon_ActivityTourDifficulty_Square1"
  }
  for i = 1, self.ui.mTrans_LevelDetail.childCount do
    local item = self.ui.mTrans_LevelDetail:GetChild(i - 1)
    local itemView = ActivityTourDifficultySelectItem.New()
    itemView:InitCtrl(item, hintIdList[i])
    table.insert(self.teamUIList, itemView)
  end
end
function ActivityTourDifficultySelectPanel:UpdatInfo()
  local mapData = TableData.listMonopolyMapDatas:GetDataById(self.levelStageData.MapId, true)
  if mapData then
    self.ui.mText_MapName.text = mapData.map_name
    self.ui.mImg_Map.sprite = IconUtils.GetActivitySprite(mapData.map_image)
  end
end
function ActivityTourDifficultySelectPanel:OnInit(root, data)
  self:InitData()
  ActivityTourGlobal.SetGlobalValue()
end
function ActivityTourDifficultySelectPanel:InitData()
  local planActivityId = NetCmdRecentActivityData:GetPlanActivityId(2)
  self.activityPlanData = TableData.listPlanDatas:GetDataById(planActivityId, true)
  if self.activityPlanData == nil then
    self.needClose = true
    self:SetVisible(false)
    return
  end
  local activityEntranceData = TableData.listActivityEntranceDatas:GetDataById(self.activityPlanData.args[0])
  if not NetCmdRecentActivityData:ThemeActivityIsOpen(activityEntranceData.id) then
    self.needClose = true
    self:SetVisible(false)
    return
  end
  NetCmdThemeData:SendMonopolyInfo(self.activityPlanData.args[0], function(ret)
    if ret == ErrorCodeSuc then
      self:SetVisible(true)
      self.phaseLevelList = NetCmdThemeData:GetAllPhaseLevelList()
      self.monopolyData = NetCmdThemeData:GetCurrMonopolyCfg()
      self.activityId = NetCmdThemeData:GetActivityIdByModuleId(self.monopolyData.activity_submodule)
      self.themeId = self.activityPlanData.args[0]
      ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
      self.currSelect = -1
      self:UpdateSelectIndex(NetCmdThemeData:GetLevelIndex(), false)
    else
      UIManager.CloseUI(UIDef.ActivityTourDifficultySelectPanel)
    end
  end)
end
function ActivityTourDifficultySelectPanel:UpdateSelectIndex(index, isShowAni)
  if self.currSelect == index then
    return
  end
  if index >= self.phaseLevelList.Count then
    return
  end
  local levelId = self.phaseLevelList[index]
  if not NetCmdThemeData:MonLevelIsUnLock(levelId, self.activityId, true) then
    return
  end
  self.levelStageData = NetCmdThemeData:GetLevelStageData(levelId)
  if self.levelStageData == nil then
    NetCmdThemeData:SendMonopolyInfo(self.activityPlanData.args[0], function(ret)
      if ret == ErrorCodeSuc then
        print("重新请求数据成功")
      end
    end)
    return
  end
  self:UpdatInfo()
  if isShowAni then
    if index > self.currSelect then
      self.ui.mAnimator_Info:SetBool("Next", true)
    else
      self.ui.mAnimator_Info:SetBool("Previous", true)
    end
  end
  self.currSelect = index
  self.currPhase = self.levelPhaseList[levelId]
  self:UpdatePhase()
  self:UpdateLevelInfo(levelId)
  self:UpdateLevelState(levelId)
end
function ActivityTourDifficultySelectPanel:UpdateLevelState(levelId)
  local phaseLevelData = self.phaseLevelCount[self.currPhase]
  for i = 1, #self.levelUIList do
    local cell = self.levelUIList[i]
    if i <= phaseLevelData.Count then
      local levelState = NetCmdThemeData:GetLevelState(phaseLevelData[i - 1], self.activityId)
      local levelStageData = NetCmdThemeData:GetLevelStageData(phaseLevelData[i - 1])
      local finish = levelStageData and levelStageData.First ~= nil and levelStageData.First == true or false
      setactive(cell.Trans_Finished, levelState ~= 2 and finish)
      setactive(cell.Trans_Selected, levelId == phaseLevelData[i - 1])
      setactive(cell.Trans_Locked, levelState < 2)
      setactive(cell.Trans_Ongoing, levelState == 2)
      setactive(cell.go, true)
    else
      setactive(cell.go, false)
    end
  end
end
function ActivityTourDifficultySelectPanel:UpdateLevelInfo(levelId)
  local levelData = TableDataBase.listMonopolyDifficultyDatas:GetDataById(levelId)
  if levelData then
    self.levelData = levelData
    self.ui.mImg_Icon.sprite = IconUtils.GetActivityTourIcon(levelData.stage_icon)
    self.ui.mText_Difficulty.text = levelData.name
    self.ui.mText_Lv.text = string_format(TableData.GetHintById(901061), levelData.sug_level)
    for i = 1, #self.teamUIList do
      local iconPath = "ActivityTour/" .. self.monopolyData.pic_resoures .. self.iconPathList[i]
      if i == 1 then
        self.teamUIList[i]:SetData(iconPath, self.monopolyData.team_number, i, self.levelStageData)
      elseif i == 2 then
        self.teamUIList[i]:SetData(iconPath, levelData.initial_point, i, self.levelStageData)
      elseif i == 3 then
        self.teamUIList[i]:SetData(iconPath, levelData.round_point, i, self.levelStageData)
      else
        self.teamUIList[i]:SetData(iconPath, string_format(TableData.GetHintById(901061), levelData.enemy_level), i, self.levelStageData)
      end
    end
    for i = 1, #self.targetUIList do
      if i <= levelData.quest_id.Count then
        local questId = levelData.quest_id[i - 1]
        local conditionData = TableData.listMonopolyWinConditionDatas:GetDataById(questId)
        if conditionData then
          self.targetUIList[i].txt.text = conditionData.des.str
          setactive(self.targetUIList[i].go, true)
        end
      else
        setactive(self.targetUIList[i].go, false)
      end
    end
    local currRewardPoint = self.levelStageData.RewardPoint or 0
    local maxRewardPoint = levelData.max_reward_point
    self.ui.mText_Explore.text = TableData.GetHintById(270303) .. string_format(TableData.GetHintById(270304), currRewardPoint, maxRewardPoint)
    if currRewardPoint >= maxRewardPoint then
      setactive(self.ui.mTrans_Finished.gameObject, true)
      setactive(self.ui.mTrans_RContent.gameObject, false)
    else
      setactive(self.ui.mTrans_Finished.gameObject, false)
      self:UpdateDropReward(levelData.drop_show)
      setactive(self.ui.mTrans_RContent.gameObject, true)
    end
    local levelStageData = NetCmdThemeData:GetLevelStageData(levelId)
    local isFinish = levelStageData and levelStageData.First ~= nil and levelStageData.First == true or false
    if not isFinish then
      self.ui.mText_FirstPass.text = TableData.GetHintById(270301)
      self:UpdatePassReward(levelData.first_reward_item, true)
    else
      self.ui.mText_FirstPass.text = TableData.GetHintById(270302)
      self:UpdatePassReward(levelData.sweep_reward, false)
    end
    local levelState = NetCmdThemeData:GetLevelState(levelId, self.activityId)
    self:UpdateBtnState(levelState)
  end
end
function ActivityTourDifficultySelectPanel:UpdateBtnState(levelState)
  setactive(self.ui.mBtn_Start.transform.parent.gameObject, levelState ~= 2)
  setactive(self.ui.mBtn_GiveUp.transform.parent.gameObject, levelState == 2)
  setactive(self.ui.mBtn_Continue.transform.parent.gameObject, levelState == 2)
  setactive(self.ui.mObj_BtnArrowL.gameObject, self.currSelect > 0 and levelState ~= 2)
  setactive(self.ui.mObj_BtnArrowR.gameObject, self.currSelect < self.phaseLevelList.Count - 1 and levelState ~= 2)
  self.lockText = ""
  local lockTextList = {}
  self.LevelUnLock = true
  for i = 0, self.levelData.sweep_unlock.Length - 1 do
    local condtionId = self.levelData.sweep_unlock[i]
    local condtionData = TableData.listSweepCondtionDatas:GetDataById(condtionId)
    if condtionData then
      local count = CS.NetCmdCounterData.Instance:GetCounterCount(24, condtionData.id)
      if count < condtionData.condition_num then
        self.LevelUnLock = false
        table.insert(lockTextList, condtionData.name)
      end
    end
  end
  if #lockTextList == 2 then
    self.lockText = lockTextList[1] .. "且" .. lockTextList[2]
  else
    self.lockText = lockTextList[1]
  end
  setactive(self.ui.mBtn_Raid.gameObject, levelState ~= 2)
  self.ui.mAnimator_Raid:SetBool("Lock", not self.LevelUnLock)
end
function ActivityTourDifficultySelectPanel:UpdateDropReward(list)
  for i = 0, list.Count - 1 do
    do
      local index = i + 1
      if self.dropUIList[index] then
        self.dropUIList[index]:SetItemData(list[i])
      else
        local item = UICommonItem.New()
        item:InitCtrl(self.ui.mTrans_RContent)
        setactive(item.ui.mBtn_Select.gameObject, true)
        item:SetItemData(list[i], nil, nil, nil, nil, nil, nil, function()
          UITipsPanel.Open(TableData.GetItemData(list[i]))
        end)
        table.insert(self.dropUIList, item)
      end
    end
  end
  if #self.dropUIList > list.Count then
    for i = list.Count + 1, #self.dropUIList do
      setactive(self.dropUIList[i].ui.mBtn_Select.gameObject, false)
    end
  end
end
function ActivityTourDifficultySelectPanel:UpdatePassReward(list, isfirst)
  local sortedItemList = LuaUtils.SortItemByDict(list)
  for i = 0, sortedItemList.Count - 1 do
    do
      local index = i + 1
      local kvPair = sortedItemList[i]
      local item = self.rewardUIList[index]
      if item == nil then
        item = UICommonItem.New()
        item:InitCtrl(self.ui.mTrans_LContent)
        table.insert(self.rewardUIList, item)
      end
      setactive(item.ui.mBtn_Select.gameObject, true)
      item:SetFirstDrop(isfirst)
      item:SetItemData(kvPair.Key, kvPair.Value, nil, nil, nil, nil, nil, function()
        UITipsPanel.Open(TableData.GetItemData(kvPair.Key))
      end)
    end
  end
  if #self.rewardUIList > sortedItemList.Count then
    for i = sortedItemList.Count + 1, #self.rewardUIList do
      setactive(self.rewardUIList[i].ui.mBtn_Select.gameObject, false)
    end
  end
end
function ActivityTourDifficultySelectPanel:UpdatePhase()
  for i = 1, #self.stageUIList do
    if i == self.currPhase then
      setactive(self.stageUIList[i].Trans_OnGoing, true)
      setactive(self.stageUIList[i].Trans_Locked, false)
      setactive(self.stageUIList[i].Trans_Unlock, false)
    else
      setactive(self.stageUIList[i].Trans_OnGoing, false)
      setactive(self.stageUIList[i].Trans_Locked, not self.stageUIList[i].isUnlock)
      setactive(self.stageUIList[i].Trans_Unlock, self.stageUIList[i].isUnlock)
    end
  end
end
function ActivityTourDifficultySelectPanel:OnShowStart()
end
function ActivityTourDifficultySelectPanel:OnShowFinish()
  setactive(self.messionRed, NetCmdThemeData:MissionRed())
  if self.needClose then
    UIManager.CloseUI(UIDef.ActivityTourDifficultySelectPanel)
  end
end
function ActivityTourDifficultySelectPanel:OnTop()
  local planActivityId = NetCmdRecentActivityData:GetPlanActivityId(2)
  self.activityPlanData = TableData.listPlanDatas:GetDataById(planActivityId)
  NetCmdThemeData:SendMonopolyInfo(self.activityPlanData.args[0], function(ret)
    local index = self.currSelect
    self.currSelect = -1
    self:UpdateSelectIndex(index, false)
  end)
end
function ActivityTourDifficultySelectPanel:OnBackFrom()
  self:InitData()
end
function ActivityTourDifficultySelectPanel:OnClose()
end
function ActivityTourDifficultySelectPanel:OnHide()
end
function ActivityTourDifficultySelectPanel:OnHideFinish()
end
function ActivityTourDifficultySelectPanel:OnRelease()
  self.currSelect = -1
end
