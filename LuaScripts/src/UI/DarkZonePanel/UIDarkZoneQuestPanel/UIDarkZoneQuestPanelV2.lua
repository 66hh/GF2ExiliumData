require("UI.DarkZonePanel.UIDarkZoneModePanel.Item.UIDarkZoneQuestItem")
UIDarkZoneQuestPanelV2 = class("UIDarkZoneQuestPanelV2", UIBaseCtrl)
UIDarkZoneQuestPanelV2.__index = UIDarkZoneQuestPanelV2
function UIDarkZoneQuestPanelV2:ctor()
end
function UIDarkZoneQuestPanelV2:InitCtrl(prefab, parent, parentPanel)
  local obj = instantiate(prefab, parent)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(obj, self.ui)
  self:AddBtnListener()
  self:AddEventListener()
  self.parentPanel = parentPanel
  self.newBieFinish = false
  self.finishSeriesQuest = DarkNetCmdStoreData.seriesQuest.FinishQuest
  self.departToGroup = NetCmdDarkZoneSeasonData.SeasonDepartToGroupList
  self.groupToQuest = NetCmdDarkZoneSeasonData.SeasonGroupToQuestList
  self.questBundleList = {}
  for index, key in pairs(self.groupToQuest.Keys) do
    table.insert(self.questBundleList, TableData.listDarkzoneSystemQuestBundleDatas:GetDataById(key))
  end
  self.btnList = {}
  self.timerMapFadein = nil
  self.posPath = nil
  self.posPathIndex = 0
  self.questGroup = {}
  self.questIsShowPop = true
  self.needLvList = {}
  self.hasFinishQuestList = {}
  self.hasFinishGroupList = {}
  self.moveFlag = true
  self.todayFinishTime = NetCmdItemData:GetNetItemCount(DarkZoneGlobal.TimeLimitID)
  self.maxFinishTime = TableDataBase.listItemLimitDatas:GetDataById(DarkZoneGlobal.TimeLimitID).max_limit
  self.nowFadeinPrefabList = nil
  self.isNowFadeIn = false
  self.fadeInList = {}
  self.delayExploreZoneUnlock = 0
  self.resetFadeinTimer = nil
  self.uid = AccountNetCmdHandler:GetUID()
  self.lastLevelType = 0
  self.lastQuestType = 0
  self.questType = 0
  self:UpdateLock()
  self.curLevelType = self:GetNowLevelType()
  for k, v in pairs(DarkZoneGlobal.DepartToLevel) do
    for j = 1, #DarkZoneGlobal.DepartToLevel[k] do
      if DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[k][j]] == self.curLevelType then
        self.questType = k
        break
      end
    end
  end
  if DarkNetCmdStoreData.questCacheGroupId ~= 0 then
    self.curLevelType = DarkZoneGlobal.StcIDToLevel[DarkNetCmdStoreData.questCacheGroupId]
    DarkNetCmdStoreData.questCacheGroupId = 0
    for depart, groupList in pairs(DarkZoneGlobal.DepartToLevel) do
      for i = 1, #groupList do
        if self.curLevelType == DarkZoneGlobal.StcIDToLevel[groupList[i]] then
          self.questType = depart
          break
        end
      end
    end
  end
  self:CreateButton()
  for i = 0, TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup.Count - 1 do
    local id = TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup[i]
    if not self:CheckNewBieFinishById(id) then
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewBieGroupFinishKey .. "_" .. id, 0)
    end
  end
  self.easyList = {}
  self.hardList = {}
  self.veryHardList = {}
  self:GetPrefabList(self.parentPanel.ui.mTrans_QuestEasy, "GrpEasy", self.easyList)
  self:GetPrefabList(self.parentPanel.ui.mTrans_QuestHard, "GrpHard", self.hardList)
  self:GetPrefabList(self.parentPanel.ui.mTrans_QuestVeryHard, "GrpVeryHard", self.veryHardList)
  setactive(self.ui.mText_FinishTime, false)
end
function UIDarkZoneQuestPanelV2:GetNowLevelType()
  for i = 1, #self.questBundleList do
    local level = DarkZoneGlobal.StcIDToLevel[self.questBundleList[i].quest_group]
    if self:CheckLevelUnlock(level) and not self.hasFinishGroupList[level] then
      return level
    end
  end
  return self.maxLevelType
end
function UIDarkZoneQuestPanelV2:CreateButton()
  for index, id in pairs(self.departToGroup.Keys) do
    local btnData = {}
    local btn = instantiate(self.ui.mTrans_TabBar.childItem, self.ui.mTrans_TabBar.transform)
    local btnui = {}
    self:LuaUIBindTable(btn, btnui)
    UIUtils.GetButtonListener(btnui.mBtn_Quest.gameObject).onClick = function()
      self:BtnClick(id)
    end
    btnui.mQuest_Name.text = TableData.listDarkzoneSystemQuestGroupDatas:GetDataById(id).name.str
    btnData.btnUI = btnui
    btnData.BtnPrefab = btn
    btnData.questType = id
    btnData.isUnlock = self:CheckBtnUnlock(id)
    btnData.isFinish = self:CheckBtnFinish(id)
    setactive(btnData.btnUI.mTrans_Lock, not btnData.isUnlock)
    btnui.mBtn_Quest.interactable = self.questType ~= id
    self.btnList[id] = btnData
    setactive(btnData.btnUI.mTrans_Compelete, btnData.isFinish)
  end
