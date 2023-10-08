UISimCombatProTalentPanel = class("UISimCombatProTalentPanel", UIBasePanel)
function UISimCombatProTalentPanel:OnInit(root, simEntranceId)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  self.simEntranceId = simEntranceId
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBack.gameObject, function()
    self:onClickBack()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnHome.gameObject, function()
    self:onClickHome()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnProfessionalInfo.gameObject, function()
    self:onClickProTalentInfo()
  end)
  function self.onRaidDuringEndCallback(msg)
    self:onRaidDuringEnd(msg)
  end
  MessageSys:AddListener(UIEvent.OnRaidDuringEnd, self.onRaidDuringEndCallback)
  self.tabTable = {}
  self.slotTable = {}
  self.curTabIndex = nil
  self.curSlotIndex = 0
  self.entranceData = nil
  self.simTypeDataList = nil
  self.curSimTypeData = nil
  self.simDutyDataTableDict = {}
  local simCombatDutyDataList = TableData.listSimCombatDutyDatas:GetList()
  for i = 0, simCombatDutyDataList.Count - 1 do
    local simCombatDutyData = simCombatDutyDataList[i]
    if not self.simDutyDataTableDict[simCombatDutyData.sim_type] then
      self.simDutyDataTableDict[simCombatDutyData.sim_type] = {}
    end
    table.insert(self.simDutyDataTableDict[simCombatDutyData.sim_type], simCombatDutyData)
  end
  for _, simCombatDutyDataTable in ipairs(self.simDutyDataTableDict) do
    table.sort(simCombatDutyDataTable, function(a, b)
      return tonumber(a.Id) < tonumber(b.Id)
    end)
  end
end
function UISimCombatProTalentPanel:OnShowStart()
  self.entranceData = TableData.listSimCombatEntranceDatas:GetDataById(self.simEntranceId)
  self.simTypeDataList = NetCmdSimulateBattleData:GetSimulateLabelByType(self.simEntranceId)
  self.ui.mText_Title.text = self.entranceData.name.str
  NetCmdSimulateBattleData:ReqPlanData(PlanType.PlanFunctionSimDailyopen.value__, function()
    self:initAllSlot()
    self:initAllTab()
    local tabIndex = UISimCombatGlobal.CachedProTalentTabIndex or self:getFirstActivatedTabIndex()
    self:onClickTab(tabIndex)
  end)
  self:refreshTimes()
end
function UISimCombatProTalentPanel:OnRelease()
  self.curTabIndex = nil
  self.curSlotIndex = nil
  for k, tab in pairs(self.slotTable) do
    tab:OnRelease()
  end
  self.slotTable = nil
  for k, slot in pairs(self.tabTable) do
    slot:OnRelease()
  end
  self.tabTable = nil
  self.ui = nil
  MessageSys:RemoveListener(UIEvent.OnRaidDuringEnd, self.onRaidDuringEndCallback)
end
function UISimCombatProTalentPanel:Refresh()
  self:refreshTimes()
end
function UISimCombatProTalentPanel:OnSave()
  UISimCombatGlobal.CachedProTalentTabIndex = self.curTabIndex
end
function UISimCombatProTalentPanel:initAllTab()
  if not self.simTypeDataList or self.simTypeDataList.Count == 0 then
    return
  end
  if #self.tabTable ~= 0 then
    for i, tab in ipairs(self.tabTable) do
      local simTypeData = self.simTypeDataList[i - 1]
      tab:SetData(simTypeData, i, function(tabIndex)
        self:onClickTab(tabIndex)
      end, self)
      tab:Refresh()
    end
  else
    local tabTemplate = self.ui.mScrollItem_Tab.childItem
    for i = 0, self.simTypeDataList.Count - 1 do
      local simTypeData = self.simTypeDataList[i]
      local tab = UISimCombatProTalentTab.New(instantiate(tabTemplate, self.ui.mScrollItem_Tab.transform))
      tab:SetData(simTypeData, i + 1, function(tabIndex)
        self:onClickTab(tabIndex)
      end, self)
      tab:Refresh()
      table.insert(self.tabTable, tab)
    end
  end
