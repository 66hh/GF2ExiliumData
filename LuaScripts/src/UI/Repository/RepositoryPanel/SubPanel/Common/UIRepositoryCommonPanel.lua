require("UI.Repository.Item.UIRepositoryPublicTabItem")
UIRepositoryCommonPanel = class("UIRepositoryCommonPanel", UIRepositoryBasePanel)
function UIRepositoryCommonPanel:ctor(parent, panelId, subPanelRoot)
  self.parent = parent
  self.panelId = panelId
  self.itemDataList = nil
  self.itemViewTable = {}
  self.TopTabTable = {}
  self.ui = UIUtils.GetUIBindTable(subPanelRoot)
  self.super.ctor(self, parent, panelId, subPanelRoot)
end
function UIRepositoryCommonPanel:Show()
  self.super.Show(self)
  self.currentIndex = 0
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  self.parent.ui.mTrans_Other.localPosition = vectorzero
  self:InitTypeDropItem()
  self:OnClickTypeDropdownItem(1)
  setactive(self.parent.ui.mTrans_ChrTalentList, 1 < #self.allDataTable)
  setactive(self.parent.ui.mTrans_TalentImgLine, 1 < #self.allDataTable)
end
function UIRepositoryCommonPanel:Refresh()
  self:RefreshItemList()
end
function UIRepositoryCommonPanel:UpdateItemList()
  self:RefreshItemList()
end
function UIRepositoryCommonPanel:UpdatePanelByType()
end
function UIRepositoryCommonPanel:InitTypeDropItem()
  local tableData = TableData.listRepositoryTagDatas:GetDataById(self.panelId)
  local allDataList = tableData.toptag
  self.allDataTable = CSList2LuaTable(allDataList)
  for i = 1, #self.allDataTable do
    local itemData = TableData.listRepositoryToptagDatas:GetDataById(self.allDataTable[i])
    if itemData then
      self:RegTypeDropdownItem(itemData.title.str, itemData.icon, itemData.item_type, i)
    end
  end
end
function UIRepositoryCommonPanel:RefreshItemList()
  self.itemDataList = nil
  self.itemList = {}
  local topTagData = TableData.listRepositoryToptagDatas:GetDataById(self.allDataTable[self.currentIndex])
  if topTagData then
    self:RegTypeDropdownItem(topTagData.title.str, topTagData.icon, topTagData.item_type, self.currentIndex)
    local itemDataList = NetCmdItemData:GetRepositoryItemListByTypes(topTagData.item_type)
    for i = 0, itemDataList.Count - 1 do
      local itemData = itemDataList[i]
      local itemTabData = TableData.GetItemData(itemData.item_id)
      table.insert(self.itemList, itemTabData)
    end
  end
  self.parent.ui.mTrans_Empty.text = "暂无" .. topTagData.title.str
  setactive(self.parent.ui.mTrans_Empty, #self.itemList == 0)
  self.super.RefreshItemList(self)
  self.parent:RefreshRedPoint()
end
function UIRepositoryCommonPanel:RegTypeDropdownItem(suitName, spriteName, typeId, index)
  if self.TopTabTable[index] == nil then
    local item1 = UIRepositoryPublicTabItem.New()
    item1:InitCtrl(self.parent.ui.mTrans_ChrTalentList.transform)
    self.TopTabTable[index] = item1
    item1:SetRedPoint(index == 2 and NetCmdItemData:UpdateWeaponPieceRedPoint() > 0)
  end
  local item = self.TopTabTable[index]
  item.itemIndex = index
  item.typeId = typeId
  item:SetData(suitName)
  item:SetClickFunction(function()
    self:OnClickTypeDropdownItem(item.itemIndex)
  end)
end
function UIRepositoryCommonPanel:OnClickTypeDropdownItem(itemIndex)
  self.parent.ui.mBtn_Compose.interactable = false
  if self.currentIndex > 0 then
    self.TopTabTable[self.currentIndex]:SetSelectState(false)
  end
  self.currentIndex = itemIndex
  self.TopTabTable[self.currentIndex]:SetSelectState(true)
  self.currentTypeID = self.TopTabTable[itemIndex].typeId
  self:RefreshItemList()
end
function UIRepositoryCommonPanel:OnPanelBack()
  self:OnClickTypeDropdownItem(self.currentIndex)
  self.super.OnPanelBack(self)
end
function UIRepositoryCommonPanel:Close()
  self.super.Close(self)
  if self.currentIndex > 0 then
    self.TopTabTable[self.currentIndex]:SetSelectState(false)
  end
  self.currentIndex = 0
  self.currentTypeID = 0
  for i, v in ipairs(self.TopTabTable) do
    v:OnRelease()
  end
  self.TopTabTable = {}
end
function UIRepositoryCommonPanel:OnRelease()
  self.parent = nil
  self.panelId = 0
  if self.itemViewTable then
    for i = #self.itemViewTable, 1, -1 do
      self.itemViewTable[i]:OnRelease()
    end
  end
  self.itemDataList = nil
  self.itemViewTable = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIRepositoryCommonPanel:ItemRenderer(index, renderDataItem)
  local item = renderDataItem.data
  local data = self.itemList[index + 1]
  local count = NetCmdItemData:GetItemCountById(data.id)
  local itemTableData = TableData.listItemDatas:GetDataById(data.id)
  if itemTableData.type == GlobalConfig.ItemType.GiftPick then
    local custOnclick = function()
      UIManager.OpenUIByParam(UIDef.UIRepositoryBoxDialog, itemTableData)
    end
    local t = TableData.GlobalSystemData.BackpackJumpSwitch == 1
    item:SetItemData(data.id, count, false, t, count, nil, nil, custOnclick, nil, true)
  elseif itemTableData.type == GlobalConfig.ItemType.Random then
    local custOnclick = function()
      UIManager.OpenUIByParam(UIDef.UIRepositoryUnSelectItemBoxDialog, itemTableData)
    end
    local t = TableData.GlobalSystemData.BackpackJumpSwitch == 1
    item:SetItemData(data.id, count, false, t, count, nil, nil, custOnclick, nil, true)
  elseif GlobalConfig.CanUseItemType[itemTableData.type] ~= nil then
    item:SetItemData(data.id, count, false, nil, count, nil, nil, nil, nil, true, nil, nil, nil, true)
  else
    item:SetItemData(data.id, count)
  end
  item:SetRedPoint(true)
  item:LimitNumTop(count)
end