end
function UIDarkZoneQuestPanelV2:BtnClick(questType)
  local caculateLevel = self.curLevelType + (self:CheckQuestIndex(questType) - self:CheckQuestIndex(self.questType)) * 3
  local temp = caculateLevel // 3
  local posIndex = temp * 3
  local tempLevel = posIndex
  local flag = false
  local nextLevelType = 0
  if caculateLevel - 1 == posIndex or caculateLevel - 2 == posIndex then
    for i = 1, 3 do
      local isUnlock = self:CheckLevelUnlock(tempLevel + i)
      flag = flag or isUnlock
      if isUnlock and nextLevelType == 0 then
        nextLevelType = tempLevel + i
      end
    end
  elseif caculateLevel == posIndex then
    for i = 2, 0, -1 do
      local isUnlock = self:CheckLevelUnlock(tempLevel - i)
      flag = flag or isUnlock
      if isUnlock and nextLevelType == 0 then
        nextLevelType = tempLevel - i
      end
    end
  end
  self.btnList[self.questType].isUnlock = flag
  if not flag then
    local reason = ""
    local level, questID = self:CheckLevelUnlockMinLevel(DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[questType][1]])
    if level > self.userLevel then
      reason = string_format(TableData.GetHintById(240066), level)
    end
    local reasonUnlock2 = self:CheckLevelUnlockMinLevelUnlock2(questID)
    if reasonUnlock2 ~= "" then
      reasonUnlock2 = string_format(TableData.GetHintById(240087), reasonUnlock2)
      if reason ~= "" then
        reasonUnlock2 = string_format(TableData.GetHintById(240121), reason, reasonUnlock2)
      end
    end
    if reason ~= "" and reasonUnlock2 ~= "" then
      PopupMessageManager.PopupString(reasonUnlock2)
    elseif reason ~= "" then
      reason = string_format(TableData.GetHintById(240133), reason)
      PopupMessageManager.PopupString(reason)
    elseif reasonUnlock2 ~= "" then
      reasonUnlock2 = string_format(TableData.GetHintById(240133), reasonUnlock2)
      PopupMessageManager.PopupString(reasonUnlock2)
    end
    return
  end
  if 0 < #self.fadeInList then
    self:SetAnimatorEmpty()
  end
  self:RemoveTimeFunc()
  if self.moveFlag then
    self:SetAnimatorEmpty()
  end
  self.btnList[self.questType].btnUI.mBtn_Quest.interactable = true
  self.btnList[questType].btnUI.mBtn_Quest.interactable = false
  self.lastQuestType = self.questType
  self.lastLevelType = self.curLevelType
  self.curLevelType = nextLevelType
  self.questType = questType
  self:OnClickQuestType(0.1)
  self:ShowCurTypeList((self.curLevelType - self.lastLevelType) // 3 == (self.curLevelType - self.lastLevelType) / 3, true)
end
function UIDarkZoneQuestPanelV2:CheckQuestIndex(questType)
  local i = 0
  for i = 1, #DarkZoneGlobal.DepartList do
    if questType == DarkZoneGlobal.DepartList[i] then
      return i
    end
  end
end
function UIDarkZoneQuestPanelV2:CheckNewBieFinish()
  local newBieFinishFlag = true
  for i = 0, TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup.Count - 1 do
    local id = TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup[i]
    newBieFinishFlag = newBieFinishFlag and self:CheckNewBieFinishById(id) and self:CheckNewBieHasNumFinish(id)
  end
  return newBieFinishFlag
end
function UIDarkZoneQuestPanelV2:CheckNewBieHasNumFinish(departID)
  for i = 0, self.departToGroup[departID].Count - 1 do
    local groupID = self.departToGroup[departID][i]
    for j = 0, self.groupToQuest[groupID].Count - 1 do
      local id = self.groupToQuest[groupID][j]
      local hasNum = DarkNetCmdStoreData:GetDZQuestReceivedChest(id)
      local totalNum = DarkNetCmdStoreData:GetDZQuestTotalChest(id)
      if hasNum ~= totalNum then
        return false
      end
    end
  end
  return true
end
function UIDarkZoneQuestPanelV2:CheckNewBieHasNumFinishByGroupID(GroupID)
  local groupID = GroupID
  for j = 0, self.groupToQuest[groupID].Count - 1 do
    local id = self.groupToQuest[groupID][j]
    local hasNum = DarkNetCmdStoreData:GetDZQuestReceivedChest(id)
    local totalNum = DarkNetCmdStoreData:GetDZQuestTotalChest(id)
    if hasNum ~= totalNum then
      return false
    end
  end
  return true
end
function UIDarkZoneQuestPanelV2:CheckNewBieFinishById(groupID)
  local newBie = TableData.listDarkzoneSystemQuestGroupDatas:GetDataById(groupID)
  local newBieFinishFlag = true
  for i = 0, newBie.quest_bundle_id.Count - 1 do
    newBieFinishFlag = newBieFinishFlag and self.hasFinishGroupList[DarkZoneGlobal.StcIDToLevel[newBie.quest_bundle_id[i]]]
  end
  return newBieFinishFlag
end
function UIDarkZoneQuestPanelV2:UpdateLock()
  self.finishSeriesQuest = DarkNetCmdStoreData.seriesQuest.FinishQuest
  for finsih, id in pairs(self.finishSeriesQuest.Keys) do
    for i = 0, self.finishSeriesQuest[id].Ids.Count - 1 do
      if self.finishSeriesQuest[id].Ids[i] ~= 0 then
        self.hasFinishQuestList[self.finishSeriesQuest[id].Ids[i]] = true
      end
    end
  end
  for i = DarkZoneGlobal.LevelTypeMin, DarkZoneGlobal.LevelTypeMax do
    self.questGroup[i] = {}
    self.hasFinishGroupList[i] = false
    local groupID = DarkZoneGlobal.LevelToStcID[i]
    if self.finishSeriesQuest:ContainsKey(groupID) and self.finishSeriesQuest[groupID].Ids.Count == self.groupToQuest[groupID].Count and self:CheckNewBieHasNumFinishByGroupID(groupID) then
      self.hasFinishGroupList[i] = true
    end
  end
  self.maxLevelType = DarkZoneGlobal.LevelTypeMin
  self.userLevel = AccountNetCmdHandler:GetLevel()
  if pcall(function()
    for i = 1, #self.questBundleList do
      self.needLvList[DarkZoneGlobal.StcIDToLevel[self.questBundleList[i].quest_group]] = self.questBundleList[i].quest_need_lv
      for j = 0, self.questBundleList[i].quest_series_id.Count - 1 do
        table.insert(self.questGroup[DarkZoneGlobal.StcIDToLevel[self.questBundleList[i].quest_group]], TableData.listDarkzoneSystemQuestDatas:GetDataById(self.questBundleList[i].quest_series_id[j]))
      end
    end
  end) then
    for i = 1, #self.questBundleList do
      if self:CheckLevelUnlock(DarkZoneGlobal.StcIDToLevel[self.questBundleList[i].quest_group]) then
        self.maxLevelType = DarkZoneGlobal.StcIDToLevel[self.questBundleList[i].quest_group]
      else
        PlayerPrefs.SetInt(self.uid .. DarkZoneGlobal.NewQuestGroupUnlock .. self.questBundleList[i].quest_group, 0)
      end
    end
  else
    gferror("读表出现问题！！请检查表格")
  end
end
function UIDarkZoneQuestPanelV2:UpdateBtnLock()
  for k, v in pairs(DarkZoneGlobal.DepartToLevel) do
    self.btnList[k].isUnlock = self:CheckBtnUnlock(k)
    setactive(self.btnList[k].btnUI.mTrans_Lock, not self.btnList[k].isUnlock)
  end
end
function UIDarkZoneQuestPanelV2:UpdateBtnFinish()
  for k, v in pairs(DarkZoneGlobal.DepartToLevel) do
    self.btnList[k].isFinish = self:CheckBtnFinish(k)
    setactive(self.btnList[k].btnUI.mTrans_Lock, self.btnList[k].isFinish)
  end
end
function UIDarkZoneQuestPanelV2:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = function()
    self:OnLeftClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = function()
    self:OnRightClick()
  end
end
function UIDarkZoneQuestPanelV2:AddEventListener()
  function self.OnUpdateItem(Sender)
    if Sender.Sender == DarkZoneGlobal.TimeLimitID then
      self.todayFinishTime = NetCmdItemData:GetNetItemCount(DarkZoneGlobal.TimeLimitID)
      if not self.maxFinishTime then
        self.maxFinishTime = TableDataBase.listItemLimitDatas:GetDataById(DarkZoneGlobal.TimeLimitID).max_limit
      end
      if self.ui then
      end
    end
  end
  MessageSys:AddListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.OnUpdateItem)
