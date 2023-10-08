require("UI.UIBasePanel")
require("UI.ArchivesPanel.Item.ArchivesCenterAchievementLeftTabItemV2")
require("UI.ArchivesPanel.Item.ArchivesCenterAchievementItemV2")
ArchivesCenterAchievementPanelV2 = class("ArchivesCenterAchievementPanelV2", UIBasePanel)
ArchivesCenterAchievementPanelV2.__index = ArchivesCenterAchievementPanelV2
function ArchivesCenterAchievementPanelV2:ctor(csPanel)
  self.super.ctor(self, csPanel)
end
function ArchivesCenterAchievementPanelV2:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.mLeftTabViewList = {}
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ArchivesCenterAchievementPanelV2)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnReceive.gameObject).onClick = function(gameObject)
    self:OnAllReceiveClick(gameObject)
  end
end
function ArchivesCenterAchievementPanelV2:InitLeftTab()
  local tagDataList = NetCmdAchieveData:GetTagDataList()
  for i = 0, tagDataList.Count - 1 do
    local index = i + 1
    local tagData = tagDataList[i]
    if self.mLeftTabViewList[index] then
      self.mLeftTabViewList[index]:SetData(tagData)
    else
      local tagItem = ArchivesCenterAchievementLeftTabItemV2.New()
      tagItem:InitCtrl(self.ui.mTrans_LeftTabList)
      tagItem:SetData(tagData)
      table.insert(self.mLeftTabViewList, tagItem)
    end
    UIUtils.GetButtonListener(self.mLeftTabViewList[index].ui.mBtn_Root.gameObject).onClick = function()
      self:OnClickTag(self.mLeftTabViewList[index])
    end
    if tagData.id == self.mData then
      self:OnClickTag(self.mLeftTabViewList[index])
    end
  end
end
function ArchivesCenterAchievementPanelV2:OnInit(root, data)
  self.mData = data
  function self.ui.mVirtualListEx_AchievementList.itemProvider()
    return self:ItemProvider()
  end
  self:InitLeftTab()
end
function ArchivesCenterAchievementPanelV2:ItemProvider()
  local itemView = ArchivesCenterAchievementItemV2.New()
  itemView:InitCtrl(self.ui.mTrans_Content)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ArchivesCenterAchievementPanelV2:ItemRenderer(index, renderData)
  local data = self.list[index]
  if data then
    local item = renderData.data
    item:SetData(data)
    local itemBtn1 = UIUtils.GetButtonListener(item.ui.mBtn_BtnGoOn.gameObject)
    function itemBtn1.onClick(gameObject)
      self:OnGotoClick(gameObject)
    end
    itemBtn1.param = data
    local itemBtn2 = UIUtils.GetButtonListener(item.ui.mBtn_BtnReceive.gameObject)
    function itemBtn2.onClick(gameObject)
      self:OnReceiveClick(gameObject)
    end
    itemBtn2.param = data
  end
end
function ArchivesCenterAchievementPanelV2:UpdateAchieveList()
  self.list = NetCmdAchieveData:GetAchieveDataListByTag(self.mCurTagItem.tagId)
  local canReceive = {}
  local allComplete = true
  function self.ui.mVirtualListEx_AchievementList.itemRenderer(...)
    self:ItemRenderer(...)
  end
  for i = 0, self.list.Count - 1 do
    local data = self.list[i]
    if data.IsCompleted and not data.IsReceived then
      table.insert(canReceive, data.Id)
    end
    allComplete = data.Progress == 1
  end
  self.ui.mMonoScrollerFadeManager_Content.enabled = false
  self.ui.mMonoScrollerFadeManager_Content.enabled = true
  self.ui.mVirtualListEx_AchievementList.content.anchoredPosition = vector2zero
  self.ui.mVirtualListEx_AchievementList:Refresh()
  self.ui.mVirtualListEx_AchievementList.numItems = self.list.Count
  UIUtils.GetButtonListener(self.ui.mBtn_BtnReceive.gameObject).param = canReceive
  self:UpdateAchieveAll(self.mCurTagItem.mData)
