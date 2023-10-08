require("UI.UIBasePanel")
UIDarkZoneSubMaintenancePanel = class("UIDarkZoneSubMaintenancePanel", UIBaseCtrl)
UIDarkZoneSubMaintenancePanel.__index = UIDarkZoneSubMaintenancePanel
UIDarkZoneSubMaintenancePanel.mView = nil
UIDarkZoneSubMaintenancePanel.Filter = {All = 1, Epiphyllum = 2}
function UIDarkZoneSubMaintenancePanel:ctor()
end
function UIDarkZoneSubMaintenancePanel:InitCtrl(root, parentClass)
  self.parentClass = parentClass
  self:SetRoot(root)
  self.ui = {}
  self.mView = UIDarkZoneSubMaintenancePanelView.New()
  self.mView:InitCtrl(root, self.ui)
  if self.sortItem == nil then
    self.sortItem = UICommonSortItem.New()
    self.nameList = {
      TableData.GetHintById(54),
      TableData.GetHintById(903157),
      TableData.GetHintById(56)
    }
    self.sortItem:InitCtrl(self.ui.mTrans_Screen, self.ui.mBtn_Screen, nil, self.parentClass.mUIRoot, function(sortType, isAscend)
      self:SortItemList(sortType, isAscend)
      self:ApplyFilter(self.curFilterIndex, self.filterItem.curFilter and self.filterItem.curFilter.data or nil)
      self:Show(true)
    end, self.nameList)
  end
  if self.leftTabList == nil then
    self.leftTabList = {}
    for i = 0, 3 do
      local leftTab = UIDarkZoneLeftTabItem.New()
      leftTab:InitCtrl(self.ui.mTrans_LeftContent)
      leftTab:SetData(i)
      UIUtils.GetButtonListener(leftTab.ui.mBtn_Root.gameObject).onClick = function()
        self:ApplyFilter(i, self.filterItem.curFilter and self.filterItem.curFilter.data or nil)
        self:Show(true)
      end
      table.insert(self.leftTabList, leftTab)
    end
  end
  function self.ui.mVirtualList_Bag.itemProvider()
    return self:BagItemProvider()
  end
  function self.ui.mVirtualList_Bag.itemRenderer(index, renderDataItem)
    self:BagItemRenderer(index, renderDataItem)
  end
  function self.ui.mVirtualList_Repo.itemProvider()
    return self:RepoItemProvider()
  end
  function self.ui.mVirtualList_Repo.itemRenderer(index, renderDataItem)
    self:RepoItemRenderer(index, renderDataItem)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnInstall.gameObject).onClick = function()
    self.parentClass:ChangeView(1)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Select.gameObject).onClick = function()
    self:OnClickFilterBtn()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnUninstall.gameObject).onClick = function()
    DarkZoneNetRepoCmdData:StorageMoveOneClick(self.curFilterIndex)
  end
  UIUtils.GetUIBlockHelper(self.ui.mUIRoot, self.ui.mTrans_BagDetail, function()
    self:ShowBagBrief(false)
    self:ShowRepoBrief(false)
  end)
  UIUtils.GetUIBlockHelper(self.ui.mUIRoot, self.ui.mTrans_RepoDetail, function()
    self:ShowBagBrief(false)
    self:ShowRepoBrief(false)
  end)
  UIUtils.GetUIBlockHelper(self.ui.mUIRoot, self.ui.mTrans_Filter, function()
    self:ShowFilter(false)
  end)
  if self.filterItem == nil then
    self.filterItem = UIDarkZoneFilterItem.New()
    self.filterItem:InitObj(self.ui.mObj_Filter, function()
      self.ui.mImg_Icon.sprite = ResSys:GetUIResAIconSprite("Darkzone" .. "/" .. "icon_Darkzone_Equip_" .. self.filterItem.curFilter.data .. ".png")
      self:ApplyFilter(self.curFilterIndex, self.filterItem.curFilter.data)
      self:Show()
      self:ShowFilter(false)
    end)
  end
  function self.refresh()
    self:ApplyFilter(self.curFilterIndex, self.filterItem.curFilter and self.filterItem.curFilter.data or nil)
    self:Show()
  end
  MessageSys:AddListener(CS.GF2.Message.DarkMsg.DarkItemMoved, self.refresh)
  self.sortItem:ResetItemListSort()
  self:ApplyFilter(0)
  self:ShowBagBrief(false)
  self:ShowRepoBrief(false)
  self:ShowFilter(false)
end
function UIDarkZoneSubMaintenancePanel:OnClickFilterBtn()
  setactive(self.ui.mTrans_Filter, not self.filterOn)
end
function UIDarkZoneSubMaintenancePanel:ShowFilter(isOn)
  self.filterOn = isOn
  setactive(self.ui.mTrans_Filter, isOn)