end
function UIDarkZoneQuestPanelV2:GetPrefabList(parentTrans, name, prefabList)
  for i = 1, 4 do
    local item = prefabList[i]
    if item == nil then
      item = UIDarkZoneQuestItem.New()
      local prefab = parentTrans:Find(name .. tostring(i))
      item:InitCtrl(prefab:GetComponent(typeof(ScrollListChild)).childItem, prefab)
      table.insert(prefabList, item)
    end
  end
end
function UIDarkZoneQuestPanelV2:OnShowStart()
end
function UIDarkZoneQuestPanelV2:Show(isFirstShow, isBackFrom, isNeedDelayFadein, isOnRecover)
  if isBackFrom then
    self:OnBackFrom()
    return
  end
  self:UpdateBtnLock()
  self:UpdateBtnFinish()
  local unMoveAnimation = false
  if isFirstShow then
    unMoveAnimation = true
    isBackFrom = true
    self:SetAllAnimatorEmpty()
  end
  if isOnRecover then
    isBackFrom = false
    unMoveAnimation = true
  end
  local newbiefinish = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewBieGroupFinishKey) == 1
  local isShowPop = false
  isShowPop = self:CheckNewBieFinish() and newbiefinish == false
  self.planID = NetCmdRecentActivityData:GetCurDarkZonePlanActivityData()
  local tmp = self:CheckNewBieFinish()
  gfdebug("newbiefinish:" .. tostring(newbiefinish))
  gfdebug("isShowPop:" .. tostring(isShowPop))
  gfdebug("self:CheckNewBieFinish():" .. tostring(tmp))
  gfdebug("self.planID" .. tostring(self.planID))
  gfdebug("NetCmdDarkZoneSeasonData.LastPlanID" .. tostring(NetCmdDarkZoneSeasonData.LastPlanID))
  if NetCmdDarkZoneSeasonData.LastPlanID > 0 and self.planID > 0 and isShowPop and self.planID ~= NetCmdDarkZoneSeasonData.LastPlanID then
    for i = 0, TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup.Count - 1 do
      local id = TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup[i]
      setactive(self.btnList[id].btnUI.mBtn_Quest.transform.parent.transform, false)
    end
    local flag = 0
    if self.curLevelType <= DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup[0]][3]] then
      for k, v in pairs(DarkZoneGlobal.DepartToLevel) do
        if k ~= TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup and flag == 0 then
          flag = 1
          self.questType = k
          self.curLevelType = DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[k][1]]
        end
      end
    end
    if #self.btnList - TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup.Count == 1 then
      for index, id in pairs(self.departToGroup.Keys) do
        setactive(self.btnList[id].btnUI.mBtn_Quest.transform.parent.transform, false)
      end
    end
  end
  for i = 0, TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup.Count - 1 do
    local isShowPopId = false
    local id = TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup[i]
    local newbiefinishById = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewBieGroupFinishKey .. "_" .. id) == 1
    isShowPopId = self:CheckNewBieFinishById(id)
    if isShowPopId and not newbiefinishById then
      self:OnNewBieFinish(id)
    end
  end
  self:CheckQuestFinishPop()
  self:OnClickQuestType(0)
  self:CheckPopChip()
  self:ShowCurTypeList(unMoveAnimation, true, isNeedDelayFadein, isBackFrom)
end
function UIDarkZoneQuestPanelV2:OnClickQuestType(isDelay)
  if isDelay then
    TimerSys:DelayCall(isDelay, function()
      self:SetQuestItemData(self.easyList, DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[self.questType][1]])
      self:SetQuestItemData(self.hardList, DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[self.questType][2]])
      self:SetQuestItemData(self.veryHardList, DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[self.questType][3]])
    end)
  else
    TimerSys:DelayCall(0.5, function()
      self:SetQuestItemData(self.easyList, DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[self.questType][1]])
      self:SetQuestItemData(self.hardList, DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[self.questType][2]])
      self:SetQuestItemData(self.veryHardList, DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[self.questType][3]])
    end)
  end
end
function UIDarkZoneQuestPanelV2:SetQuestItemData(prefabList, GroupId)
  local systemQuestData = self.questGroup[GroupId]
  for i = 1, 4 do
    local state = DarkZoneGlobal.QuestState.Locked
    local frontFinish = false
    local enoughLevel = false
    if i <= #systemQuestData then
      frontFinish = self:CheckFrontFinish(systemQuestData[i].id)
      enoughLevel = self:CheckByLevel(systemQuestData[i].unlock1)
    end
    if frontFinish and enoughLevel then
      state = DarkZoneGlobal.QuestState.UnLocked
    end
    if i <= #systemQuestData and self.hasFinishQuestList[systemQuestData[i].id] then
      state = DarkZoneGlobal.QuestState.Finished
    end
    if i <= #systemQuestData then
      prefabList[i]:SetData(systemQuestData[i], self.questBundleList, state, self.curLevelType, frontFinish, enoughLevel)
      prefabList[i]:SetShowFlag(true)
    else
      prefabList[i]:SetShowFlag(false)
    end
  end
end
function UIDarkZoneQuestPanelV2:ClosePrefabList(prefabList)
  for i = 1, #prefabList do
    prefabList[i]:CloseSelf()
  end
end
function UIDarkZoneQuestPanelV2:OpenPrefabList(prefabList)
  for i = 1, #prefabList do
    prefabList[i]:OpenSelf()
  end
end
function UIDarkZoneQuestPanelV2:SetQuestAnimatorFadeOut(prefabList)
  for i = 1, 4 do
    prefabList[i].ui.mAnimator:SetTrigger("FadeOut")
    prefabList[i].ui.mCanvasGroup.blocksRaycasts = false
  end
