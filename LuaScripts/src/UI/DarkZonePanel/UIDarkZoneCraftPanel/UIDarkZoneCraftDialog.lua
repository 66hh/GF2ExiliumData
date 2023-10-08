require("UI.DarkZonePanel.UIDarkZoneCraftPanel.UIDarkZoneCraftDialogView")
require("UI.UIBasePanel")
UIDarkZoneCraftDialog = class("UIDarkZoneCraftDialog", UIBasePanel)
UIDarkZoneCraftDialog.__index = UIDarkZoneCraftDialog
function UIDarkZoneCraftDialog:ctor(csPanel)
  UIDarkZoneCraftDialog.super.ctor(UIDarkZoneCraftDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneCraftDialog:OnInit(root)
  UIDarkZoneCraftDialog.super.SetRoot(UIDarkZoneCraftDialog, root)
  self.ui = {}
  self.mView = UIDarkZoneCraftDialogView.New()
  self.mView:InitCtrl(root, self.ui)
  self:AddBtnListener()
  self:InitBaseData()
  self:ShowLeftTab()
  function self.ui.mVirtualListEx_List.itemProvider()
    return self:RightItemProvider()
  end
  function self.ui.mVirtualListEx_List.itemRenderer(index, renderData)
    self:RightItemRenderer(index, renderData)
  end
end
function UIDarkZoneCraftDialog:Close()
  self.ui.mUIFadeOutHelper_Self:CloseUI(function()
    UIManager.CloseUI(UIDef.UIDarkZoneCraftDialog)
  end)
end
function UIDarkZoneCraftDialog:OnClose()
  self.ui.mVirtualListEx_List.itemProvider = nil
  self.ui.mVirtualListEx_List.itemRenderer = nil
  self.ui = nil
  self.mView = nil
  self.currentClickLeftTabItem = nil
  self.func = nil
  self.tabItemListData = nil
  self.AllTypeItemListData = nil
  self.ItemListData = nil
  self.tabItemShowRedDotList = nil
  for i = 1, #self.leftTabItemList do
    self.leftTabItemList[i]:OnClose()
  end
  self.leftTabItemList = nil
end
function UIDarkZoneCraftDialog:OnRelease()
  self.super.OnRelease(self)
  self.hasCache = false
end
function UIDarkZoneCraftDialog:ShowLeftTab()
  for i = 1, #self.tabItemListData do
    local data = self.tabItemListData[i]
    local item = DZCraftDialogLeftTabItem.New()
    item:InitCtrl(self.ui.mTrans_LeftContent)
    local needShowNew = self.tabItemShowRedDotList[data.id]
    item:SetData(data, self.func, needShowNew)
    if self.currentClickLeftTabItem == nil then
      item:ClickFunction()
    end
    self.leftTabItemList[i] = item
  end
end
function UIDarkZoneCraftDialog.LeftItemProvider()
  local itemView = DZCraftDialogLeftTabItem.New()
  itemView:InitCtrl(self.ui.mTrans_LeftContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneCraftDialog.LeftItemRenderer(index, renderData)
  local data = self.tabItemListData[index + 1]
  local item = renderData.data
  local needShowNew = self.tabItemShowRedDotList[data.id]
  item:SetData(data, self.func, needShowNew)
  if self.currentClickLeftTabItem == nil then
    item:ClickFunction()
  end
end
function UIDarkZoneCraftDialog:RightItemProvider()
  local itemView = UICommonItem.New()
  itemView:InitCtrl(self.ui.mTrans_RightContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneCraftDialog:RightItemRenderer(index, renderData)
  local stcData = self.ItemListData[index + 1]
  local id = stcData.id
  local item = renderData.data
  local data = UIWeaponGlobal:GetWeaponModSimpleData(CS.GunWeaponModData(id))
  local itemData = TableData.GetItemData(id)
  item:SetPartData(data, nil, stcData.isShowNew)
  TipsManager.Add(item.ui.mBtn_Select.gameObject, itemData, 1, false, nil, nil, nil, nil, false)
end
function UIDarkZoneCraftDialog:AddBtnListener()
  if self.hasCache ~= true then
    self.ui.mBtn_BGBack.onClick:AddListener(function()
      self:Close()
    end)
    self.ui.mBtn_Close.onClick:AddListener(function()
      self:Close()
    end)
    self.hasCache = true
  end
end
function UIDarkZoneCraftDialog:InitBaseData()
  self.tabItemListData = {}
  self.AllTypeItemListData = {}
  self.ItemListData = nil
  self.tabItemShowRedDotList = {}
  self.leftTabItemList = {}
  local list1 = TableData.listWeaponModTypeDatas:GetList()
  for i = 0, list1.Count - 1 do
    local d = list1[i]
    if d.type == 1 then
      table.insert(self.tabItemListData, d)
    end
  end
  local list2 = TableData.listItemByTypeDatas:GetDataById(GlobalConfig.ItemType.WeaponPart).Id
  for i = 0, list2.Count - 1 do
    local d = TableData.listWeaponModDatas:GetDataById(list2[i])
    if self.AllTypeItemListData[d.father_type] == nil then
      self.AllTypeItemListData[d.father_type] = {}
    end
    if not self.tabItemShowRedDotList then
      self.tabItemShowRedDotList[d.father_type] = false
    end
    if d.isShowNew == true then
      self.tabItemShowRedDotList[d.father_type] = true
    end
    table.insert(self.AllTypeItemListData[d.father_type], d)
  end
  for i = 1, #self.tabItemListData do
    local data = self.tabItemListData[i]
    local t = self.AllTypeItemListData[data.id]
    table.sort(t, function(a, b)
      return a.rank > b.rank
    end)
  end
  function self.func(partType)
    self:RefreshRightList(partType)
  end
end
function UIDarkZoneCraftDialog:RefreshRightList(item)
  if self.currentClickLeftTabItem then
    self.currentClickLeftTabItem.ui.mBtn_Self.interactable = true
  end
  self.currentClickLeftTabItem = item
  self.currentClickLeftTabItem.ui.mBtn_Self.interactable = false
  self.ItemListData = self.AllTypeItemListData[item.mData.id]
  self.ui.mVirtualListEx_List:Refresh()
  self.ui.mVirtualListEx_List.numItems = #self.ItemListData
end
