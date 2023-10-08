require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.SubPanel.UIDarkZoneRepositoryBasePanel")
UIDarkZoneRepositorySearchChipPanel = class("UIDarkZoneRepositorySearchChipPanel", UIDarkZoneRepositoryBasePanel)
function UIDarkZoneRepositorySearchChipPanel:ctor(parent, panelId, subPanelRoot)
  self.super.ctor(self, parent, panelId, subPanelRoot)
  self.parent = parent
  self.panelId = panelId
  self.itemList = {}
  self.param = nil
  self.transRoot = subPanelRoot
  self.comScreenItemV2 = nil
end
function UIDarkZoneRepositorySearchChipPanel:Show()
  self.super.Show(self)
  function self.virtualList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
  local repoList = DarkZoneNetRepositoryData:GetRepositoryData(GlobalConfig.ItemType.Wishcreate)
  self.comScreenItemV2 = ComScreenItemHelper:InitDarkZoneRepoComScreenItemV2(self.parent.ui.mTrans_BtnScreen.gameObject, repoList, function()
    self:RefreshItemList()
  end, nil)
  self:RefreshItemList()
  setactive(self.parent.ui.mTrans_Bottom, true)
  setactive(self.parent.ui.mTrans_Other, true)
  setactive(self.parent.ui.mTrans_Empty, false)
end
function UIDarkZoneRepositorySearchChipPanel:OnPanelBack()
  self.comScreenItemV2:DoSort()
end
function UIDarkZoneRepositorySearchChipPanel:Close()
  self.super.Close(self)
  setactive(self.parent.ui.mTrans_Bottom, false)
  setactive(self.parent.ui.mTrans_Other, false)
  if self.comScreenItemV2 then
    self.comScreenItemV2:OnRelease()
  end
  self.comScreenItemV2 = nil
end
function UIDarkZoneRepositorySearchChipPanel:OnRelease()
  self.itemList = nil
  self.parent = nil
  self.panelId = 0
  self.param = nil
end
function UIDarkZoneRepositorySearchChipPanel:ItemRenderer(index, renderData)
  local data = self.itemList[index]
  local item = renderData.data
  item:SetItemData(data.ItemId, data.ItemCount, false, true)
  item:LimitNumTop(data.ItemCount)
end
function UIDarkZoneRepositorySearchChipPanel:Refresh()
  self:RefreshItemList()
end
function UIDarkZoneRepositorySearchChipPanel:RefreshItemList()
  self.itemList = self:GetSearchChipList()
  setactive(self.parent.ui.mTrans_Empty, self.itemList.Count == 0)
  self.parent.ui.mTrans_Empty.text = TableData.GetHintById(240116)
  self.super.RefreshItemList(self)
end
function UIDarkZoneRepositorySearchChipPanel:GetSearchChipList()
  local wishCreateList = self.comScreenItemV2:GetResultList()
  return wishCreateList
end