end
function UIDarkZoneQuestPanelV2:SetQuestAnimatorEmpty(prefabList)
  for i = 1, 4 do
    prefabList[i].ui.mCanvasGroup.blocksRaycasts = false
  end
  self:ClosePrefabList(prefabList)
end
function UIDarkZoneQuestPanelV2:SetQuestAnimatorFadeIn(prefabList)
  self.isNowFadeIn = true
  for i = 1, 4 do
    local timer
    timer = TimerSys:DelayCall(0.1 * i, function()
      prefabList[i]:OpenSelf()
      self.nowFadeinPrefabList = prefabList
      prefabList[i].ui.mAnimator:Play("FadeIn", 2, 0)
      prefabList[i].ui.mCanvasGroup.blocksRaycasts = true
      if i == 4 then
        self.resetFadeinTimer = TimerSys:DelayCall(0.7, function()
          self.fadeInList = {}
          self.isNowFadeIn = false
          self.nowFadeinPrefabList = nil
          self.resetFadeinTimer = nil
        end)
      end
    end)
    table.insert(self.fadeInList, timer)
  end
end
function UIDarkZoneQuestPanelV2:OnNewBieFinish(groupID)
  PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewBieGroupFinishKey .. "_" .. groupID, 1)
  local groupData = TableData.listDarkzoneSystemQuestGroupDatas:GetDataById(groupID)
  self:SetIsShowPopState(false)
  CS.PopupMessageManager.PopupDarkZoneQuestStateChange(string_format(TableData.GetHintById(192082), groupData.name.str), function()
    self:SetIsShowPopState(true)
  end)
  self.delayExploreZoneUnlock = self.delayExploreZoneUnlock - DarkZoneGlobal.PopDelayTime
end
function UIDarkZoneQuestPanelV2:OnLeftClick()
  local temp = self.curLevelType // 3
  local posIndex = temp * 3
  local tempLevel = 0
  if posIndex == self.curLevelType - 1 then
    if DarkZoneGlobal.LevelToStcID[tempLevel] == TableData.GlobalDarkzoneData.DzQuestGroupShow then
      tempLevel = self.curLevelType + 1
    else
      tempLevel = self.curLevelType + 2
    end
  else
    tempLevel = self.curLevelType - 1
  end
  if not self:CheckLevelUnlock(tempLevel) then
    local reason = ""
    local level, questID = self:CheckLevelUnlockMinLevel(tempLevel)
    if level > self.userLevel then
      reason = string_format(TableData.GetHintById(240066), level)
    end
    local reasonUnlock2 = self:CheckLevelUnlockMinLevelUnlock2(questID)
    if reasonUnlock2 ~= "" then
      reasonUnlock2 = string_format(TableData.GetHintById(240087), reasonUnlock2)
      if reason ~= "" then
        reasonUnlock2 = string_format(TableData.GetHintById(240121), reason, reasonUnlock2)
      end
    end
    if reason ~= "" and reasonUnlock2 ~= "" then
      PopupMessageManager.PopupString(reasonUnlock2)
    elseif reason ~= "" then
      reason = string_format(TableData.GetHintById(240133), reason)
      PopupMessageManager.PopupString(reason)
    elseif reasonUnlock2 ~= "" then
      reasonUnlock2 = string_format(TableData.GetHintById(240133), reasonUnlock2)
      PopupMessageManager.PopupString(reasonUnlock2)
    end
    return
  end
  if 0 < #self.fadeInList then
    self:SetAnimatorEmpty()
  end
  self:RemoveTimeFunc()
  if self.moveFlag then
    self:SetAnimatorEmpty()
  end
  self.lastLevelType = self.curLevelType
  self.curLevelType = tempLevel
  self:OnClickQuestType()
  self:ShowCurTypeList()
  self:BanArrow()
end
function UIDarkZoneQuestPanelV2:OnRightClick()
  local temp = self.curLevelType // 3
  local posIndex = temp * 3
  local tempLevel = 0
  if posIndex == self.curLevelType then
    tempLevel = self.curLevelType - 2
  elseif posIndex == self.curLevelType - 2 then
    tempLevel = self.curLevelType + 1
    if DarkZoneGlobal.LevelToStcID[tempLevel] == TableData.GlobalDarkzoneData.DzQuestGroupShow then
      tempLevel = self.curLevelType - 1
    end
  else
    tempLevel = self.curLevelType + 1
  end
  if not self:CheckLevelUnlock(tempLevel) then
    local reason = ""
    local level, questID = self:CheckLevelUnlockMinLevel(tempLevel)
    if level > self.userLevel then
      reason = string_format(TableData.GetHintById(240066), level)
    end
    local reasonUnlock2 = self:CheckLevelUnlockMinLevelUnlock2(questID)
    if reasonUnlock2 ~= "" then
      reasonUnlock2 = string_format(TableData.GetHintById(240087), reasonUnlock2)
      if reason ~= "" then
        reasonUnlock2 = string_format(TableData.GetHintById(240121), reason, reasonUnlock2)
      end
    end
    if reason ~= "" and reasonUnlock2 ~= "" then
      PopupMessageManager.PopupString(reasonUnlock2)
    elseif reason ~= "" then
      reason = string_format(TableData.GetHintById(240133), reason)
      PopupMessageManager.PopupString(reason)
    elseif reasonUnlock2 ~= "" then
      reasonUnlock2 = string_format(TableData.GetHintById(240133), reasonUnlock2)
      PopupMessageManager.PopupString(reasonUnlock2)
    end
    return
  end
  if 0 < #self.fadeInList then
    self:SetAnimatorEmpty()
  end
  self:RemoveTimeFunc()
  if self.moveFlag then
    self:SetAnimatorEmpty()
  end
  self.lastLevelType = self.curLevelType
  self.curLevelType = tempLevel
  self:OnClickQuestType()
  self:ShowCurTypeList()
  self:BanArrow()
end
function UIDarkZoneQuestPanelV2:BanArrow()
  self.ui.mBtn_PreGun.interactable = false
  self.ui.mBtn_NextGun.interactable = false
end
function UIDarkZoneQuestPanelV2:CheckIsHideGroup()
  for i = 0, self.departToGroup[self.questType].Count - 1 do
    local groupID = self.departToGroup[self.questType][i]
    if groupID == TableData.GlobalDarkzoneData.DzQuestGroupShow then
      return true
    end
  end
  return false