end
function UISimCombatProTalentPanel:initAllSlot()
  if #self.slotTable ~= 0 then
    local curTab = self:getCurTab()
    if not curTab then
      return
    end
    local simTypeData = curTab:GetSimTypeData()
    local dutyDataTable = self.simDutyDataTableDict[simTypeData.id]
    for i, slot in ipairs(self.slotTable) do
      slot:SetData(dutyDataTable[i], simTypeData.DutyId, i, function(index)
        self:onClickSlot(index)
      end)
      slot:Refresh()
    end
  else
    local slotTemplate = self.ui.mScrollItem_Slot.childItem
    local firstSimTypeData = self.simTypeDataList[0]
    local simDutyDataTable = self.simDutyDataTableDict[firstSimTypeData.id]
    for i, simDutyData in ipairs(simDutyDataTable) do
      local slot = UISimCombatProTalentSlot.New(instantiate(slotTemplate, self.ui.mScrollItem_Slot.transform))
      slot:SetData(simDutyData, firstSimTypeData.DutyId, i, function(index)
        self:onClickSlot(index)
      end)
      slot:Refresh()
      table.insert(self.slotTable, slot)
    end
  end
end
function UISimCombatProTalentPanel:onClickTab(tabIndex)
  if not tabIndex or self.curTabIndex == tabIndex then
    return
  end
  if tabIndex < 0 or tabIndex > #self.tabTable then
    return
  end
  local targetTab = self.tabTable[tabIndex]
  if targetTab then
    if TipsManager.NeedLockTips(targetTab:GetUnlockId()) then
      return
    end
    if not targetTab:IsOpen() then
      PopupMessageManager.PopupString(TableData.GetHintById(103080))
      return
    end
  end
  if self.tabTable[self.curTabIndex] then
    self.tabTable[self.curTabIndex]:Deselect()
  end
  self.curTabIndex = tabIndex
  if targetTab then
    targetTab:Select()
    self:onClickTabAfter()
  end
end
function UISimCombatProTalentPanel:onClickSlot(slotIndex)
  if not slotIndex or self.curSlotIndex == slotIndex then
    return
  end
  if slotIndex < 0 or slotIndex > #self.slotTable then
    return
  end
  if self.slotTable[self.curSlotIndex] then
    self.slotTable[self.curSlotIndex]:Deselect()
  end
  self.curSlotIndex = slotIndex
  if self.slotTable[self.curSlotIndex] then
    self.slotTable[self.curSlotIndex]:Select()
    self:onClickSlotAfter()
  end
end
function UISimCombatProTalentPanel:onClickBack()
  UISimCombatGlobal.CachedProTalentTabIndex = nil
  UIManager.CloseUI(UIDef.UISimCombatProTalentPanel)
end
function UISimCombatProTalentPanel:onClickTabAfter()
  local curTab = self:getCurTab()
  if not curTab then
    return
  end
  self.curSimTypeData = curTab:GetSimTypeData()
  self:switchContent()
end
function UISimCombatProTalentPanel:onClickSlotAfter()
  self:showRightPanel()
  self:doContentMoveByCurSlotIndex()
end
function UISimCombatProTalentPanel:switchContent()
  self.ui.mFade_Content:DoScrollFade()
  if not self.curSimTypeData then
    return
  end
  local dutyDataTable = self.simDutyDataTableDict[self.curSimTypeData.id]
  for i, slot in ipairs(self.slotTable) do
    slot:SetData(dutyDataTable[i], self.curSimTypeData.DutyId, i, function(index)
      self:onClickSlot(index)
    end)
    slot:Refresh()
  end
end
function UISimCombatProTalentPanel:showRightPanel()
  local curSlot = self:getCurSlot()
  if not curSlot then
    return
  end
  self.ui.mVirtualListEx.enabled = false
  local simDutyData = curSlot:GetSimDutyData()
  local stageData = curSlot:GetStageData()
  local recordData = curSlot:GetRecordData()
  local isUnLock = curSlot:IsUnlock()
  local index = curSlot:GetSlotIndex()
  local preSlot = self:getPreSlot(index)
  local isLastCanBattle = true
  if preSlot then
    local preStageData = preSlot:GetStageData()
    isLastCanBattle = self:checkStageRecordPass(preStageData.Id)
  end
  UIBattleDetailDialog.OpenBySimCombatData(UIDef.UISimCombatProTalentPanel, stageData, recordData, simDutyData, isUnLock, isLastCanBattle, function()
    self:onCloseRightPanel()
  end)
