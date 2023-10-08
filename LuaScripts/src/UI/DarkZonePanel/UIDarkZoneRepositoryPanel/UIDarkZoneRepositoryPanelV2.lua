require("UI.Common.UICommonLeftTabItemV2")
require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.UIDarkZoneRepositoryGlobal")
require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.SubPanel.UIDarkZoneRepositoryChipMaterialPanel")
require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.SubPanel.UIDarkZoneRepositorySearchChipPanel")
require("UI.Repository.RepositoryPanel.SubPanel.UIRepositoryBasePanel")
UIDarkZoneRepositoryPanelV2 = class("UIDarkZoneRepositoryPanelV2", UIBasePanel)
function UIDarkZoneRepositoryPanelV2:ctor(csPanel)
  UIDarkZoneRepositoryPanelV2.super.ctor(self, csPanel)
end
function UIDarkZoneRepositoryPanelV2:OnAwake(root, tabId)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.leftTabTable = {}
  self.subPanelTable = {}
  self.sortItemTable = {}
  self.DropdownItemTable = {}
  self.isAscend = false
  self.isSortDropDownActive = false
  UIUtils.GetButtonListener(self.ui.mBtn_BackItem.gameObject).onClick = function()
    self:OnReturnClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_HomeItem.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  self:InitAllSubPanel()
  self:InitTabButton()
end
function UIDarkZoneRepositoryPanelV2:OnInit(root, tabId)
  self.curTabId = 0
  self.curPanelId = 0
  self.curSort = 0
  local defaultTabId = 1
  if TableData.listDarkzoneRepositoryTagDatas.Count ~= 0 then
    defaultTabId = TableData.listDarkzoneRepositoryTagDatas:GetDataByIndex(0).id
  end
  local targetTabId = tabId or defaultTabId
  if tabId and type(tabId) == "userdata" then
    targetTabId = tabId[0]
  elseif tabId then
    targetTabId = tabId
  end
  self:OnClickTab(targetTabId)
end
function UIDarkZoneRepositoryPanelV2:OnShowStart()
  local subPanel = self.subPanelTable[self.curPanelId]
  if subPanel ~= nil then
    subPanel:OnShowStart()
  end
end
function UIDarkZoneRepositoryPanelV2:OnBackFrom()
  self.subPanelTable[self.curPanelId]:OnPanelBack()
  UIManager.EnableFacilityBarrack(false)
end
function UIDarkZoneRepositoryPanelV2:OnTop()
  self.subPanelTable[self.curPanelId]:OnPanelBack()
  UIManager.EnableFacilityBarrack(false)
end
function UIDarkZoneRepositoryPanelV2:OnFadeInFinish()
end
function UIDarkZoneRepositoryPanelV2:OnClose()
  for i, tab in pairs(self.leftTabTable) do
    tab:SetItemState(false)
  end
  local subPanel = self.subPanelTable[self.curPanelId]
  if subPanel then
    subPanel:Close()
  end
  self.curTabId = nil
  self.curPanelId = nil
  self.curSort = nil
end
function UIDarkZoneRepositoryPanelV2:OnRelease()
  self:ReleaseCtrlTable(self.leftTabTable, true)
  self:ReleaseCtrlTable(self.sortItemTable, true)
  for _, panel in pairs(self.subPanelTable) do
    panel:OnRelease()
  end
  self.subPanelTable = nil
end
function UIDarkZoneRepositoryPanelV2:InitAllSubPanel()
  local allPanelTagDataList = TableData.listDarkzoneRepositoryTagDatas
  for i = 0, allPanelTagDataList.Count - 1 do
    self:InitSubPanel(allPanelTagDataList[i].Id)
  end
end
function UIDarkZoneRepositoryPanelV2:InitSubPanel(panelId)
  local subPanel
  if panelId == UIDarkZoneRepositoryGlobal.PanelType.SearchChip then
    subPanel = UIDarkZoneRepositorySearchChipPanel.New(self, panelId, self.ui.mCanvasGroup_Other)
  elseif panelId == UIDarkZoneRepositoryGlobal.PanelType.ChipMaterial then
    subPanel = UIDarkZoneRepositoryChipMaterialPanel.New(self, panelId, self.ui.mCanvasGroup_Other)
  end
  self.subPanelTable[panelId] = subPanel
end
function UIDarkZoneRepositoryPanelV2:InitTabButton()
  local childItem = self.ui.mContent_Tab.transform:GetComponent(typeof(CS.ScrollListChild))
  local leftTabMobilePrefab = childItem.childItem
  local leftTabPCPrefab = childItem.childItem
  local typeList = TableData.listDarkzoneRepositoryTagDatas:GetList()
  local list = {}
  for i = 0, typeList.Count - 1 do
    local type = typeList[i]
    list[type.sequence] = type
  end
  for id, data in pairs(list) do
    if data ~= nil then
      local item = UICommonLeftTabItemV2.New()
      local obj = instantiate(leftTabMobilePrefab, self.ui.mContent_Tab.transform)
      item:InitCtrl(obj.transform)
      item:SetName(data.id, data.title.str)
      item:SetUnlock(data.unlock)
      UIUtils.GetButtonListener(item.ui.mBtn_Self.gameObject).onClick = function()
        self:OnClickTab(item.tagId)
      end
      table.insert(self.leftTabTable, item)
    end
  end
  self:RefreshRedPoint()
  setactive(self.ui.mTrans_LeftMobile, true)
end
function UIDarkZoneRepositoryPanelV2:RefreshRedPoint()
end
function UIDarkZoneRepositoryPanelV2:OnClickTab(tabId)
  if self.curTabId == tabId or tabId == nil or tabId <= 0 then
    return
  end
  local tagData = TableData.listDarkzoneRepositoryTagDatas:GetDataById(tabId)
  if tagData == nil then
    return
  end
  local unlockId = UIDarkZoneRepositoryGlobal.SystemIdList[tabId]
  if TipsManager.NeedLockTips(unlockId) then
    return
  end
  if self.curTabId > 0 then
    local lastTab = self:GetLeftTabByTagId(self.curTabId)
    lastTab:SetItemState(false)
  end
  local curTab = self:GetLeftTabByTagId(tabId)
  curTab:SetItemState(true)
  self.curTabId = tabId
  self:SwitchPanel(tabId)
end
function UIDarkZoneRepositoryPanelV2:GetLeftTabByTagId(tagId)
  for i, tab in pairs(self.leftTabTable) do
    if tab.tagId == tagId then
      return tab
    end
  end
  return nil
end
function UIDarkZoneRepositoryPanelV2:SwitchPanel(panelId)
  local curPanel = self.subPanelTable[self.curPanelId]
  if curPanel then
    curPanel:Close()
  end
  self.curPanelId = panelId
  local subPanel = self.subPanelTable[panelId]
  if panelId == 6 then
    setactive(self.ui.mBtn_Desc, true)
  else
    setactive(self.ui.mBtn_Desc, false)
  end
  if subPanel then
    subPanel:Show()
    subPanel:Refresh()
  end
end
function UIDarkZoneRepositoryPanelV2:OnReturnClick(go)
  UIManager.CloseUI(UIDef.UIDarkZoneRepositoryPanel)
end
function UIDarkZoneRepositoryPanelV2:ResetEscapeBtn(boolean, action)
  if boolean then
    self:UnRegistrationKeyboard(KeyCode.Escape)
    self:RegistrationKeyboardAction(KeyCode.Escape, function()
      if action ~= nil then
        action()
      end
    end)
  else
    self:UnRegistrationKeyboard(KeyCode.Escape)
    self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_BackItem)
  end
end