end
function UIDarkZoneSubMaintenancePanel:ApplyFilter(index, pos)
  self:ShowRepoBrief(false)
  self:ShowBagBrief(false)
  for i = 0, #self.leftTabList - 1 do
    self.leftTabList[i + 1]:SetSelected(i == index)
  end
  self.bagItemList = {}
  self.repoItemList = {}
  if index ~= 1 then
    local bagList = DarkZoneNetRepoCmdData:GetBagList(index, self.sortType, self.isAscend)
    for i = 0, bagList.Count - 1 do
      table.insert(self.bagItemList, bagList[i])
    end
    local repoList = DarkZoneNetRepoCmdData:GetRepoList(index, self.sortType, self.isAscend)
    for i = 0, repoList.Count - 1 do
      table.insert(self.repoItemList, repoList[i])
    end
  else
    if pos == nil then
      pos = -1
    end
    local bagList = DarkZoneNetRepoCmdData:GetBagEquips(self.sortType, self.isAscend, pos)
    for i = 0, bagList.Count - 1 do
      table.insert(self.bagItemList, bagList[i])
    end
    local repoList = DarkZoneNetRepoCmdData:GetRepoEquips(self.sortType, self.isAscend, pos)
    for i = 0, repoList.Count - 1 do
      table.insert(self.repoItemList, repoList[i])
    end
  end
  setactive(self.ui.mTrans_FilterBtn, index == 1)
  self.curFilterIndex = index
end
function UIDarkZoneSubMaintenancePanel:Show(scrollToTop)
  if scrollToTop then
    self.ui.mVirtualList_Bag.verticalNormalizedPosition = 1
    self.ui.mVirtualList_Repo.verticalNormalizedPosition = 1
  end
  if self.ui.mFadeController_Bag.gameObject.activeInHierarchy == true then
    self.ui.mFadeController_Bag:InitVirtual()
  end
  if self.ui.mFadeController_Repo.gameObject.activeInHierarchy == true then
    self.ui.mFadeController_Repo:InitVirtual()
  end
  self.lastBagCount = DarkZoneNetRepoCmdData:GetBagItemCount(self.curFilterIndex)
  self.lastRepoCount = DarkZoneNetRepoCmdData:GetRepoItemCount(self.curFilterIndex)
  self.ui.mVirtualList_Bag.numItems = #self.bagItemList
  self.ui.mVirtualList_Repo.numItems = #self.repoItemList
  self.ui.mVirtualList_Bag:Refresh()
  self.ui.mVirtualList_Repo:Refresh()
  self.ui.mText_Bag.text = TableData.GetHintById(903130) .. "【" .. DarkZoneNetRepoCmdData:GetBagItemCount(self.curFilterIndex) .. "/" .. DarkZoneNetRepoCmdData:GetBagValidCount(self.curFilterIndex) .. "】"
  self.ui.mText_Repo.text = TableData.GetHintById(903131) .. "【" .. DarkZoneNetRepoCmdData:GetRepoItemCount(self.curFilterIndex) .. "/" .. DarkZoneNetRepoCmdData:GetRepoValidCount(self.curFilterIndex) .. "】"
end
function UIDarkZoneSubMaintenancePanel:SortItemList(sortType, isAscend)
  self.sortType = sortType
  self.isAscend = isAscend
end
function UIDarkZoneSubMaintenancePanel.OnScreenClick()
  self.isAscend = not self.isAscend
  self:UpdateSortList(self.curSort)
end
function UIDarkZoneSubMaintenancePanel:BagItemProvider()
  local renderDataItem = CS.RenderDataItem()
  local itemView = UIDarkZoneRepoItem.New()
  itemView:InitCtrl(nil, function(data)
    if self.selectedBagItem ~= nil and self.selectedBagItem.item ~= nil then
      self.selectedBagItem.item:EnableSel(false)
    end
    if itemView.item ~= nil then
      self.selectedBagItem = itemView
      self.ui.mTrans_Package:SetSiblingIndex(2)
      itemView.item:EnableSel(true)
      self:OnClickBagItem(data)
    elseif itemView.emptyItem ~= nil then
      self:ShowBagBrief(false)
    end
  end)
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneSubMaintenancePanel:ShowRepoBrief(show)
  setactive(self.ui.mTrans_RepoDetail, show)
  if not show then
    ComPropsDetailsHelper:Close()
  end
  if not show and self.selectedRepoItem then
    if self.selectedRepoItem.item ~= nil then
      self.selectedRepoItem.item:EnableSel(false)
    end
    self.selectedRepoItem = nil
  end
