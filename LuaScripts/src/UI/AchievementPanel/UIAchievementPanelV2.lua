require("UI.AchievementPanel.Item.UIAchievementLeftTabItemV2")
require("UI.UIBasePanel")
require("UI.AchievementPanel.UIAchievementPanelV2View")
UIAchievementPanelV2 = class("UIAchievementPanelV2", UIBasePanel)
UIAchievementPanelV2.__index = UIAchievementPanelV2
UIAchievementPanelV2.mView = nil
UIAchievementPanelV2.mData = nil
UIAchievementPanelV2.mCurTagItem = nil
UIAchievementPanelV2.mAchieveItemList = {}
UIAchievementPanelV2.mUICommonReceiveItem = nil
UIAchievementPanelV2.mUICommonReceiveItemData = nil
UIAchievementPanelV2.allClicked = false
UIAchievementPanelV2.mPath_UICommonTabButtonItem = "UICommonFramework/UI_CommonTabButtonItem.prefab"
function UIAchievementPanelV2:ctor()
  UIAchievementPanelV2.super.ctor(self)
end
function UIAchievementPanelV2.Open()
end
function UIAchievementPanelV2.Close()
  UIManager.CloseUI(UIDef.UIAchievementPanel)
end
function UIAchievementPanelV2.Hide()
  self:Show(false)
end
function UIAchievementPanelV2:OnInit(root, data)
  self.mData = data
  self:SetRoot(root)
  self.mView = UIAchievementPanelV2View.New()
  self.ui = {}
  self.mView:InitCtrl(self.mUIRoot, self.ui)
  self.RedPointType = {}
  self.allClicked = false
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnReturnClicked()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    CS.BattlePerformSetting.RefreshGraphicSetting()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GetAll.gameObject).onClick = function(gameObject)
    self:OnAllReceiveClick(gameObject)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_CompleteQuest.gameObject).onClick = function(gameObject)
    self:OnTagRewardReceive(gameObject)
  end
  self.ui.mText_CompleteQuest.text = TableData.GetHintById(901001)
  self.ui.mText_TextUnCompleted.text = TableData.GetHintById(901002)
  self.ui.mText_TextCompleted.text = TableData.GetHintById(901003)
  self.ui.mText_Name1.text = TableData.GetHintById(901002)
  function self.ui.mVirtualList_Achievement.itemProvider()
    return self:itemProvider()
  end
  self.mItemViewList = List:New()
  self.mLeftTabViewList = List:New()
  self:InitAchieveTagList()
end
function UIAchievementPanelV2:OnShowStart()
  self:UpdatePanel()
end
function UIAchievementPanelV2:OnBackFrom()
  self:UpdatePanel()
end
function UIAchievementPanelV2:OnTop()
  if self.needRefresh then
    self:UpdatePanel()
    self.needRefresh = nil
  end
end
function UIAchievementPanelV2:itemProvider()
  local itemView = UIAchievementItemV2.New()
  itemView:InitCtrl(self.ui.mTrans_Achievement.gameObject)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  table.insert(self.mAchieveItemList, itemView)
  return renderDataItem
end
function UIAchievementPanelV2:ItemRenderer(index, renderData)
  local data = self.list[index]
  local item = renderData.data
  item:SetData(data)
  local itemBtn1 = UIUtils.GetButtonListener(item.ui.mBtn_GotoQuest.gameObject)
  function itemBtn1.onClick(gameObject)
    self:OnGotoClick(gameObject)
  end
  itemBtn1.param = data
  itemBtn1 = UIUtils.GetButtonListener(item.ui.mBtn_CompleteQuest.gameObject)
  function itemBtn1.onClick(gameObject)
    self:OnReceiveClick(gameObject)
  end
  itemBtn1.param = data
end
function UIAchievementPanelV2:InitAchieveTagList()
  for i = 0, TableData.listAchievementTagDatas.Count - 1 do
    do
      local tagData = TableData.listAchievementTagDatas[i]
      local tagItem = UIAchievementLeftTabItemV2.New()
      tagItem:InitCtrl(self.ui.mContent_Material)
      self.mLeftTabViewList:Add(tagItem)
      tagItem:SetData(tagData)
      UIUtils.GetButtonListener(tagItem:GetSelfButton().gameObject).onClick = function()
        self:OnClickTag(tagItem)
      end
      if tagData.id == self.mData then
        self:OnClickTag(tagItem)
      end
      i = i + 1
    end
  end
