require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.SubPanel.UIDarkZoneRepositoryBasePanel")
UIDarkZoneRepositoryChipMaterialPanel = class("UIDarkZoneRepositoryChipMaterialPanel", UIDarkZoneRepositoryBasePanel)
function UIDarkZoneRepositoryChipMaterialPanel:ctor(parent, panelId, subPanelRoot)
  self.super.ctor(self, parent, panelId, subPanelRoot)
  self.parent = parent
  self.panelId = panelId
  self.itemList = {}
  self.param = nil
  self.transRoot = subPanelRoot
  self.comScreenItemV2 = nil
end
function UIDarkZoneRepositoryChipMaterialPanel:Show()
  self.super.Show(self)
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  local repoList = DarkZoneNetRepositoryData:GetRepositoryData(GlobalConfig.ItemType.WishMaterial)
  self.comScreenItemV2 = ComScreenItemHelper:InitDarkZoneRepoComScreenItemV2(self.parent.ui.mTrans_BtnScreen.gameObject, repoList, function()
    self:RefreshItemList()
  end, nil)
  self:RefreshItemList()
  setactive(self.parent.ui.mTrans_Bottom, true)
  setactive(self.parent.ui.mTrans_Other, true)
  setactive(self.parent.ui.mTrans_Empty, false)
end
function UIDarkZoneRepositoryChipMaterialPanel:OnPanelBack()
  self.comScreenItemV2:DoSort()
end
function UIDarkZoneRepositoryChipMaterialPanel:Close()
  self.super.Close(self)
  setactive(self.parent.ui.mTrans_Bottom, false)
  setactive(self.parent.ui.mTrans_Other, false)
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
  end
  self.comScreenItemV2 = nil
end
function UIDarkZoneRepositoryChipMaterialPanel:OnRelease()
  self.itemList = nil
  self.parent = nil
  self.panelId = 0
  self.param = nil
end
function UIDarkZoneRepositoryChipMaterialPanel:ItemRenderer(index, renderData)
  local data = self.itemList[index]
  local item = renderData.data
  item:SetItemData(data.ItemId, data.ItemCount, false, true)
  item:LimitNumTop(data.ItemCount)
end
function UIDarkZoneRepositoryChipMaterialPanel:Refresh()
  self:RefreshItemList()
end
function UIDarkZoneRepositoryChipMaterialPanel:RefreshItemList()
  self.itemList = self:GetSearchChipList()
  setactive(self.parent.ui.mTrans_Empty, self.itemList.Count == 0)
  self.parent.ui.mTrans_Empty.text = TableData.GetHintById(240117)
  self.super.RefreshItemList(self)
end
function UIDarkZoneRepositoryChipMaterialPanel:GetSearchChipList()
  local wishCreateList = self.comScreenItemV2:GetResultList()
  return wishCreateList
end
