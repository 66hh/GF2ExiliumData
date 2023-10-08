require("UI.UIBasePanel")
require("UI.Common.UIComTabBtn1ItemV2")
require("UI.MonopolyActivity.ActivityTourGlobal")
require("UI.ActivityTour.ActivityTourMissionItem")
ActivityTourMissionDialog = class("ActivityTourMissionDialog", UIBasePanel)
ActivityTourMissionDialog.__index = ActivityTourMissionDialog
function ActivityTourMissionDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function ActivityTourMissionDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:ManualUI()
end
function ActivityTourMissionDialog:ManualUI()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourMissionDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityTourMissionDialog)
  end
  self.ThemeWarmUp = NetCmdThemeData:GetThemeRewardType()
  self.tabUIList = {}
  local hintNameList = {270198, 270199}
  for i = 1, 2 do
    do
      local tabItem = UIComTabBtn1ItemV2.New()
      table.insert(self.tabUIList, tabItem)
      local data = {
        index = i,
        name = TableData.GetHintById(hintNameList[i])
      }
      tabItem:InitCtrl(self.ui.mTrans_TopTab.gameObject, data)
      tabItem:AddClickListener(function()
        self:ChangeTab2Next(tabItem)
      end)
    end
  end
  function self.ui.mVirtualListExNew_MissionList.itemProvider()
    return self:ItemProvider()
  end
  function self.ui.mVirtualListExNew_MissionList.itemRenderer(...)
    self:ItemRenderer(...)
  end
end
function ActivityTourMissionDialog:ChangeTab2Next(tabItem)
  if tabItem == self.curTabItem then
    return
  end
  if self.curTabItem ~= nil then
    self.curTabItem:SetBtnInteractable(true)
  end
  self.curTabItem = tabItem
  tabItem:SetBtnInteractable(false)
  self:RefreshRewardContents(tabItem.index)
end
function ActivityTourMissionDialog:UpdateRedPoint()
  for i = 1, #self.tabUIList do
    setactive(self.tabUIList[i].ui.mTrans_RedPoint.gameObject, NetCmdThemeData:MissionRedByType(i))
  end
end
function ActivityTourMissionDialog:RefreshRewardContents(index)
  if index == 1 then
    self.dailyTaskList = NetCmdThemeData:GetTaskDataByIndex(1)
    self.ui.mVirtualListExNew_MissionList.numItems = self.dailyTaskList.Count
  else
    self.tourTaskList = NetCmdThemeData:GetTaskDataByIndex(2)
    self.ui.mVirtualListExNew_MissionList.numItems = self.tourTaskList.Count
  end
  self:UpdateRedPoint()
  self.ui.mVirtualListExNew_MissionList:Refresh()
  self.ui.mTrans_Content.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = false
  self.ui.mTrans_Content.transform:GetComponent(typeof(CS.MonoScrollerFadeManager)).enabled = true
end
function ActivityTourMissionDialog:ItemProvider()
  local itemView = ActivityTourMissionItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ActivityTourMissionDialog:ItemRenderer(index, renderData)
  if self.curTabItem == nil then
    return
  end
  local data
  if self.curTabItem.index == 1 then
    data = self.dailyTaskList[index]
  else
    data = self.tourTaskList[index]
  end
  local item = renderData.data
  item:SetData(data, self.curTabItem.index)
  local itemBtn = UIUtils.GetButtonListener(item.ui.mBtn_BtnReceive.gameObject)
  function itemBtn.onClick(gameObject)
    self:OnReceiveClick(gameObject)
  end
  itemBtn.param = data
end
function ActivityTourMissionDialog:OnReceiveClick(gameObject)
  self.themeId = NetCmdRecentActivityData:GetNowOpenThemeId(self.themeId)
  if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
    CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
    UIManager.CloseUI(UIDef.ActivityTourMissionDialog)
    return
  end
  local itemBtn = UIUtils.GetButtonListener(gameObject)
  NetCmdCommonQuestData:ReqGetQuestReward(16 + self.curTabItem.index, itemBtn.param.id, function(ret)
    if ret == ErrorCodeSuc then
      UIManager.OpenUI(UIDef.UICommonReceivePanel)
      if self.curTabItem.index == 1 then
        self.dailyTaskList = NetCmdThemeData:GetTaskDataByIndex(1)
      else
        self.tourTaskList = NetCmdThemeData:GetTaskDataByIndex(2)
      end
      self:RefreshRewardContents(self.curTabItem.index)
    end
  end)
end
function ActivityTourMissionDialog:OnInit(root, data)
  self.themeId = data.themeId or 99902
  self.dailyTaskList = NetCmdThemeData:GetTaskDataByIndex(1)
  self.tourTaskList = NetCmdThemeData:GetTaskDataByIndex(2)
  if self.curTabItem then
    self.curTabItem:SetBtnInteractable(true)
    self.curTabItem = nil
  end
  self:ChangeTab2Next(self.tabUIList[1])
  ActivityTourGlobal.ReplaceAllColor(self.mUIRoot)
  self.isRefresh = false
  function ActivityTourMissionDialog.RefreshQuestChange(type)
    if not self.isRefresh then
      self.isRefresh = true
      ActivityTourMissionDialog:OnQuestChange()
    end
  end
  MessageSys:AddListener(CS.GF2.Message.QuestEvent.OnQuestReset, ActivityTourMissionDialog.RefreshQuestChange)
end
function ActivityTourMissionDialog:CleanTime()
  if self.refreshTime then
    self.refreshTime:Stop()
    self.refreshTime = nil
  end
end
function ActivityTourMissionDialog:OnQuestChange()
  self:CleanTime()
  self.refreshTime = TimerSys:DelayCall(1, function()
    self:CleanTime()
    self:RefreshRewardContents(self.curTabItem.index)
  end)
end
function ActivityTourMissionDialog:OnShowStart()
end
function ActivityTourMissionDialog:OnShowFinish()
end
function ActivityTourMissionDialog:OnTop()
end
function ActivityTourMissionDialog:OnBackFrom()
end
function ActivityTourMissionDialog:OnClose()
  self.ui.mVirtualListExNew_MissionList.numItems = 0
  self:CleanTime()
  self.isRefresh = false
  MessageSys:RemoveListener(CS.GF2.Message.QuestEvent.OnQuestReset, ActivityTourMissionDialog.RefreshQuestChange)
end
function ActivityTourMissionDialog:OnHide()
end
function ActivityTourMissionDialog:OnHideFinish()
end
function ActivityTourMissionDialog:OnRelease()
end
