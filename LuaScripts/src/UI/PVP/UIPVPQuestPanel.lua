require("UI.PVP.UIPVPQuestNewbiePanel")
UIPVPQuestPanel = class("UIPVPQuestPanel", UIBasePanel)
function UIPVPQuestPanel:OnAwake(root)
end
function UIPVPQuestPanel:OnInit(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBack.gameObject, function()
    self:onClickBack()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnHome.gameObject, function()
    self:onClickHome()
  end)
  self.tabTable = {}
  self.curTabIndex = nil
  self.subPanelTable = {}
  self:initAllSubPanel()
end
function UIPVPQuestPanel:OnShowStart()
  local isAllPhaseComplete = NetCmdQuestData:CheckNewbiePhaseIsReceived(self:getMaxPhaseId())
  self:onClickTab(1)
end
function UIPVPQuestPanel:OnShowFinish()
  TimerSys:DelayCall(0.5, function()
    self.ui.mCanvas_Mission.blocksRaycasts = true
  end)
end
function UIPVPQuestPanel:OnRecover()
  self:OnShowStart()
end
function UIPVPQuestPanel:OnBackFrom()
  self:onPanelBack()
end
function UIPVPQuestPanel:OnTop()
  self:onDialogBack()
end
function UIPVPQuestPanel:OnSave()
  UIQuestGlobal.cachedTabIndex = self.curTabIndex
end
function UIPVPQuestPanel:OnClose()
  for i, subPanel in pairs(self.subPanelTable) do
    subPanel:Release()
  end
  self:ReleaseCtrlTable(self.tabTable, true)
  self.curTabIndex = nil
  self.ui = nil
end
function UIPVPQuestPanel:Refresh()
  self:refreshTabRedPoint()
end
function UIPVPQuestPanel:initAllTopTab()
  local taskTypeDataList = TableData.listTaskTypeDatas:GetList()
  local tabTemplate = self.ui.mScrollItem_TopTab.childItem
  local sortedTable = {}
  for i = 0, taskTypeDataList.Count - 1 do
    local taskTypeData = taskTypeDataList[i]
    if taskTypeData.Sequence == 4 then
      table.insert(sortedTable, taskTypeDataList[i])
    end
  end
  table.sort(sortedTable, function(a, b)
    return a.Sequence < b.Sequence
  end)
  for i = 1, #sortedTable do
    local taskTypeData = sortedTable[i]
    local tab = UICommonTab.New(instantiate(tabTemplate, self.ui.mScrollItem_TopTab.transform))
    tab:InitByTaskTypeData(taskTypeData, i, function(tabIndex)
      self:onClickTab(tabIndex)
    end)
    local isUnlock = AccountNetCmdHandler:CheckSystemIsUnLock(tab:GetUnlockId())
    local redPointVisible = isUnlock and NetCmdPVPQuestData:CheckIshaveGetReward(tab:GetType())
    tab:SetRedPointVisible(redPointVisible)
    tab:SetLockIconVisible(not isUnlock)
    tab:SetMainIconVisible(isUnlock)
    table.insert(self.tabTable, tab)
  end
  if #sortedTable <= 1 then
    setactive(self.ui.mScrollItem_TopTab, false)
  end
end
function UIPVPQuestPanel:initAllSubPanel()
  local tempSubPanelTable = {}
  table.insert(tempSubPanelTable, UIPVPQuestNewbiePanel.New(self.ui.mTrans_Novice.gameObject, self))
  local getSubPanelByType = function(tabType, subPanelTable)
    for i, subPanel in ipairs(subPanelTable) do
      if not subPanel.GetTaskTypeId then
        gferror("请实现函数GetTaskTypeId()")
        return
      end
      if tabType == subPanel:GetTaskTypeId() then
        return subPanel
      end
    end
  end
  self.subPanelTable[1] = getSubPanelByType(1, tempSubPanelTable)
end
function UIPVPQuestPanel:onClickTab(tabIndex)
  local preTabIndex = self.curTabIndex
  self.curTabIndex = tabIndex
  self:onTabChanged(preTabIndex, self.curTabIndex)
end
function UIPVPQuestPanel:onTabChanged(preTabIndex, curTabIndex)
  if preTabIndex and self.subPanelTable[preTabIndex] then
    self.subPanelTable[preTabIndex]:Hide()
  end
  if curTabIndex then
    local targetSubPanel = self.subPanelTable[curTabIndex]
    if targetSubPanel then
      targetSubPanel:Show()
      self.ui.mAnimator:SetInteger("PageSwitch", targetSubPanel:GetAnimPageSwitchInt())
    end
  end
  TimerSys:DelayCall(0.5, function()
    self.ui.mCanvas_Mission.blocksRaycasts = true
  end)
end
function UIPVPQuestPanel:onPanelBack()
  local targetSubPanel = self.subPanelTable[self.curTabIndex]
  if targetSubPanel then
    targetSubPanel:OnPanelBack()
    self.ui.mAnimator:SetInteger("PageSwitch", targetSubPanel:GetAnimPageSwitchInt())
  end
end
function UIPVPQuestPanel:onDialogBack()
  local targetSubPanel = self.subPanelTable[self.curTabIndex]
  if targetSubPanel then
    targetSubPanel:OnDialogBack()
    self.ui.mAnimator:SetInteger("PageSwitch", targetSubPanel:GetAnimPageSwitchInt())
  end
end
function UIPVPQuestPanel:getMaxPhaseId()
  local dataList = TableData.listNrtpvpTaskGuideDatas:GetList()
  return dataList[dataList.Count - 1].id
end
function UIPVPQuestPanel:refreshTabRedPoint()
end
function UIPVPQuestPanel:onClickHome()
  UIManager.JumpToMainPanel()
end
function UIPVPQuestPanel:onClickBack()
  UIManager.CloseUI(UIDef.UIPVPQuestPanel)
end
