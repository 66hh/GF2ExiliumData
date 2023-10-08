require("UI.Common.UICommonItemL")
UIDarkZoneRepositoryBasePanel = class("UIDarkZoneRepositoryBasePanel")
function UIDarkZoneRepositoryBasePanel:ctor(parent, panelId, transRoot)
  self.parent = parent
  self.transRoot = transRoot
  self.panelId = panelId
  self.itemList = {}
  self.isSub = false
  self.sortFunc = nil
  self.param = nil
  self.selectItemList = {}
  self.virtualList = parent.ui.mVirtualListEx_List
  function self.virtualList.itemProvider()
    local item = self:ItemProvider()
    return item
  end
  self.repositoryTagData = TableData.listDarkzoneRepositoryTagDatas:GetDataById(self.panelId)
end
function UIDarkZoneRepositoryBasePanel:Show()
  if self.transRoot then
    self.transRoot.alpha = 1
    self.transRoot.blocksRaycasts = true
  end
  if self.repositoryTagData then
    local canSold = false
  end
end
function UIDarkZoneRepositoryBasePanel:OnShowStart()
end
function UIDarkZoneRepositoryBasePanel:OnPanelBack()
end
function UIDarkZoneRepositoryBasePanel:Close()
  if self.transRoot then
    self.transRoot.alpha = 0
    self.transRoot.blocksRaycasts = false
  end
end
function UIDarkZoneRepositoryBasePanel:UpdatePanelByType(type, param)
  if self.parent then
    self.parent:UpdatePanelByType(type, param)
  end
end
function UIDarkZoneRepositoryBasePanel:UpdateItemList()
  self.virtualList.numItems = #self.itemList
end
function UIDarkZoneRepositoryBasePanel:RefreshItemList(child)
  if self.itemList == nil then
    gfwarning("self.itemList == nil")
  end
  local itemIdList = self.itemList
  self.virtualList.numItems = self.itemList.Count
  self.virtualList:Refresh()
  if self.parent.ui.mFade_Content then
    setactive(self.parent.ui.mFade_Content, false)
    setactive(self.parent.ui.mFade_Content, true)
  end
  self.parent:RefreshRedPoint()
end
function UIDarkZoneRepositoryBasePanel:ItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.parent.ui.mTrans_Content, false)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneRepositoryBasePanel:ItemRenderer(index, renderData)
  local data = self.itemList[index + 1]
  local item = renderData.data
  item:SetWeaponData(data, function()
    self:OnClickWeaponItem()
  end, false, false)
end
function UIDarkZoneRepositoryBasePanel:SortItemList(sortFunc)
end
function UIDarkZoneRepositoryBasePanel:UpdateVirtualList()
  if self.virtualList then
    self.virtualList:Refresh()
  end
end
function UIDarkZoneRepositoryBasePanel:FiltrateItemList(filtrateType, isFiltrate)
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
function UIDarkZoneRepositoryBasePanel:IsFiltrateItem(filtrateType, item)
  return item.rank == filtrateType
end
function UIDarkZoneRepositoryBasePanel:GetSelectItemList()
  return self.selectItemList
end
function UIDarkZoneRepositoryBasePanel:GetItemList()
  return self.itemList
end
function UIDarkZoneRepositoryBasePanel:UpdateConfirmBtn()
  if self.parent then
    self.parent:UpdateConfirmBtn()
  end
end
function UIDarkZoneRepositoryBasePanel:ResetSelectItemList()
  self.selectItemList = {}
end
function UIDarkZoneRepositoryBasePanel:RemoveSelectItemById(id)
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
function UIDarkZoneRepositoryBasePanel:Refresh()
end
function UIDarkZoneRepositoryBasePanel:OnRelease()
  self.parent = nil
  self.transRoot = nil
  self.panelId = nil
  self.virtualList = nil
  self.itemList = nil
  self.isSub = nil
  self.sortFunc = nil
  self.selectItemList = nil
end
