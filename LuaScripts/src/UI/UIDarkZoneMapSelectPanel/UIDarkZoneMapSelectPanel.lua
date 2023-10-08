require("UI.UIDarkZoneMapSelectPanel.Item.DarkZoneMapSelectItem")
require("UI.UIDarkZoneMapSelectPanel.UIDarkZoneMapSelectPanelView")
require("UI.UIBasePanel")
UIDarkZoneMapSelectPanel = class("UIDarkZoneMapSelectPanel", UIBasePanel)
UIDarkZoneMapSelectPanel.__index = UIDarkZoneMapSelectPanel
function UIDarkZoneMapSelectPanel:ctor(csPanel)
  UIDarkZoneMapSelectPanel.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function UIDarkZoneMapSelectPanel:OnInit(root, data)
  UIDarkZoneMapSelectPanel.super.SetRoot(UIDarkZoneMapSelectPanel, root)
  self:InitBaseData()
  if data and type(data) == "userdata" then
    self.targetID = data[0]
  end
  self.mview:InitCtrl(root, self.ui)
  self:AddBtnListen()
  function self.itemFunction(Data, num, key)
    self.ui.mAnim_Root:ResetTrigger("Refresh")
    self.ui.mAnim_Root:SetTrigger("Refresh")
    self:UpdateInfo(Data, num, key)
  end
  function self.ui.mVirtualListEx.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListEx.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
end
function UIDarkZoneMapSelectPanel:OnShowFinish()
  if self.IsPanelOpen == false then
    self:UpdateItemList()
  end
  self.IsPanelOpen = true
end
function UIDarkZoneMapSelectPanel:OnHide()
  self.IsPanelOpen = false
end
function UIDarkZoneMapSelectPanel:OnUpdate(deltatime)
end
function UIDarkZoneMapSelectPanel:CloseFunction()
  UIManager.CloseUI(UIDef.UIDarkZoneMapSelectPanel)
end
function UIDarkZoneMapSelectPanel:OnClose()
  self.ui.mVirtualListEx.numItems = 0
  self.ui.mVirtualListEx.itemProvider = nil
  self.ui.mVirtualListEx.itemRenderer = nil
  self.ui = nil
  self.mview = nil
  self.ItemDataList = nil
  self.IsPanelOpen = nil
  self.objlist = nil
  self.ExcuteOnce = nil
  self.targetID = nil
  MapSelectUtils.LastBtn = nil
  MapSelectUtils.LastItemIndex = nil
end
function UIDarkZoneMapSelectPanel:InitBaseData()
  self.mview = UIDarkZoneMapSelectPanelView.New()
  self.ui = {}
  self.ItemDataList = {}
  self.IsPanelOpen = false
  self.ExcuteOnce = false
  self.objlist = {}
end
function UIDarkZoneMapSelectPanel:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:CloseFunction()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_StaminaNum.gameObject).onClick = function()
    local str = TableData.GetHintById(903250)
    local data = MapSelectUtils.CurMapData
  end
end
function UIDarkZoneMapSelectPanel:UpdateItemList()
  local list = {}
  TableData.listDarkzoneMapV2Datas:ForcePreLoadAll()
  for i = 0, TableData.listDarkzoneMapV2Datas.Count - 1 do
    table.insert(list, TableData.listDarkzoneMapV2Datas[i])
  end
  table.sort(list, function(a, b)
    return a.id < b.id
  end)
  for i = 1, #list do
    table.insert(self.ItemDataList, list[i])
  end
  self.ui.mVirtualListEx.numItems = #self.ItemDataList
  self.ui.mFade_Script:InitVirtual()
end
function UIDarkZoneMapSelectPanel:ItemProvider()
  local itemView = DarkZoneMapSelectItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIDarkZoneMapSelectPanel:ItemRenderer(index, renderData)
  local data = self.ItemDataList[index + 1]
  if data then
    local item = renderData.data
    item:SetData(data, index, self.itemFunction)
    if self.targetID == nil then
      if index == 0 and self.ExcuteOnce == false then
        self.ExcuteOnce = true
        item.ui.mBtn_Root.onClick:Invoke()
      end
    elseif self.targetID == data.id then
      self.ExcuteOnce = true
      item.ui.mBtn_Root.onClick:Invoke()
    end
  end
end
function UIDarkZoneMapSelectPanel:UpdateInfo(Data, type, key)
  setactive(self.ui.mTrans_Lock, false)
  setactive(self.ui.mBtn_Next, false)
  if type == 0 then
    setactive(self.ui.mBtn_Next, true)
    UIUtils.GetButtonListener(self.ui.mBtn_Next.gameObject).onClick = function()
      self:OpenTwiceTeamInfo()
    end
  elseif type == 1 then
    setactive(self.ui.mTrans_Lock, true)
  elseif type == 2 then
    setactive(self.ui.mTrans_Lock, true)
    self.ui.mText_LockLevel.text = string_format(TableData.GetHintById(903134), key)
  end
  for i = 0, self.ui.mTrans_Enemy.childCount - 1 do
    gfdestroy(self.ui.mTrans_Enemy:GetChild(i))
  end
end
function UIDarkZoneMapSelectPanel:OpenTwiceTeamInfo()
  local data = {}
  data.MapId = MapSelectUtils.CurMapData.id
  CS.DzMatchUtils.RequireDarkMatchDefault(MapSelectUtils.CurMapData.id)
end
