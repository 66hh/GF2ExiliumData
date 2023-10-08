require("UI.Repository.Item.UIRepositoryListItemV2")
require("UI.Repository.RepositoryPanel.SubPanel.UIRepositoryBasePanel")
UIRepositoryItemPanel = class("UIRepositoryItemPanel", UIRepositoryBasePanel)
UIRepositoryItemPanel.__index = UIRepositoryItemPanel
function UIRepositoryItemPanel:ctor(parent, panelId, transRoot)
  self.super.ctor(self, parent, panelId, transRoot)
  self.itemList = nil
end
function UIRepositoryItemPanel:InitItemTypeList()
  local parentRoot = self.parent.ui.mContent_Item.transform
  local typeList = TableData.listRepositoryCategoryDatas
  for i = 0, typeList.Count - 1 do
    local item = UIRepositoryListItemV2.New()
    item:InitCtrl(parentRoot)
    item:SetData(typeList[i])
    table.insert(self.itemList, item)
  end
end
function UIRepositoryItemPanel:OnShowStart()
  local timeLimitItem = {}
  for _, item in ipairs(self.itemList) do
    local itemDataList = NetCmdItemData:GetRepositoryItemListByTypes(item.mData.item_type)
    for i = 0, itemDataList.Count - 1 do
      local itemData = itemDataList[i]
      local itemTableData = TableData.listItemDatas:GetDataById(itemData.item_id)
      local timeLimit = itemTableData.time_limit
      if timeLimit ~= 0 and timeLimit < CGameTime:GetTimestamp() then
        table.insert(timeLimitItem, itemData)
      end
    end
  end
  if 0 < #timeLimitItem then
    UIManager.OpenUIByParam(UIDef.UIComExpirationPopDialog, timeLimitItem)
  end
end
function UIRepositoryItemPanel:Show()
  self.super.Show(self)
  self.parent.ui.mTrans_Item.localPosition = vectorzero
end
function UIRepositoryItemPanel:OnPanelBack()
  self:Refresh()
end
function UIRepositoryItemPanel:Refresh()
  self:UpdateItemList()
end
function UIRepositoryItemPanel:UpdateItemList()
  if self.itemList == nil then
    self.itemList = {}
    self:InitItemTypeList()
    TimerSys:DelayCall(0.3, function()
      self:UpdateItemListDetail()
    end)
  else
    self:UpdateItemListDetail()
  end
end
function UIRepositoryItemPanel:UpdateItemListDetail()
  for _, item in ipairs(self.itemList) do
    item:UpdateItemList()
  end
  if self.isFirstIn == true then
    self.parent.ui.mFade_ItemContent:InitFade()
    self.isFirstIn = false
  end
end
function UIRepositoryItemPanel:SortItemList()
end
function UIRepositoryItemPanel:Close()
  self.super.Close(self)
  self.isFirstIn = true
  self.parent.ui.mTrans_Item.localPosition = Vector3(0, 3000, 0)
end
function UIRepositoryItemPanel:OnRelease()
  if self.itemList ~= nil then
    for _, item in ipairs(self.itemList) do
      item:OnRelease()
    end
  end
  self.isFirstIn = nil
  self.super.OnRelease(self)
end