end
function UIDarkZoneQuestPanelV2:ShowCurTypeList(unMoveAnimation, isNeedFadeIn, isNeedDelayFadein, isBackFrom)
  self.parentPanel.ui.mAnimator_Mode:SetInteger("MapEasy", 3)
  self.parentPanel.ui.mAnimator_Mode:SetInteger("MapHard", 3)
  self.parentPanel.ui.mAnimator_Mode:SetInteger("MapVeryHard", 3)
  self.todayFinishTime = NetCmdItemData:GetNetItemCount(DarkZoneGlobal.TimeLimitID)
  setactivewithcheck(self.ui.mTrans_GrpNum3, not self:CheckIsHideGroup())
  setactive(self.ui.mTrans_Ongoing1, false)
  setactive(self.ui.mTrans_Ongoing2, false)
  setactive(self.ui.mTrans_Ongoing3, false)
  setactive(self.ui.mTrans_Finish1, false)
  setactive(self.ui.mTrans_Finish2, false)
  setactive(self.ui.mTrans_Finish3, false)
  local temp = self.curLevelType // 3
  local posIndex = temp * 3
  if posIndex == self.curLevelType then
    setactive(self.ui.mTrans_Lock1, not self:CheckLevelUnlock(self.curLevelType - 2))
    setactive(self.ui.mTrans_Lock2, not self:CheckLevelUnlock(self.curLevelType - 1))
    setactive(self.ui.mTrans_Lock3, not self:CheckLevelUnlock(self.curLevelType))
    setactive(self.ui.mTrans_Num1, self:CheckLevelUnlock(self.curLevelType - 2))
    setactive(self.ui.mTrans_Num2, self:CheckLevelUnlock(self.curLevelType - 1))
    setactive(self.ui.mTrans_Num3, self:CheckLevelUnlock(self.curLevelType))
    setactive(self.ui.mTrans_GoNum1, self:CheckLevelUnlock(self.curLevelType - 2))
    setactive(self.ui.mTrans_GoNum2, self:CheckLevelUnlock(self.curLevelType - 1))
    setactive(self.ui.mTrans_GoNum3, self:CheckLevelUnlock(self.curLevelType))
  else
    setactive(self.ui.mTrans_Lock1, not self:CheckLevelUnlock(posIndex + 1))
    setactive(self.ui.mTrans_Lock2, not self:CheckLevelUnlock(posIndex + 2))
    setactive(self.ui.mTrans_Lock3, not self:CheckLevelUnlock(posIndex + 3))
    setactive(self.ui.mTrans_Num1, self:CheckLevelUnlock(posIndex + 1))
    setactive(self.ui.mTrans_Num2, self:CheckLevelUnlock(posIndex + 2))
    setactive(self.ui.mTrans_Num3, self:CheckLevelUnlock(posIndex + 3))
    setactive(self.ui.mTrans_GoNum1, self:CheckLevelUnlock(posIndex + 1))
    setactive(self.ui.mTrans_GoNum2, self:CheckLevelUnlock(posIndex + 2))
    setactive(self.ui.mTrans_GoNum3, self:CheckLevelUnlock(posIndex + 3))
  end
  self:UpdateMapLevelBg(posIndex)
  for i = 1, #DarkZoneGlobal.DepartToLevel[self.questType] do
    if self.hasFinishGroupList[DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[self.questType][i]]] then
      setactive(self.ui["mTrans_Finish" .. tostring(i)], true)
      setactive(self.ui["mTrans_Num" .. tostring(i)], false)
      setactive(self.ui["mTrans_GoNum" .. tostring(i)], false)
    end
  end
  if self.lastLevelType ~= self.curLevelType and (self.curLevelType - self.lastLevelType) // 3 ~= (self.curLevelType - self.lastLevelType) / 3 and not unMoveAnimation then
    self.lastLevelType = self.curLevelType
    self:SetMapAnimation()
    self.timerMapFadein = TimerSys:DelayCall(0.4, function()
      self:SetAnimatorFadeIn()
      self.timerMapFadein = nil
    end)
    self.parentPanel.ui.mAnimator_Mode:SetTrigger("QuestMode_Tab")
  elseif unMoveAnimation then
    self.lastLevelType = self.curLevelType
    if isBackFrom then
      self:SetFixedPos()
    else
      self:SetMapAnimation(true)
    end
    if isNeedFadeIn then
      if isNeedDelayFadein then
        self.timerMapFadein = TimerSys:DelayCall(0.2, function()
          self:SetAnimatorFadeIn()
          self.timerMapFadein = nil
        end)
      else
        self:SetAnimatorFadeIn()
      end
    end
  end
  local isUnlock = PlayerPrefs.GetInt(self.uid .. DarkZoneGlobal.NewQuestGroupUnlock .. DarkZoneGlobal.LevelToStcID[self.curLevelType]) == 1
  if isUnlock == false and self:CheckLevelUnlock(self.curLevelType) then
    PlayerPrefs.SetInt(self.uid .. DarkZoneGlobal.NewQuestGroupUnlock .. DarkZoneGlobal.LevelToStcID[self.curLevelType], 1)
  end
  self:UpdateRedPoint()
end
function UIDarkZoneQuestPanelV2:UpdateMapLevelBg(posIndex)
  setactive(self.ui.mBtn_PreGun.transform.parent.transform, true)
  setactive(self.ui.mBtn_NextGun.transform.parent.transform, true)
  self.ui.mText_MapLevel.text = self:GetLevelText(self.curLevelType)
  if self.curLevelType - 1 == posIndex then
    setactive(self.ui.mTrans_Ongoing1, true)
    self.parentPanel.ui.mAnimator_Mode:SetInteger("MapEasy", 1)
    setactive(self.ui.mBtn_PreGun.transform.parent.transform, false)
    self.ui.mImg_MapBg.color = DarkZoneGlobal.ColorType.normal
  elseif self.curLevelType - 2 == posIndex then
    setactive(self.ui.mTrans_Ongoing2, true)
    self.parentPanel.ui.mAnimator_Mode:SetInteger("MapHard", 1)
    self.ui.mImg_MapBg.color = DarkZoneGlobal.ColorType.hard
    if DarkZoneGlobal.LevelToStcID[self.curLevelType + 1] == TableData.GlobalDarkzoneData.DzQuestGroupShow then
      setactive(self.ui.mBtn_NextGun.transform.parent.transform, false)
    end
  elseif self.curLevelType == posIndex then
    setactive(self.ui.mTrans_Ongoing3, true)
    self.parentPanel.ui.mAnimator_Mode:SetInteger("MapVeryHard", 1)
    setactive(self.ui.mBtn_NextGun.transform.parent.transform, false)
    self.ui.mImg_MapBg.color = DarkZoneGlobal.ColorType.veryHard
  end
  if self:CheckBtnAllUnlock(self.questType) then
    setactive(self.ui.mBtn_PreGun.transform.parent.transform, true)
    setactive(self.ui.mBtn_NextGun.transform.parent.transform, true)
  end
  local colorIndex = self:IsNewBieQuestType()
  if colorIndex == 0 then
    self.ui.mImg_MapBg.color = DarkZoneGlobal.ColorType.newBie
  elseif colorIndex == 1 then
    self.ui.mImg_MapBg.color = DarkZoneGlobal.ColorType.newBie2
  end
