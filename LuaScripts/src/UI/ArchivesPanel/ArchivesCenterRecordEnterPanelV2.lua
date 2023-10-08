require("UI.UIBasePanel")
require("UI.ArchivesPanel.Item.ArchivesCenterStoryItemV2")
require("UI.ArchivesPanel.Item.ArchivesCenterHardItemV2")
ArchivesCenterRecordEnterPanelV2 = class("ArchivesCenterRecordEnterPanelV2", UIBasePanel)
ArchivesCenterRecordEnterPanelV2.__index = ArchivesCenterRecordEnterPanelV2
function ArchivesCenterRecordEnterPanelV2:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function ArchivesCenterRecordEnterPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.currSelectIndex = -1
  self.btnStateList = {}
  self.scrollIndex = 0
  self:InitTab()
  self:OnBtnClick()
end
function ArchivesCenterRecordEnterPanelV2:OnInit(root, data)
  self.storyDataList = NetCmdArchivesData:GetPlotListByType(1)
  self.hardDataList = NetCmdArchivesData:GetPlotListByType(2)
  self.currSelectIndex = -1
  self:OnClickTab(data)
end
function ArchivesCenterRecordEnterPanelV2:OnShowFinish()
  self:RefreshRedPoint()
end
function ArchivesCenterRecordEnterPanelV2:OnClickTab(index)
  local data = TableDataBase.listStoryRoomDatas:GetDataById(index)
  if data == nil then
    return
  end
  if not AccountNetCmdHandler:CheckSystemIsUnLock(data.unlock) then
    local unlockData = TableDataBase.listUnlockDatas:GetDataById(data.unlock)
    if unlockData then
      local str = UIUtils.CheckUnlockPopupStr(unlockData)
      PopupMessageManager.PopupString(str)
      return
    end
  end
  if self.currSelectIndex == index then
    return
  end
  self.currSelectIndex = index
  for k, v in ipairs(self.tabUIList) do
    v.mBtn_Item.interactable = k ~= self.currSelectIndex
  end
  setactive(self.ui.mVirtualListEx_Story.gameObject, self.currSelectIndex == 1)
  setactive(self.ui.mVirtualListEx_Hard.gameObject, self.currSelectIndex == 2)
  if self.currSelectIndex == 1 then
    if self.storyDataList.Count == 0 then
      return
    end
    if not self.btnStateList[self.currSelectIndex] then
      self.btnStateList[self.currSelectIndex] = true
      function self.ui.mVirtualListEx_Story.itemProvider()
        return self:ItemStoryProvider()
      end
      function self.ui.mVirtualListEx_Story.itemRenderer(...)
        self:ItemStoryRenderer(...)
      end
    end
    self.ui.mVirtualListEx_Story.numItems = self.storyDataList.Count
    self.ui.mVirtualListEx_Story:Refresh()
  elseif self.currSelectIndex == 2 then
    if self.hardDataList.Count == 0 then
      return
    end
    if not self.btnStateList[self.currSelectIndex] then
      self.btnStateList[self.currSelectIndex] = true
      function self.ui.mVirtualListEx_Hard.itemProvider()
        return self:ItemHardProvider()
      end
      function self.ui.mVirtualListEx_Hard.itemRenderer(...)
        self:ItemHardRenderer(...)
      end
    end
    self.ui.mVirtualListEx_Hard.numItems = self.hardDataList.Count
    self.ui.mVirtualListEx_Hard:Refresh()
  end
end
function ArchivesCenterRecordEnterPanelV2:ItemStoryProvider()
  local itemView = ArchivesCenterStoryItemV2.New()
  itemView:InitCtrl(self.ui.mTrans_StoryContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ArchivesCenterRecordEnterPanelV2:ItemStoryRenderer(index, renderData)
  local data = self.storyDataList[index]
  if data then
    local item = renderData.data
    item:SetData(data, index + 1, self)
  end
end
function ArchivesCenterRecordEnterPanelV2:ItemHardProvider()
  local itemView = ArchivesCenterHardItemV2.New()
  itemView:InitCtrl(self.ui.mTrans_HardContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ArchivesCenterRecordEnterPanelV2:ItemHardRenderer(index, renderData)
  local data = self.hardDataList[index]
  if data then
    local item = renderData.data
    item:SetData(data, index + 1)
  end
end
function ArchivesCenterRecordEnterPanelV2:InitTab()
  local tabPrefab = self.ui.mTrans_TabContent:GetComponent(typeof(CS.ScrollListChild))
  self.tabUIList = {}
  for i = 1, 2 do
    self.tabUIList[i] = {}
    local instObj = instantiate(tabPrefab.childItem)
    self:LuaUIBindTable(instObj, self.tabUIList[i])
    UIUtils.AddListItem(instObj.gameObject, self.ui.mTrans_TabContent.gameObject)
    local data = TableDataBase.listStoryRoomDatas:GetDataById(i)
    if data then
      self.tabUIList[i].mText_Text.text = data.name.str
    end
    UIUtils.GetButtonListener(self.tabUIList[i].mBtn_Item.gameObject).onClick = function()
      self:OnClickTab(i)
    end
  end
end
function ArchivesCenterRecordEnterPanelV2:OnBtnClick()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterRecordEnterPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
end
function ArchivesCenterRecordEnterPanelV2:RefreshRedPoint()
  setactive(self.tabUIList[1].mTrans_RedPoint, NetCmdArchivesData:PlotBranchIsHaveRed())
  setactive(self.tabUIList[2].mTrans_RedPoint, false)
end
function ArchivesCenterRecordEnterPanelV2:OnHide()
end
function ArchivesCenterRecordEnterPanelV2:OnBackFrom()
  local index = self.currSelectIndex
  self.currSelectIndex = -1
  self:OnClickTab(index)
  if index == 1 then
    if self.scrollIndex % 2 == 0 then
      self.ui.mVirtualListEx_Story:DelayScrollToPosByIndex(self.scrollIndex - 2, false)
    else
      self.ui.mVirtualListEx_Story:DelayScrollToPosByIndex(self.scrollIndex, false)
    end
  end
end
function ArchivesCenterRecordEnterPanelV2:OnClose()
end
function ArchivesCenterRecordEnterPanelV2:OnRelease()
  self.btnStateList = {}
end
