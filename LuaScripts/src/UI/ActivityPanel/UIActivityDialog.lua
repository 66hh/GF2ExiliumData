require("UI.UIBasePanel")
require("UI.ActivityPanel.UIActivityLeftTabItem")
require("UI.ActivityPanel.Item.SignIn.UIActivitySignInItem")
require("UI.ActivityPanel.Item.AmoWish.UIActivityAmoWishItem")
require("UI.ActivityPanel.Item.SevenQuest.UIActivitySevenQuestItem")
require("UI.ActivityPanel.Item.Guiding.UIActivityGuidingItem")
require("UI.ActivityPanel.UIActivityDefine")
UIActivityDialog = class("UIActivityDialog", UIBasePanel)
UIActivityDialog.__index = UIActivityDialog
function UIActivityDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
  csPanel.Is3DPanel = true
end
function UIActivityDialog:OnInit(root)
  self.super.SetRoot(UIActivityDialog, root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mSelectIndex = 1
  function self.OnActivityRedPointChange()
    if not self.mUITabItems then
      return
    end
    for i = 1, #self.mUITabItems do
      local item = self.mUITabItems[i]
      if item then
        item:UpdateRedPoint()
      end
    end
  end
  function self.OnResetOperationActivity()
    self.CloseSelf()
    UIUtils.PopupErrorWithHint(260010)
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnActivityRedPointChange, self.OnActivityRedPointChange)
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnResetOperationActivity, self.OnResetOperationActivity)
  self:RegisterEvent()
  self:UpdateAll()
end
function UIActivityDialog.CloseSelf()
  UIManager.CloseUI(UIDef.UIActivityDialog)
end
function UIActivityDialog:OnEscClick()
  UIActivityDialog.CloseSelf()
end
function UIActivityDialog:OnCameraStart()
  return 0.01
end
function UIActivityDialog:OnCameraBack()
  return 0.01
end
function UIActivityDialog:RegisterEvent()
  UIUtils.GetButtonListener(self.ui.mBtn_BGClose.gameObject).onClick = function()
    self.CloseSelf()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self.CloseSelf()
  end
  function self.ui.mVirtualList_TabList.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualList_TabList.itemRenderer(index, renderData)
    self:ItemRenderer(index, renderData)
  end
end
function UIActivityDialog:UpdateAll()
  self:InitData()
  self:UpdateTabs()
end
function UIActivityDialog:InitData()
  self.mActivityList = {}
  local serverActivityList = NetCmdOperationActivityData:GetShowActivityList()
  local serverCount = serverActivityList and serverActivityList.Count or 0
  for i = 0, serverCount - 1 do
    local activityPlanData = serverActivityList[i]
    local activityID = activityPlanData.Id
    local tableData = TableDataBase.listActivityListDatas:GetDataById(activityID)
    local activityData = {
      activityID = activityID,
      closeTime = activityPlanData.CloseTime,
      openTime = activityPlanData.OpenTime,
      tableData = tableData
    }
    table.insert(self.mActivityList, activityData)
  end
end
function UIActivityDialog:UpdateTabs()
  self.ui.mVirtualList_TabList.numItems = #self.mActivityList
  self.ui.mVirtualList_TabList:Refresh()
  self:SetSelect(self.mSelectIndex, true)
end
function UIActivityDialog:ItemProvider()
  local itemView = UIActivityLeftTabItem.New()
  itemView:InitCtrl(self.ui.mScrollChild_Content.childItem, self.ui.mScrollChild_Content.transform, function(index)
    self:SetSelect(self.mSelectIndex, false)
    self.mSelectIndex = index
    self:SetSelect(self.mSelectIndex, true)
  end)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UIActivityDialog:ItemRenderer(index, renderData)
  local luaIndex = index + 1
  local activityData = self.mActivityList[luaIndex]
  local item = renderData.data
  if self.mUITabItems == nil then
    self.mUITabItems = {}
  end
  self.mUITabItems[luaIndex] = item
  item:SetData(activityData, luaIndex, luaIndex == self.mSelectIndex)
end
function UIActivityDialog:SetSelect(index, isSelect)
  local activityData = self.mActivityList[index]
  local tabItem
  if self.mUITabItems and self.mUITabItems[index] then
    tabItem = self.mUITabItems[index]
  end
  if tabItem then
    tabItem:SetSelect(isSelect)
  end
  local uiItem = self:GetUIDesc(activityData)
  if not uiItem then
    return
  end
  setactive(uiItem.mUIRoot, isSelect)
  if isSelect then
    if not NetCmdOperationActivityData:IsActivityOpen(activityData.activityID) then
      self.CloseSelf()
      UIUtils.PopupErrorWithHint(260007)
      return
    end
    if not NetCmdOperationActivityData:IsActivityWatch(activityData.activityID) then
      NetCmdOperationActivityData:WatchActivity(activityData.activityID)
      if tabItem then
        tabItem:UpdateRedPoint()
      end
    end
    uiItem:SetData(activityData)
  else
    uiItem:OnHide()
    uiItem:ReleaseTimers()
  end
end
function UIActivityDialog:GetCurrentUIDesc()
  local activityData = self.mActivityList[self.mSelectIndex]
  if not activityData then
    return nil
  end
  return self:GetUIDesc(activityData)
end
function UIActivityDialog:GetUIDesc(activityData)
  if not self.mUITabInfoItem then
    self.mUITabInfoItem = {}
  end
  local activityType = activityData.tableData.type
  local activityItem = self.mUITabInfoItem[activityType]
  if not activityItem then
    activityItem = self:CreateNewActivity(activityType)
    self.mUITabInfoItem[activityType] = activityItem
  end
  return activityItem
end
function UIActivityDialog:CreateNewActivity(activityType)
  local uiConfig = UIActivityItemConfig[activityType]
  if not uiConfig then
    gferror("没有在UIActivityItemConfig中找到活动：" .. tostring(activityType) .. "的配置")
    return nil
  end
  local item = uiConfig.itemClass.New()
  item:InitCtrl(self.ui.mTrans_InfoRoot, uiConfig)
  return item
end
function UIActivityDialog:OnRecover()
  self:UpdateAll()
end
function UIActivityDialog:OnTop()
  local item = self:GetCurrentUIDesc()
  if item then
    item:OnTop()
  end
end
function UIActivityDialog:OnBackFrom()
  local item = self:GetCurrentUIDesc()
  if item then
    item:OnTop()
  end
end
function UIActivityDialog:OnRelease()
end
function UIActivityDialog:OnClose()
  self.mUITabItems = nil
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnActivityRedPointChange, self.OnActivityRedPointChange)
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.OnResetOperationActivity, self.OnResetOperationActivity)
  for i, baseCtrl in pairs(self.mUITabInfoItem) do
    if baseCtrl then
      setactive(baseCtrl.mUIRoot, false)
      baseCtrl:OnHide()
      baseCtrl:OnClose()
    end
  end
  self.mActivityList = nil
  if self.mUITabInfoItem then
    for _, item in pairs(self.mUITabInfoItem) do
      item:ReleaseTimers()
      item:OnRelease(true)
    end
  end
  self.mUITabInfoItem = nil
end