end
function UIDarkZoneQuestPanelV2:GetLevelText(curLevelType)
  for i = 1, #self.questBundleList do
    if DarkZoneGlobal.LevelToStcID[curLevelType] == self.questBundleList[i].QuestGroup then
      return self.questBundleList[i].name.str
    end
  end
end
function UIDarkZoneQuestPanelV2:IsNewBieQuestType()
  for i = 0, TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup.Count - 1 do
    local id = TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup[i]
    if self.curLevelType >= DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[id][1]] and self.curLevelType <= DarkZoneGlobal.StcIDToLevel[DarkZoneGlobal.DepartToLevel[id][3]] then
      return i
    end
  end
  return false
end
function UIDarkZoneQuestPanelV2:SetMapAnimation(isfromExplore)
  local temp = self.curLevelType // 3
  local posIndex = temp * 3
  if not isfromExplore then
    if self.curLevelType - 1 == posIndex then
      self.parentPanel.ui.mMoveController:MoveAsset(self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition, DarkZoneGlobal.QuestMapPos.Normal)
    elseif self.curLevelType - 2 == posIndex then
      self.parentPanel.ui.mMoveController:MoveAsset(self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition, DarkZoneGlobal.QuestMapPos.Hard)
    elseif self.curLevelType == posIndex then
      self.parentPanel.ui.mMoveController:MoveAsset(self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition, DarkZoneGlobal.QuestMapPos.VeryHard)
    end
  elseif self.curLevelType - 1 == posIndex then
    self.parentPanel.ui.mMoveController:MoveAssetExplore(self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition, DarkZoneGlobal.QuestMapPos.Normal, 1)
  elseif self.curLevelType - 2 == posIndex then
    self.parentPanel.ui.mMoveController:MoveAssetExplore(self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition, DarkZoneGlobal.QuestMapPos.Hard, 1)
  elseif self.curLevelType == posIndex then
    self.parentPanel.ui.mMoveController:MoveAssetExplore(self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition, DarkZoneGlobal.QuestMapPos.VeryHard, 1)
  end
  self.moveFlag = false
  self:BanArrow()
  if self.timerMapFadein then
    TimerSys:RemoveTimer(self.timerMapFadein)
  end
  if self.fadeInList then
    local flag = false
    if self.nowFadeinPrefabList then
      self.nowFadeinPrefabList = nil
      TimerSys:RemoveTimer(self.resetFadeinTimer)
      self.resetFadeinTimer = nil
      flag = true
    end
    if self.resetFadeinTimer and not flag then
      self.nowFadeinPrefabList = nil
      TimerSys:RemoveTimer(self.resetFadeinTimer)
      self.resetFadeinTimer = nil
    end
    for i = 1, #self.fadeInList do
      TimerSys:RemoveTimer(self.fadeInList[i])
    end
  end
end
function UIDarkZoneQuestPanelV2:RemoveTimeFunc()
  if self.timerMapFadein then
    TimerSys:RemoveTimer(self.timerMapFadein)
  end
  if self.resetFadeinTimerthen then
    self.nowFadeinPrefabList = nil
    TimerSys:RemoveTimer(self.resetFadeinTimer)
    self.resetFadeinTimer = nil
  end
  for i = 1, #self.fadeInList do
    TimerSys:RemoveTimer(self.fadeInList[i])
  end
end
function UIDarkZoneQuestPanelV2:CheckPopChip()
  local btnAndGroupID = NetCmdDarkZoneSeasonData:GetNewUnlockBtn()
  local levelGroupID = NetCmdDarkZoneSeasonData:GetNewUnlockLevel()
  if btnAndGroupID == nil and levelGroupID == nil then
    return
  end
  TimerSys:DelayCall(0.5, function()
    for i = 1, #DarkZoneGlobal.DepartList do
      local isUnlock = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewQuestBtnUnlock .. self.btnList[DarkZoneGlobal.DepartList[i]].questType) == 1
      if not isUnlock and self.btnList[DarkZoneGlobal.DepartList[i]].isUnlock then
        self:SetIsShowPopState(false)
        PopupMessageManager.PopupDZStateChangeString(string_format(TableData.GetHintById(240086), self.btnList[DarkZoneGlobal.DepartList[i]].btnUI.mQuest_Name.text), function()
          self:SetIsShowPopState(true)
        end)
        PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewQuestBtnUnlock .. self.btnList[DarkZoneGlobal.DepartList[i]].questType, 1)
      end
    end
    if levelGroupID and btnAndGroupID == nil then
      self:SetIsShowPopState(false)
      PopupMessageManager.PopupDZStateChangeString(TableData.GetHintById(240098), function()
        self:SetIsShowPopState(true)
      end)
    end
  end)
  for i = 1, #self.fadeInList do
    TimerSys:RemoveTimer(self.fadeInList[i])
  end
  self:SetAnimatorEmpty()
  self.btnList[self.questType].btnUI.mBtn_Quest.interactable = true
  self.lastQuestType = self.questType
  self.lastLevelType = self.curLevelType
  if btnAndGroupID then
    self.curLevelType = DarkZoneGlobal.StcIDToLevel[btnAndGroupID[1]]
    self.questType = btnAndGroupID[0]
  elseif levelGroupID then
    self.curLevelType = DarkZoneGlobal.StcIDToLevel[levelGroupID[1]]
    self.questType = levelGroupID[0]
  end
  self.btnList[self.questType].btnUI.mBtn_Quest.interactable = false
end
function UIDarkZoneQuestPanelV2:CheckBtnUnlock(questType)
  local levelList = DarkZoneGlobal.DepartToLevel[questType]
  local unlock = false
  for i = 1, #levelList do
    unlock = unlock or self:CheckLevelUnlock(DarkZoneGlobal.StcIDToLevel[levelList[i]])
  end
  return unlock
end
function UIDarkZoneQuestPanelV2:CheckBtnFinish(questType)
  local levelList = DarkZoneGlobal.DepartToLevel[questType]
  local finish = true
  for i = 1, #levelList do
    finish = finish and self:CheckLevelFinish(DarkZoneGlobal.StcIDToLevel[levelList[i]])
  end
  return finish
