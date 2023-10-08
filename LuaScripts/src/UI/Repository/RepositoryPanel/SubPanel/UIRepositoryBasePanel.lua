require("UI.Common.UICommonItemL")
UIRepositoryBasePanel = class("UIRepositoryBasePanel")
function UIRepositoryBasePanel:ctor(parent, panelId, transRoot)
  self.parent = parent
  self.transRoot = transRoot
  self.panelId = panelId
  self.itemList = {}
  self.isSub = false
  self.sortFunc = nil
  self.param = nil
  self.selectItemList = {}
  self.virtualList = parent.ui.mVirtualListEx_List
  function self.virtualList.itemCreated(renderData)
    local item = self:ItemProvider(renderData)
    return item
  end
  self.repositoryTagData = TableData.listRepositoryTagDatas:GetDataById(self.panelId)
end
function UIRepositoryBasePanel:Show()
  if self.transRoot then
    self.transRoot.alpha = 1
    self.transRoot.blocksRaycasts = true
  end
  if self.repositoryTagData then
    local canSold = false
    if self.repositoryTagData.can_sold.Count > 0 then
      for i = 0, self.repositoryTagData.can_sold.Count - 1 do
        if self.repositoryTagData.can_sold[i] == 1 then
          canSold = true
          break
        end
      end
    end
    self.parent:SetDecomposeVisible(canSold)
  end
end
function UIRepositoryBasePanel:OnShowStart()
end
function UIRepositoryBasePanel:OnPanelBack()
end
function UIRepositoryBasePanel:Close()
  if self.transRoot then
    self.transRoot.alpha = 0
    self.transRoot.blocksRaycasts = false
  end
end
function UIRepositoryBasePanel:UpdatePanelByType(type, param)
  if self.parent then
    self.parent:UpdatePanelByType(type, param)
  end
end
function UIRepositoryBasePanel:UpdateItemList()
  self.virtualList.numItems = #self.itemList
end
function UIRepositoryBasePanel:RefreshItemList(child)
  local itemIdList = LuaUtils.ConvertToItemIdList(self.itemList)
  self.virtualList:SetItemIdList(itemIdList)
  self.virtualList.numItems = #self.itemList
  self.virtualList:Refresh()
  if self.parent.ui.mFade_Content then
    self.parent.ui.mFade_Content.enabled = false
    self.parent.ui.mFade_Content.enabled = true
  end
  self.parent:RefreshRedPoint()
end
function UIRepositoryBasePanel:ItemProvider(renderData)
  local itemView = UICommonItem.New()
  itemView:InitCtrlWithNoInstantiate(renderData.gameObject, false)
  renderData.data = itemView
end
function UIRepositoryBasePanel:ItemRenderer(index, renderData)
  local data = self.itemList[index + 1]
  local item = renderData.data
  item:SetWeaponData(data, function()
    self:OnClickWeaponItem()
  end, false, false)
end
function UIRepositoryBasePanel:SortItemList(sortFunc)
end
function UIRepositoryBasePanel:UpdateVirtualList()
  if self.virtualList then
    self.virtualList:Refresh()
  end
end
function UIRepositoryBasePanel:FiltrateItemList(filtrateType, isFiltrate)
  for _, item in ipairs(self.itemList) do
    if self:IsFiltrateItem(filtrateType, item) and item.isChoose ~= isFiltrate then
      item.isChoose = isFiltrate
      if isFiltrate then
        self.parent:AddSoldItem(item.soldItem)
        table.insert(self.selectItemList, item)
      else
        self.parent:RemoveSoldItem(item.soldItem)
        self:RemoveSelectItemById(item.id)
      end
    end
  end
  self.virtualList:Refresh()
end
function UIRepositoryBasePanel:IsFiltrateItem(filtrateType, item)
  return item.rank == filtrateType
end
function UIRepositoryBasePanel:GetSelectItemList()
  return self.selectItemList
end
function UIRepositoryBasePanel:GetItemList()
  return self.itemList
end
function UIRepositoryBasePanel:UpdateConfirmBtn()
  if self.parent then
    self.parent:UpdateConfirmBtn()
  end
end
function UIRepositoryBasePanel:ResetSelectItemList()
  self.selectItemList = {}
end
function UIRepositoryBasePanel:RemoveSelectItemById(id)
  local index = 0
  for i, item in ipairs(self.selectItemList) do
    if item.id == id then
      index = i
      break
    end
  end
  if 0 < index then
    table.remove(self.selectItemList, index)
  end
end
function UIRepositoryBasePanel:Refresh()
end
function UIRepositoryBasePanel:OnRelease()
  self.parent = nil
  self.transRoot = nil
  self.panelId = nil
  self.virtualList = nil
  self.itemList = nil
  self.isSub = nil
  self.sortFunc = nil
  self.selectItemList = nil
end