end
function UIAchievementPanelV2:UpdateAchieveList()
  self.list = NetCmdAchieveData:GetAchieveDataListByTag(self.mCurTagItem.tagId)
  local canReceive = {}
  local allComplete = true
  function self.ui.mVirtualList_Achievement.itemRenderer(index, renderDataItem)
    self:ItemRenderer(index, renderDataItem)
  end
  for i = 0, self.list.Count - 1 do
    local data = self.list[i]
    if data.IsCompleted and not data.IsReceived then
      table.insert(canReceive, data.Id)
    end
    allComplete = data.Progress == 1
  end
  self.ui.mVirtualList_Achievement.numItems = self.list.Count
  self.ui.mVirtualList_Achievement:Refresh()
  self.ui.mVirtualList_Achievement.content.anchoredPosition = vector2zero
  self.ui.mVirtualList_Achievement:StopMovement()
  UIUtils.GetButtonListener(self.ui.mBtn_GetAll.gameObject).param = canReceive
  setactive(self.ui.mTrans_Receive, 0 < #canReceive)
  setactive(self.ui.mTrans_TextCompleted, 0 < self.list.Count and allComplete and #canReceive == 0)
  setactive(self.ui.mTrans_TextUnCompleted, not allComplete and #canReceive == 0 or self.list.Count == 0)
  self:UpdateAchieveAll(self.mCurTagItem.mData)
end
function UIAchievementPanelV2:UpdateAchieveAll(data)
  self.ui.mText_Tittle.text = data.tag_name.str
  self.ui.mImg_Icon.sprite = IconUtils.GetAchievementIcon(data.icon)
  local rewardNotReceivedId = NetCmdAchieveData:GetCurrentNotReceivedTagRewardId(data.id)
  local rewardId = NetCmdAchieveData:GetCurrentTagRewardId(data.id)
  local count = 0
  local rewardData, nextRewardData, reward
  if rewardNotReceivedId == -1 then
    count = NetCmdAchieveData:GetCurrentTagRewardLevelProgress(data)
    rewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId)
    nextRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId + 1)
    if nextRewardData ~= nil and nextRewardData.lv_exp > NetCmdItemData:GetResCount(data.point_item) then
      self.ui.mText_ProgressNum.text = count .. "/" .. nextRewardData.lv_exp - rewardData.lv_exp
      self.ui.mImg_ProgressBar.fillAmount = count / (nextRewardData.lv_exp - rewardData.lv_exp)
    else
      local prevRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId - 1)
      self.ui.mText_ProgressNum.text = count .. "/" .. rewardData.lv_exp - prevRewardData.lv_exp
      self.ui.mImg_ProgressBar.fillAmount = count / (rewardData.lv_exp - prevRewardData.lv_exp)
    end
    self.ui.mText_Content.text = "Lv." .. rewardData.tag_lv
    reward = nextRewardData.Reward
  else
    rewardId = rewardNotReceivedId
    rewardData = TableData.listAchievementRewardDatas:GetDataById(rewardNotReceivedId)
    local prevRewardData = TableData.listAchievementRewardDatas:GetDataById(rewardId - 1)
    count = rewardData.lv_exp - prevRewardData.lv_exp
    self.ui.mText_ProgressNum.text = count .. "/" .. rewardData.lv_exp - prevRewardData.lv_exp
    self.ui.mImg_ProgressBar.fillAmount = count / (rewardData.lv_exp - prevRewardData.lv_exp)
    self.ui.mText_Content.text = "Lv." .. prevRewardData.tag_lv
    reward = rewardData.Reward
  end
  for _, item in ipairs(self.mItemViewList) do
    gfdestroy(item:GetRoot())
  end
  for itemId, num in pairs(reward) do
    local itemview = UICommonItem.New()
    itemview:InitCtrl(self.ui.mContent_All)
    itemview:SetItemData(itemId, num)
    self.mItemViewList:Add(itemview)
    itemview.mUIRoot:SetAsFirstSibling()
    local stcData = TableData.GetItemData(itemId)
    TipsManager.Add(itemview.mUIRoot, stcData)
  end
  local canReceive = NetCmdAchieveData:TagRewardCanReceive(data.id)
  local allCompleted = NetCmdAchieveData:TagRewardAllCompleted(data.id)
  setactive(self.ui.mTrans_BtnPick, canReceive)
  setactive(self.ui.mTrans_CompletedAll, not canReceive and allCompleted)
  setactive(self.ui.mTrans_UnCompletedAll, not canReceive and not allCompleted)
end
function UIAchievementPanelV2:OnClickTag(item)
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
function UIAchievementPanelV2:UpdatePanel()
  for _, item in ipairs(self.mLeftTabViewList) do
    item:RefreshData()
  end
  self.allClicked = false
  self.ui.mText_Num.text = NetCmdAchieveData:GetTotalPoints()
  self:UpdateAchieveList()
  self:UpdateRedPoint()
end
function UIAchievementPanelV2:OnGotoClick(gameObject)
  local itemBtn = UIUtils.GetButtonListener(gameObject)
  local dailyData = itemBtn.param
  SceneSwitch:SwitchByID(dailyData.jumpID)
  self.needRefresh = true
end
function UIAchievementPanelV2:OnAllReceiveClick(gameObject)
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
function UIAchievementPanelV2:OnTagRewardReceive(gameObject)
  NetCmdAchieveData:GetFirstTagRewardById(self.mCurTagItem.mData.id, function(ret)
    self:OnReceivedCallback(ret)
  end)
end
function UIAchievementPanelV2:OnReceiveClick(gameObject)
  local itemBtn = UIUtils.GetButtonListener(gameObject)
  local dailyData = itemBtn.param
  self.mUICommonReceiveItemData = itemBtn.param
  local idList = {}
  table.insert(idList, dailyData.Id)
  NetCmdAchieveData:SendReqTakeAchievementRewardCmd(idList, function(ret)
    self:OnReceivedCallback(ret)
  end)
end
function UIAchievementPanelV2:OnReceivedCallback(ret)
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
      UIAchievementPanelV2:UpdatePanel()
    end)
  else
    gfdebug("领取失败")
    self.allClicked = false
  end
end
function UIAchievementPanelV2.CloseTakeQuestRewardCallBack(data)
  if self.mUICommonReceiveItem ~= nil then
    self.mUICommonReceiveItem:SetData(nil)
  end
end
function UIAchievementPanelV2:OnReturnClicked(gameObject)
  self.Close()
end
function UIAchievementPanelV2:OnClose()
  self.mCurTagItem = nil
  for _, item in ipairs(self.mItemViewList) do
    gfdestroy(item:GetRoot())
  end
  for _, item in ipairs(self.mLeftTabViewList) do
    gfdestroy(item:GetRoot())
  end
  self.mAchieveItemList = {}
  self.mUICommonReceiveItemData = nil
  self.mUICommonReceiveItem = nil
end