end
function UIDarkZoneQuestPanelV2:CheckLevelUnlockMinLevel(level)
  local questList = self.questGroup[level]
  local minUnlockLevel = 99999999
  local questID = 0
  for i = 1, #questList do
    if minUnlockLevel >= questList[i].unlock1 and questList[i].recommend_show == true then
      minUnlockLevel = questList[i].unlock1
      questID = questList[i].id
    end
  end
  for i = 1, #questList do
    if minUnlockLevel >= questList[i].unlock1 and questList[i].recommend_show == false then
      minUnlockLevel = questList[i].unlock1
      questID = questList[i].id
    end
  end
  return minUnlockLevel, questID
end
function UIDarkZoneQuestPanelV2:CheckLevelUnlockOneLevel(level)
  local questList = self.questGroup[level]
  local minUnlockLevel, questID = self:CheckLevelUnlockMinLevel(level)
  for i = 1, #questList do
    if questList[i].unlock1 <= self.userLevel then
      minUnlockLevel = questList[i].unlock1
      questID = questList[i].id
    end
  end
  return minUnlockLevel, questID
end
function UIDarkZoneQuestPanelV2:CheckLevelUnlockMinLevelUnlock2(questID)
  local reason = ""
  local quest = TableData.listDarkzoneSystemQuestDatas:GetDataById(questID)
  for i = 0, quest.unlock2.Count - 1 do
    if self.hasFinishQuestList and self.hasFinishQuestList[quest.unlock2[i]] ~= true then
      reason = reason .. TableData.listDarkzoneSystemQuestDatas:GetDataById(quest.unlock2[i]).QuestName.str
    end
  end
  return reason
end
function UIDarkZoneQuestPanelV2:CheckLevelUnlock(level)
  local questList = self.questGroup[level]
  local unlock = false
  for i = 1, #questList do
    unlock = unlock or self:CheckSingleQuestUnlock(questList[i].id)
  end
  if unlock == nil then
    unlock = false
  end
  return unlock
end
function UIDarkZoneQuestPanelV2:CheckLevelFinish(level)
  local questList = self.questGroup[level]
  local finish = false
  for i = 1, #questList do
    finish = finish or self.hasFinishGroupList[level]
  end
  return finish
end
function UIDarkZoneQuestPanelV2:CheckByLevel(level, isLess)
  self.userLevel = AccountNetCmdHandler:GetLevel()
  if not isLess then
    if level <= self.userLevel then
      return true
    end
  elseif level > self.userLevel then
    return true
  end
  return false
end
function UIDarkZoneQuestPanelV2:CheckSingleQuestUnlock(questID)
  local quest = TableData.listDarkzoneSystemQuestDatas:GetDataById(questID)
  local unlock = true
  unlock = self:CheckByLevel(quest.unlock1) and self:CheckFrontFinish(questID)
  return unlock
end
function UIDarkZoneQuestPanelV2:CheckFrontFinish(questID)
  local quest = TableData.listDarkzoneSystemQuestDatas:GetDataById(questID)
  local frontFinish = true
  for i = 0, quest.unlock2.Count - 1 do
    frontFinish = frontFinish and self.hasFinishQuestList[quest.unlock2[i]]
  end
  return frontFinish
end
function UIDarkZoneQuestPanelV2:CheckBtnAllUnlock(questType)
  local levelList = DarkZoneGlobal.DepartToLevel[questType]
  local unlock = true
  for i = 1, #levelList do
    unlock = unlock and self:CheckLevelUnlock(DarkZoneGlobal.StcIDToLevel[levelList[i]])
  end
  return unlock
end
function UIDarkZoneQuestPanelV2:OnUpdate()
  if not self.moveFlag then
    self.moveFlag = self.parentPanel.ui.mMoveController:UpdateTime(CS.UnityEngine.Time.deltaTime, self.moveFlag)
    if self.moveFlag then
      self.ui.mBtn_PreGun.interactable = true
      self.ui.mBtn_NextGun.interactable = true
    end
  end
end
function UIDarkZoneQuestPanelV2:UpdateRedPoint()
  self.parentPanel.mTopTab[DarkZoneGlobal.PanelType.Quest]:SetRedPoint(NetCmdDarkZoneSeasonData:UpdateQuestRedPoint() > 0)
  for k, v in pairs(DarkZoneGlobal.DepartToLevel) do
    setactive(self.btnList[k].btnUI.mTrans_RedPoint, 0 < self:UpdateBtnRedPoint(v))
  end
end
function UIDarkZoneQuestPanelV2:UpdateBtnRedPoint(LevelStcID)
  local seasonQuestList = LevelStcID
  local userLevel = AccountNetCmdHandler:GetLevel()
  local count = 0
  for i = 1, #seasonQuestList do
    local questBundle = TableData.listDarkzoneSystemQuestBundleDatas:GetDataById(seasonQuestList[i])
    local isUnlock = PlayerPrefs.GetInt(self.uid .. DarkZoneGlobal.NewQuestGroupUnlock .. questBundle.quest_group) == 1
    local tmp = DarkZoneGlobal.StcIDToLevel[questBundle.QuestGroup] // 3
    local posIndex = tmp * 3
    if self:CheckLevelUnlock(DarkZoneGlobal.StcIDToLevel[questBundle.QuestGroup]) and isUnlock == false and questBundle.QuestGroup ~= TableData.GlobalDarkzoneData.DzQuestGroupShow then
      count = count + 1
    end
  end
  return count
end
function UIDarkZoneQuestPanelV2:OnShowFinish()
end
function UIDarkZoneQuestPanelV2:OnBackFrom()
  self:UpdateLock()
  self:UpdateBtnLock()
  self:UpdateBtnFinish()
  for i = 0, TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup.Count - 1 do
    local isShowPopId = false
    local id = TableData.GlobalSystemData.DarkzoneBeginnerQuestGroup[i]
    local newbiefinish = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.NewBieGroupFinishKey .. "_" .. id) == 1
    isShowPopId = self:CheckNewBieFinishById(id)
    if isShowPopId and not newbiefinish then
      self:OnNewBieFinish(id)
    end
  end
  self:CheckQuestFinishPop()
  self:OnClickQuestType()
  self:ShowCurTypeList(true, false, false, true)