end
function UISimCombatProTalentPanel:getPreSlot(index)
  local targetIndex = index - 1
  if targetIndex < 1 or targetIndex > #self.slotTable then
    return nil
  end
  return self.slotTable[targetIndex]
end
function UISimCombatProTalentPanel:doContentMoveByCurSlotIndex()
  local layoutGroup = self.ui.mLayoutGroup_Content
  local elementWidth = layoutGroup.cellSize.x + layoutGroup.spacing.x
  local offset = 0
  if self:checkPlatform(CS.PlatformSetting.PlatformType.Mobile) then
    offset = -50
  elseif self:checkPlatform(CS.PlatformSetting.PlatformType.PC) then
    offset = 100
  end
  local to = 0
  if self.curSlotIndex <= 1 then
    to = 0
  elseif self.curSlotIndex == 2 then
    to = offset
  elseif self.curSlotIndex == #self.slotTable then
    to = -((self.curSlotIndex - 3) * elementWidth) + offset
  else
    to = -((self.curSlotIndex - 2) * elementWidth) + offset
  end
  UITweenManager.PlayAnchoredPositionXTween(self.ui.mTrans_Content, to, 0.3, nil, CS.DG.Tweening.Ease.OutQuad)
end
function UISimCombatProTalentPanel:getCurTab()
  return self.tabTable[self.curTabIndex]
end
function UISimCombatProTalentPanel:getCurSlot()
  return self.slotTable[self.curSlotIndex]
end
function UISimCombatProTalentPanel:onClickHome()
  UISimCombatGlobal.CachedProTalentTabIndex = nil
  UIManager.JumpToMainPanel()
end
function UISimCombatProTalentPanel:onClickProTalentInfo()
  UIManager.OpenUI(UIDef.UISimCombatDutyOpenDateDialog)
end
function UISimCombatProTalentPanel:onCloseRightPanel()
  self.ui.mVirtualListEx.enabled = true
  self:onClickSlot(0)
end
function UISimCombatProTalentPanel:refreshTimes()
  setactive(self.ui.mTrans_GrpExtraReward, false)
  setactive(self.ui.mTrans_GrpRemainingTimes, false)
  local entranceData = self.entranceData
  if entranceData.extra_drop_cost ~= 0 then
    setactive(self.ui.mTrans_GrpExtraReward, true)
    local haveNum = NetCmdItemData:GetNetItemCount(entranceData.extra_drop_cost)
    local costData = TableData.listCostDatas:GetDataById(4)
    self.ui.mText_DoubleTalent.text = haveNum .. "/" .. costData.extra_item
  end
  if entranceData.item_id ~= 0 then
    setactive(self.ui.mTrans_GrpRemainingTimes, true)
    local haveNum = NetCmdItemData:GetNetItemCount(entranceData.item_id)
    local costData = TableData.listCostDatas:GetDataById(4)
    self.ui.mText_TalentTimes.text = haveNum .. "/" .. costData.cost_item
  end
end
function UISimCombatProTalentPanel:getFirstActivatedTabIndex()
  for i, tab in ipairs(self.tabTable) do
    if tab:IsOpen() and tab:IsUnlock() then
      return i
    end
  end
  return -1
end
function UISimCombatProTalentPanel:checkPlatform(platformType)
  return platformType == CS.GameRoot.Instance.AdapterPlatform
end
function UISimCombatProTalentPanel:checkStageRecordPass(stageId)
  local stageRecord = NetCmdStageRecordData:GetStageRecordById(stageId, false)
  if stageRecord ~= nil and stageRecord.first_pass_time > 0 then
    return true
  end
  return false
end
function UISimCombatProTalentPanel:onRaidDuringEnd(msg)
  local simTypeId = msg.Sender
  if simTypeId == self.curSimTypeData.Id then
    self:refreshTimes()
  end
end
