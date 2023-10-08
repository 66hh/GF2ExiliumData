require("UI.SimCombatPanel.ResourcesCombat.UISimCombatResourceTab")
UISimCombatResourceTabList = class("UISimCombatResourceTabList", UIBaseCtrl)
function UISimCombatResourceTabList:ctor(root)
  self.super.ctor(self)
  self:SetRoot(root.transform)
  self.ui = UIUtils.GetUIBindTable(root)
  self.tabTable = {}
  self.curTabIndex = -1
end
function UISimCombatResourceTabList:SetData(simEntranceId, targetTabTypeId, fromState)
  self.simEntranceId = simEntranceId
  self:initAllTab()
  self.fromState = fromState
  local tabIndex = self:getTabIndexBySimTypeId(targetTabTypeId)
  self:onClickTab(tabIndex)
end
function UISimCombatResourceTabList:Refresh()
  local isMultiTab = #self.tabTable > 1
  if isMultiTab then
    for i, tab in ipairs(self.tabTable) do
      tab:Refresh()
    end
  end
  self:SetVisible(isMultiTab)
end
function UISimCombatResourceTabList:OnClose()
  self:ReleaseCtrlTable(self.tabTable, true)
  self.curTabIndex = -1
end
function UISimCombatResourceTabList:OnRelease(isDestroy)
  self.simEntranceId = nil
  self.curTabIndex = nil
  self.onClickCallback = nil
  self.tabTable = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UISimCombatResourceTabList:AddClickTabListener(callback)
  self.onClickCallback = callback
end
function UISimCombatResourceTabList:JumpTo(simTypeId)
  if not simTypeId then
    return
  end
  local jumpTabIndex = self:getJumpTabIndex(simTypeId)
  self:SetData(self.simEntranceId, self.tabTable[jumpTabIndex])
end
function UISimCombatResourceTabList:GetCurTabSimTypeId()
  return self:GetCurTabSimTypeData().id
end
function UISimCombatResourceTabList:GetCurTabSimTypeData()
  return self:getCurTab():GetSimTypeData()
end
function UISimCombatResourceTabList:initAllTab()
  local simCombatEntranceData = TableDataBase.listSimCombatEntranceDatas:GetDataById(self.simEntranceId)
  if not simCombatEntranceData then
    return
  end
  LuaUtils.SortBySimCombatType(simCombatEntranceData.LabelId)
  local tempTabTable = {}
  for i = 0, simCombatEntranceData.LabelId.Count - 1 do
    local index = i + 1
    if self.tabTable[index] == nil then
      local tabTemplate = self.ui.mScrollListChild_GrpTabList.childItem
      local tabGo = instantiate(tabTemplate, self.ui.mScrollListChild_GrpTabList.transform)
      self.tabTable[index] = UISimCombatResourceTab.New(tabGo)
    end
    local tab = self.tabTable[index]
    tab:SetData(simCombatEntranceData.LabelId[i], i + 1, function(tabIndex)
      self:onClickTab(tabIndex)
    end)
    if i == simCombatEntranceData.label_id.Count - 1 then
      tab:SetLineVisible(false)
    end
    table.insert(tempTabTable, tab)
  end
  return tempTabTable
end
function UISimCombatResourceTabList:getCurTab()
  return self.tabTable[self.curTabIndex]
end
function UISimCombatResourceTabList:getJumpTabIndex(simTypeDataId)
  if not simTypeDataId then
    return self:getFirstActivatedTabIndex()
  end
  for i, tab in ipairs(self.tabTable) do
    if tab:GetSimTypeData().id == simTypeDataId then
      return i
    end
  end
  return self:getFirstActivatedTabIndex()
end
function UISimCombatResourceTabList:getFirstActivatedTabIndex()
  for i, tab in ipairs(self.tabTable) do
    if tab:IsOpen() and tab:IsUnlock() then
      return i
    end
  end
  return -1
end
function UISimCombatResourceTabList:getTabIndexBySimTypeId(simTypeId)
  if not simTypeId then
    return self.curTabIndex > 0 and self.curTabIndex or 1
  end
  for i, tab in ipairs(self.tabTable) do
    if tab:GetSimTypeData().id == simTypeId then
      return i
    end
  end
  gferror("当前没有找到Target tab index!")
  return 1
end
function UISimCombatResourceTabList:onClickTab(tabIndex)
  if not tabIndex or self.curTabIndex == tabIndex then
    return
  end
  if tabIndex <= 0 or tabIndex > #self.tabTable then
    return
  end
  local targetTab = self.tabTable[tabIndex]
  if targetTab and TipsManager.NeedLockTips(targetTab:GetUnlockId()) then
    return
  end
  if self.tabTable[self.curTabIndex] then
    self.tabTable[self.curTabIndex]:Deselect()
  end
  local preTabIndex = self.curTabIndex
  self.curTabIndex = tabIndex
  if targetTab then
    targetTab:Select()
  end
  MessageSys:SendMessage(UIEvent.ResouceTabClick, self.tabTable[self.curTabIndex].simTypeId)
  self:onTabChanged(preTabIndex, self.curTabIndex)
end
function UISimCombatResourceTabList:onTabChanged(prevTabIndex, currTabIndex)
  local curTab = self:getCurTab()
  if not curTab then
    gferror("当前没有选中的Tab!")
    return
  end
  if self.onClickCallback then
    self.onClickCallback(curTab:GetSimTypeData().id, curTab:IsOpen(), self.fromState)
  end
end