end
function UIDarkZoneQuestPanelV2:CheckExploreUnlock(isFromShow)
  local toExploreFlag = false
  local season = TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID)
  for k, v in pairs(self.hasFinishQuestList) do
    local questId = k
    local isUnlock = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.ExploreZoneUnlock .. questId) == 1
    if not isUnlock and questId == season.explore_unlock then
      toExploreFlag = true
      self:SetIsShowPopState(false)
      CS.PopupMessageManager.PopupDarkZoneQuestStateChange(TableData.GetHintById(240055), function()
        self:SetIsShowPopState(true)
      end)
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.ExploreZoneUnlock .. questId, 1)
    end
  end
  for k, v in pairs(self.hasFinishQuestList) do
    local questId = k
    local isUnlock = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.QuestUnlock .. questId) == 1
    if not isUnlock then
      for j = 0, NetCmdDarkZoneSeasonData.SeasonExploreList.Count - 1 do
        if NetCmdDarkZoneSeasonData.SeasonExploreList[j] == questId then
          toExploreFlag = true
          self:SetIsShowPopState(false)
          TimerSys:DelayCall(DarkZoneGlobal.PopDelayTimeZone, function()
            CS.PopupMessageManager.PopupDZStateChangeString(TableData.GetHintById(240056 + j), function()
              self:SetIsShowPopState(true)
            end)
          end)
          PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.QuestUnlock .. questId, 1)
        end
      end
    end
  end
  if toExploreFlag then
    if self.fadeInList then
      for i = 1, #self.fadeInList do
        TimerSys:RemoveTimer(self.fadeInList[i])
      end
    end
    self:SetAnimatorEmpty()
  end
  return toExploreFlag
end
function UIDarkZoneQuestPanelV2:CheckEndlessUnlock(isFromShow)
  local toEndlessFlag = false
  local season = TableData.listDarkzoneSeasonDatas:GetDataById(NetCmdDarkZoneSeasonData.SeasonID)
  for k, v in pairs(self.hasFinishQuestList) do
    local questId = k
    local isUnlock = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.EndLessZoneUnlock .. questId) == 1
    if not isUnlock and questId == season.endless_unlock then
      toEndlessFlag = true
      self:SetIsShowPopState(false)
      CS.PopupMessageManager.PopupDarkZoneQuestStateChange(TableData.GetHintById(240104), function()
        self:SetIsShowPopState(true)
      end)
      PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.EndLessZoneUnlock .. questId, 1)
    end
  end
  if toEndlessFlag then
    if self.fadeInList then
      for i = 1, #self.fadeInList do
        TimerSys:RemoveTimer(self.fadeInList[i])
      end
    end
    self:SetAnimatorEmpty()
  end
  return toEndlessFlag
end
function UIDarkZoneQuestPanelV2:CheckQuestFinishPop()
  local questID = PlayerPrefs.GetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.QuestCacheIDKey)
  local quest
  if questID ~= 0 then
    quest = TableData.listDarkzoneSystemQuestDatas:GetDataById(questID)
  end
  if not quest then
    return
  end
  local tips = string.split(quest.quest_unlock_tips.str, ";")
  for i = 1, #tips do
    if tips[i] ~= "" then
      TimerSys:DelayCall(DarkZoneGlobal.PopDelayTimeZone, function()
        self:SetIsShowPopState(false)
        PopupMessageManager.PopupDZStateChangeString(tips[i], function()
          self:SetIsShowPopState(true)
        end)
      end)
    end
  end
  PlayerPrefs.SetInt(AccountNetCmdHandler:GetUID() .. DarkZoneGlobal.QuestCacheIDKey, 0)
end
function UIDarkZoneQuestPanelV2:SetAnimatorFadeOut()
  local temp = self.curLevelType // 3
  local posIndex = temp * 3
  if self.curLevelType - 1 == posIndex then
    self:SetQuestAnimatorFadeOut(self.easyList)
  elseif self.curLevelType - 2 == posIndex then
    self:SetQuestAnimatorFadeOut(self.hardList)
  elseif self.curLevelType == posIndex then
    self:SetQuestAnimatorFadeOut(self.veryHardList)
  end
end
function UIDarkZoneQuestPanelV2:SetAnimatorEmpty()
  local temp = self.curLevelType // 3
  local posIndex = temp * 3
  if self.curLevelType - 1 == posIndex then
    self:SetQuestAnimatorEmpty(self.easyList)
  elseif self.curLevelType - 2 == posIndex then
    self:SetQuestAnimatorEmpty(self.hardList)
  elseif self.curLevelType == posIndex then
    self:SetQuestAnimatorEmpty(self.veryHardList)
  end
end
function UIDarkZoneQuestPanelV2:SetAllAnimatorFadeOut()
  self:SetQuestAnimatorFadeOut(self.easyList)
  self:SetQuestAnimatorFadeOut(self.hardList)
  self:SetQuestAnimatorFadeOut(self.veryHardList)
end
function UIDarkZoneQuestPanelV2:SetAllAnimatorEmpty()
  self:SetQuestAnimatorEmpty(self.easyList)
  self:SetQuestAnimatorEmpty(self.hardList)
  self:SetQuestAnimatorEmpty(self.veryHardList)
end
function UIDarkZoneQuestPanelV2:SetFixedPos()
  local temp = self.curLevelType // 3
  local posIndex = temp * 3
  if self.curLevelType - 1 == posIndex then
    self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition = DarkZoneGlobal.QuestMapPos.Normal
  elseif self.curLevelType - 2 == posIndex then
    self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition = DarkZoneGlobal.QuestMapPos.Hard
  elseif self.curLevelType == posIndex then
    self.parentPanel.ui.mAnimator_Map.transform.anchoredPosition = DarkZoneGlobal.QuestMapPos.VeryHard
  end
end
function UIDarkZoneQuestPanelV2:SetAnimatorFadeIn()
  local temp = self.curLevelType // 3
  local posIndex = temp * 3
  if self.curLevelType - 1 == posIndex then
    self:SetQuestAnimatorFadeIn(self.easyList)
  elseif self.curLevelType - 2 == posIndex then
    self:SetQuestAnimatorFadeIn(self.hardList)
  elseif self.curLevelType == posIndex then
    self:SetQuestAnimatorFadeIn(self.veryHardList)
  end
end
function UIDarkZoneQuestPanelV2:OnClose()
end
function UIDarkZoneQuestPanelV2:Hide()
  self.lastLevelType = 0
end
function UIDarkZoneQuestPanelV2:OnHide()
end
function UIDarkZoneQuestPanelV2:OnHideFinish()
end
function UIDarkZoneQuestPanelV2:Release()
  MessageSys:RemoveListener(CS.GF2.Message.CommonEvent.ItemUpdate, self.OnUpdateItem)
  self:ReleaseCtrlTable(self.easyList, true)
  self:ReleaseCtrlTable(self.hardList, true)
  self:ReleaseCtrlTable(self.veryHardList, true)
  self.easyList = nil
  self.hardList = nil
  self.veryHardList = nil
end
function UIDarkZoneQuestPanelV2:IsReadyStartTutorial()
  return self.questIsShowPop
end
function UIDarkZoneQuestPanelV2:SetIsShowPopState(bool)
  self.questIsShowPop = bool
end