end
function ArchivesCenterAchievementPanelV2:UpdateAchieveAll(data)
  local count = NetCmdAchieveData:GetTotalTagProcess()
  local total = NetCmdAchieveData:GetTotalTagCount()
  self.ui.mText_Num.text = "<color=#f26c1c>" .. count .. "</color>/" .. total
  self.ui.mImg_ProgressBar.fillAmount = count / total
  setactive(self.ui.mTrans_Action.gameObject, NetCmdAchieveData:TagRewardCanReceive(self.mCurTagItem.mData.id) or NetCmdAchieveData:CanReceiveByTagId(self.mCurTagItem.mData.id))
end
function ArchivesCenterAchievementPanelV2:OnClickTag(item)
  if self.mCurTagItem ~= nil then
    if item.tagId ~= self.mCurTagItem.tagId then
      self.mCurTagItem:SetItemState(false)
    else
      return
    end
  end
  self.allClicked = false
  item:SetItemState(true)
  self.mCurTagItem = item
  self:UpdatePanel()
end
function ArchivesCenterAchievementPanelV2:UpdatePanel()
  for _, item in ipairs(self.mLeftTabViewList) do
    item:RefreshData()
  end
  self.allClicked = false
  self:UpdateAchieveList()
  self:UpdateRedPoint()
end
function ArchivesCenterAchievementPanelV2:OnGotoClick(gameObject)
  local itemBtn = UIUtils.GetButtonListener(gameObject)
  local dailyData = itemBtn.param
  SceneSwitch:SwitchByID(dailyData.jumpID)
  self.needRefresh = true
end
function ArchivesCenterAchievementPanelV2:OnAllReceiveClick(gameObject)
  local itemBtn = UIUtils.GetButtonListener(gameObject)
  local receiveList = itemBtn.param
  if receiveList ~= nil and 0 < #receiveList then
    if self.allClicked then
      return
    end
    self.allClicked = true
    NetCmdAchieveData:SendReqTakeAchievementRewardCmd(receiveList, function(ret)
      self:OnReceivedCallback(ret)
    end)
  else
    self.allClicked = false
  end
end
function ArchivesCenterAchievementPanelV2:OnTagRewardReceive(gameObject)
  NetCmdAchieveData:GetFirstTagRewardById(self.mCurTagItem.mData.id, function(ret)
    self:OnReceivedCallback(ret)
  end)
end
function ArchivesCenterAchievementPanelV2:OnReceiveClick(gameObject)
  local itemBtn = UIUtils.GetButtonListener(gameObject)
  local dailyData = itemBtn.param
  self.mUICommonReceiveItemData = itemBtn.param
  local idList = {}
  table.insert(idList, dailyData.Id)
  NetCmdAchieveData:SendReqTakeAchievementRewardCmd(idList, function(ret)
    self:OnReceivedCallback(ret)
  end)
end
function ArchivesCenterAchievementPanelV2:OnReceivedCallback(ret)
  if ret == ErrorCodeSuc then
    gfdebug("领取成功")
    if AccountNetCmdHandler.IsLevelUpdate == true then
      UICommonLevelUpPanel.Open(UICommonLevelUpPanel.ShowType.CommanderLevelUp, nil, true, true)
    else
      UIManager.OpenUIByParam(UIDef.UICommonReceivePanel, {
        nil,
        nil,
        nil,
        true
      })
    end
    TimerSys:DelayCall(0.4, function()
      self:UpdatePanel()
    end)
  else
    gfdebug("领取失败")
    self.allClicked = false
  end
end
function ArchivesCenterAchievementPanelV2.CloseTakeQuestRewardCallBack(data)
  if self.mUICommonReceiveItem ~= nil then
    self.mUICommonReceiveItem:SetData(nil)
  end
end
function ArchivesCenterAchievementPanelV2:OnReturnClicked(gameObject)
  self.Close()
end
function ArchivesCenterAchievementPanelV2:OnShowStart()
end
function ArchivesCenterAchievementPanelV2:OnShowFinish()
end
function ArchivesCenterAchievementPanelV2:OnBackFrom()
  self:UpdatePanel()
end
function ArchivesCenterAchievementPanelV2:OnClose()
end
function ArchivesCenterAchievementPanelV2:OnHide()
end
function ArchivesCenterAchievementPanelV2:OnHideFinish()
end
function ArchivesCenterAchievementPanelV2:OnRelease()
  self.mCurTagItem = nil
  self.mUICommonReceiveItemData = nil
  self.mUICommonReceiveItem = nil
end