end
function UIDarkZoneSubMaintenancePanel:ShowBagBrief(show)
  setactive(self.ui.mTrans_BagDetail, show)
  if not show then
    ComPropsDetailsHelper:Close()
  end
  if not show and self.selectedBagItem then
    if self.selectedBagItem.item ~= nil then
      self.selectedBagItem.item:EnableSel(false)
    end
    self.selectedBagItem = nil
  end
end
function UIDarkZoneSubMaintenancePanel:OnClickBagItem(data)
  self:ShowRepoBrief(false)
  self:ShowBagBrief(true)
  if data.IsEquip then
    self:ResetBriefBottomFunc(self.ui.mTrans_BagDetail, UIDarkZoneBriefItem.ShowType.RepoEquip, data)
  elseif data.IsItem then
    self:ResetBriefBottomFunc(self.ui.mTrans_BagDetail, UIDarkZoneBriefItem.ShowType.RepoItem, data)
  end
end
function UIDarkZoneSubMaintenancePanel:RepoItemProvider()
  local renderDataItem = CS.RenderDataItem()
  local itemView = UIDarkZoneRepoItem.New()
  itemView:InitCtrl(nil, function(data)
    if self.selectedRepoItem ~= nil and self.selectedRepoItem.item ~= nil then
      self.selectedRepoItem.item:EnableSel(false)
    end
    if itemView.item ~= nil then
      self.ui.mTrans_Repository:SetSiblingIndex(2)
      self.selectedRepoItem = itemView
      itemView.item:EnableSel(true)
      self:OnClickRepoItem(data)
    elseif itemView.emptyItem ~= nil then
      self:ShowRepoBrief(false)
    end
  end)
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneSubMaintenancePanel:OnClickRepoItem(data)
  self:ShowBagBrief(false)
  self:ShowRepoBrief(true)
  if data.IsEquip then
    self:ResetBriefBottomFunc(self.ui.mTrans_RepoDetail, UIDarkZoneBriefItem.ShowType.RepoEquip, data)
  elseif data.IsItem then
    self:ResetBriefBottomFunc(self.ui.mTrans_RepoDetail, UIDarkZoneBriefItem.ShowType.RepoItem, data)
  end
end
function UIDarkZoneSubMaintenancePanel:BagItemRenderer(index, renderDataItem)
  local itemData = self.bagItemList[index + 1]
  local item = renderDataItem.data
  item:SetData(itemData)
end
function UIDarkZoneSubMaintenancePanel:RepoItemRenderer(index, renderDataItem)
  local itemData = self.repoItemList[index + 1]
  local item = renderDataItem.data
  item:SetData(itemData)
end
function UIDarkZoneSubMaintenancePanel:Close()
  self.mView = nil
  MessageSys:RemoveListener(CS.GF2.Message.DarkMsg.DarkItemMoved, self.refresh)
  self.refresh = nil
  for _, v in pairs(self.leftTabList) do
    gfdestroy(v:GetRoot())
  end
  self.leftTabList = nil
end
function UIDarkZoneSubMaintenancePanel:Release()
  self.ui = nil
  self.sortItem:Release()
  self.sortItem = nil
  self.filterItem:Release()
  self.filterItem = nil
end
function UIDarkZoneSubMaintenancePanel:ResetBriefBottomFunc(parent, type, data)
  local ShowItemDetail = function()
    UITipsPanel.Open(data.ItemData, 0, true)
  end
  ComPropsDetailsHelper:InitDarkItemData(parent.transform, type, data, ShowItemDetail)
  ComPropsDetailsHelper:OnClickExistBtn(function()
    if data.IsItem and data.ItemCount > 1 then
      UIManager.OpenUIByParam(UIDef.UIDarkZoneRepositoryExistDialog, {data, false})
    else
      DarkZoneNetRepoCmdData:StorageMove(false, data, function()
        ComPropsDetailsHelper:Close()
      end)
    end
  end)
  ComPropsDetailsHelper:OnClickEquipedBtn(function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneEquip(data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903104))
      ComPropsDetailsHelper:Close()
    end)
  end)
  ComPropsDetailsHelper:OnClickTakeBtn(function()
    if data.IsItem and data.ItemCount > 1 then
      UIManager.OpenUIByParam(UIDef.UIDarkZoneRepositoryExistDialog, {data, true})
    else
      DarkZoneNetRepoCmdData:StorageMove(true, data, function()
        ComPropsDetailsHelper:Close()
      end)
    end
  end)
  ComPropsDetailsHelper:OnClickUninstallBtn(function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneTake(data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903106))
      ComPropsDetailsHelper:Close()
    end)
  end)
  ComPropsDetailsHelper:OnClickReplaceBtn(function()
    DarkZoneNetRepoCmdData:SendCS_DarkZoneEquip(data, function()
      CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(903105))
      ComPropsDetailsHelper:Close()
    end)
  end)
end
