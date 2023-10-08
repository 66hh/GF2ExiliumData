require("UI.UIBasePanel")
require("UI.Common.UICommonItem")
require("UI.ActivityTour.Btn_ActivityMuseItem")
require("UI.ActivityTour.Btn_ActivityMuseExchangeLeftItem")
require("UI.ActivityTour.Btn_ActivityMuseExchangeRightItem")
ActivityMusePanel = class("ActivityMusePanel", UIBasePanel)
ActivityMusePanel.__index = ActivityMusePanel
function ActivityMusePanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Panel
end
function ActivityMusePanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:AddBtnListener()
  self:ManualUI()
end
function ActivityMusePanel:AddBtnListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.ActivityMusePanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    self.themeId = NetCmdRecentActivityData:GetNowOpenThemeId(self.themeId)
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityMusePanel)
      return
    end
    for i = 1, self.collectDataList.Count do
      local itemNum = NetCmdItemData:GetItemCount(self.collectDataList[i - 1].id)
      if itemNum <= 0 then
        CS.PopupMessageManager.PopupString(TableData.GetHintById(270185))
        return
      end
    end
    NetCmdThemeData:SendActiveInspiration(self.themeId, function(ret)
      if ret == ErrorCodeSuc then
        self.isActiveCollect = false
        self.ui.mAnimator_Collect:SetBool("Activation", true)
        self:CleanOpenTime()
        self.openTime = TimerSys:DelayCall(1, function()
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
          self:CleanOpenTime()
        end)
        self:UpdateCollectRedPoint()
      end
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Refresh.gameObject).onClick = function()
    if not NetCmdRecentActivityData:ThemeActivityIsOpen(self.themeId) then
      CS.PopupMessageManager.PopupString(TableData.GetHintById(260007))
      UIManager.CloseUI(UIDef.ActivityMusePanel)
      return
    end
    if self.refreshTime then
      local refreshCount = CGameTime:GetTimestamp() - self.refreshTime
      if refreshCount < 15 then
        local count = 15 - refreshCount
        CS.PopupMessageManager.PopupString(string_format(TableData.GetHintById(270186), count))
        return
      end
    end
    NetCmdThemeData:SendRefreshInspirationOrder(self.themeId, function(ret)
      if ret == ErrorCodeSuc then
        self.refreshTime = CGameTime:GetTimestamp()
        self:UpdateExchangeList()
        CS.PopupMessageManager.PopupPositiveString(TableData.GetHintById(270207))
      end
    end)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Hint.gameObject).onClick = function()
    self.isonlyFirend = not self.isonlyFirend
    self:UpdateToggle()
    self:RefreshItemList()
  end
end
function ActivityMusePanel:UpdateToggle()
  setactive(self.ui.mTrans_ImgOn.gameObject, not self.isonlyFirend)
  setactive(self.ui.mTrans_ImgOff.gameObject, self.isonlyFirend)
  self:RefreshItemList()
end
function ActivityMusePanel:ManualUI()
  self.activityID = 101
  self.currSelectIndex = -1
  self.isonlyFirend = false
  setactive(self.ui.mTrans_Item.gameObject, false)
  setactive(self.ui.mVirtualListEx_RightList.gameObject, true)
  self.firstDataList = NetCmdThemeData:GetCollectRewardList(self.activityID, 1)
  self.secondDataList = NetCmdThemeData:GetCollectRewardList(self.activityID, 2)
  self.firstUIList = {}
  self.secondUIList = {}
  self.secTextList = {}
  self.leftTimerList = {}
  for i = 1, self.firstDataList.Count do
    do
      local data = self.firstDataList[i - 1]
      local itemData = self:GetItemData(data.reward_item)
      local collCount = NetCmdThemeData:GetCollectItemCount(data.id)
      local item = UICommonItem.New()
      item:InitCtrl(self.ui.mTrans_Content)
      item:SetItemData(itemData.itemId, itemData.itemNum, nil, nil, nil, nil, nil, function()
        UITipsPanel.Open(TableData.GetItemData(itemData.itemId))
      end)
      item:SetReceivedIcon(collCount >= data.reward_count)
      table.insert(self.firstUIList, item)
    end
  end
  for i = 1, self.secondDataList.Count do
    do
      local GO = instantiate(self.ui.mTrans_Item, self.ui.mTrans_ItemList)
      GO.transform:SetAsLastSibling()
      setactive(GO.gameObject, true)
      local data = self.secondDataList[i - 1]
      local collCount = NetCmdThemeData:GetCollectItemCount(data.id)
      local itemData = self:GetItemData(data.reward_item)
      local item = UICommonItem.New()
      item:InitCtrl(GO.transform)
      item:SetItemData(itemData.itemId, itemData.itemNum, nil, nil, nil, nil, nil, function()
        UITipsPanel.Open(TableData.GetItemData(itemData.itemId))
      end)
      item:SetReceivedIcon(collCount >= data.reward_count)
      local txt = GO.transform:Find("TextNum/Text_Num"):GetComponent(typeof(CS.UnityEngine.UI.Text))
      txt.text = TableData.GetHintById(103124) .. data.reward_count - collCount
      table.insert(self.secTextList, txt)
      table.insert(self.secondUIList, item)
    end
  end
  self.collectDataList = NetCmdThemeData:GetCollectDataList(self.activityID)
  self.collectItemList = {}
  for i = 1, self.ui.mTrans_Item1.childCount do
    do
      local index = i - 1
      local trans = self.ui.mTrans_Item1:GetChild(index)
      local btn = trans:GetComponent(typeof(CS.UnityEngine.UI.GFButton))
      UIUtils.GetButtonListener(btn.gameObject).onClick = function()
        UITipsPanel.Open(TableData.GetItemData(self.collectDataList[index].id))
      end
      local parent = trans:Find("GrpItem")
      local item = Btn_ActivityMuseItem.New()
      item:InitCtrl(parent)
      item:SetData(self.collectDataList[index])
      table.insert(self.collectItemList, item)
    end
  end
  self.tabUIList = {}
  local tabHintList = {270022, 270023}
  for i = 1, 2 do
    self.tabUIList[i] = {}
    local instObj = instantiate(self.ui.mScrollListChild_TabContent.childItem)
    self:LuaUIBindTable(instObj, self.tabUIList[i])
    UIUtils.AddListItem(instObj.gameObject, self.ui.mScrollListChild_TabContent.gameObject)
    self.tabUIList[i].mText_Name.text = TableData.GetHintById(tabHintList[i])
    UIUtils.GetButtonListener(self.tabUIList[i].mBtn_Self.gameObject).onClick = function()
      self:OnClickTab(i)
    end
  end
  self.showCollectList = {}
  for i = 1, self.collectDataList.Count do
    local data = self.collectDataList[i - 1]
    local item = Btn_ActivityMuseItem.New()
    item:InitCtrl(self.ui.mTrans_Item2)
    item:SetData(data)
    table.insert(self.showCollectList, item)
  end
  self.mySubUIList = {}
end
function ActivityMusePanel:CleanOpenTime()
  if self.openTime then
    self.openTime:Stop()
    self.openTime = nil
  end
end
function ActivityMusePanel:CleanTimeIndex(index)
  if self.leftTimerList[index] then
    self.leftTimerList[index]:Stop()
    self.leftTimerList[index] = nil
  end
end
function ActivityMusePanel:CleanAllTime()
  for k, v in pairs(self.leftTimerList) do
    v:Stop()
    v = nil
  end
  self.leftTimerList = {}
end
function ActivityMusePanel:UpdateTimer(item, data)
  if data == nil or data.Expire == nil then
    return
  end
  if data.MatchUid and data.MatchUid > 0 then
    NetCmdThemeData:CleanMyOrder(data.Id)
    self:CleanTimeIndex(data.Id)
    self:UpdateMySubList()
    return
  end
  local timeCount = data.Expire - CGameTime:GetTimestamp()
  local desc = TableData.GetHintById(108001)
  if 0 < timeCount then
    self:CleanTimeIndex(data.Id)
    item.ui.mText_Info.text = desc .. CS.CGameTime.ReturnDurationBySecAuto(timeCount)
    self.leftTimerList[data.Id] = TimerSys:DelayCall(1, function()
      local count = data.Expire - CGameTime:GetTimestamp()
      if 0 < count then
        item.ui.mText_Info.text = desc .. CS.CGameTime.ReturnDurationBySecAuto(count)
      else
        self:CleanTimeIndex(data.Id)
        self:UpdateMySubList()
      end
    end, nil, timeCount)
  end
end
function ActivityMusePanel:RightProvider()
  local itemView = Btn_ActivityMuseExchangeRightItem.New()
  itemView:InitCtrl(self.ui.mTrans_Content2)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function ActivityMusePanel:RightRenderer(index, renderData)
  local data
  if self.isonlyFirend then
    data = self.onlyFriendList[index]
  else
    data = self.exchangeList[index]
  end
  if data then
    local item = renderData.data
    item:SetData(data, self.themeId)
  end
end
function ActivityMusePanel:GetItemData(rewardList)
  local itemData = {}
  for k, v in pairs(rewardList) do
    itemData.itemId = k
    itemData.itemNum = v
    break
  end
  return itemData
end
function ActivityMusePanel:UpdateInfo()
  self.museData = TableData.listCollectionThemeDatas:GetDataById(self.activityID)
  if self.museData then
    self:UpdateCollectInfo()
    self:UpdateCollectReward()
    self:UpdateRewardCount()
    self:UpdateMySubList()
    self:UpdateExchangeList()
    self:UpdateCollectRedPoint()
    self:UpdateExchangeRedPoint()
  end
end
function ActivityMusePanel:UpdateCollectRedPoint()
  if self.tabUIList[1] then
    setactive(self.tabUIList[1].mTrans_RedPoint.gameObject, NetCmdThemeData:ThemeCollectRed())
  end
end
function ActivityMusePanel:UpdateExchangeRedPoint()
  if self.tabUIList[2] then
    setactive(self.tabUIList[2].mTrans_RedPoint.gameObject, NetCmdThemeData:ThemeExchangeRed())
  end
end
function ActivityMusePanel:UpdateCollectInfo()
  self.ui.mText_Name.text = self.museData.name
  self.ui.mText_Description.text = self.museData.function_desc
  self.ui.mImg_Icon.sprite = IconUtils.GetActivitySprite(self.museData.theme_image)
  self.ui.mImg_IconGlow.sprite = IconUtils.GetActivitySprite(self.museData.theme_image)
  local collectCount = NetCmdThemeData:GetCurrActiCount()
  local collTotolCount = NetCmdThemeData:GetTotalActiCount()
  self.ui.mText_Num.text = "<color=#d8bf74>" .. collectCount .. "</color>/" .. collTotolCount .. TableData.GetHintById(270204)
  setactive(self.ui.mTrans_Btn.gameObject, collectCount < collTotolCount)
  setactive(self.ui.mTrans_Receive.gameObject, collectCount >= collTotolCount)
end
function ActivityMusePanel:UpdateExchangeList()
  self.exchangeList = NetCmdThemeData:GetExchangeList(false)
  self.onlyFriendList = NetCmdThemeData:GetExchangeList(true)
  self.exchangeList2 = NetCmdThemeData:GetExchangeList(false)
  self.onlyFriendList2 = NetCmdThemeData:GetExchangeList(true)
  function self.ui.mVirtualListEx_RightList.itemProvider()
    return self:RightProvider()
  end
  function self.ui.mVirtualListEx_RightList.itemRenderer(...)
    self:RightRenderer(...)
  end
  self:RefreshItemList()
end
function ActivityMusePanel:RefreshItemList()
  if self.isonlyFirend then
    if self.comScreenItemV2 == nil then
      self.comScreenItemV2 = ComScreenItemHelper:InitExchange(self.ui.mScrollListChild_BtnScreen.gameObject, self.onlyFriendList, function()
        self:RefreshItemList()
      end, nil)
    end
    self.comScreenItemV2:DoSetList(self.onlyFriendList2)
  else
    if self.comScreenItemV2 == nil then
      self.comScreenItemV2 = ComScreenItemHelper:InitExchange(self.ui.mScrollListChild_BtnScreen.gameObject, self.exchangeList, function()
        self:RefreshItemList()
      end, nil)
    end
    self.comScreenItemV2:DoSetList(self.exchangeList2)
  end
  if self.isonlyFirend then
    self.onlyFriendList = self.comScreenItemV2:GetResultList()
    self.ui.mVirtualListEx_RightList.numItems = self.onlyFriendList.Count
    setactive(self.ui.mTrans_Title.gameObject, self.onlyFriendList.Count == 0)
  else
    self.exchangeList = self.comScreenItemV2:GetResultList()
    self.ui.mVirtualListEx_RightList.numItems = self.exchangeList.Count
    setactive(self.ui.mTrans_Title.gameObject, self.exchangeList.Count == 0)
  end
  self.ui.mVirtualListEx_RightList:Refresh()
end
function ActivityMusePanel:UpdateMySubList()
  self.mysubList = NetCmdThemeData:GetMySubList()
  local count
  if self.mysubList.Count >= self.museData.order_num - 1 then
    count = self.museData.order_num
  else
    count = self.mysubList.Count + 1
  end
  for i = 1, count do
    local subView = self.mySubUIList[i]
    if subView == nil then
      subView = Btn_ActivityMuseExchangeLeftItem.New()
      subView:InitCtrl(self.ui.mTrans_Content1)
      table.insert(self.mySubUIList, subView)
    end
    local data
    if i <= self.mysubList.Count then
      data = self.mysubList[i - 1]
    end
    subView:ShowItem(true)
    subView:SetData(data, self)
    self:UpdateTimer(subView, data)
  end
  if count < #self.mySubUIList then
    for i = count + 1, #self.mySubUIList do
      self.mySubUIList[i]:ShowItem(false)
    end
  end
  self.ui.mMonoScrollerFadeManager_Content.enabled = false
  self.ui.mMonoScrollerFadeManager_Content.enabled = true
  self.ui.mText_Num1.text = string_format(TableData.GetHintById(270143), self.mysubList.Count, self.museData.order_num)
end
function ActivityMusePanel:UpdateCollectReward()
  for k, v in ipairs(self.firstUIList) do
    local data = self.firstDataList[k - 1]
    local collectCount = NetCmdThemeData:GetCollectItemCount(data.id)
    v:SetReceivedIcon(collectCount >= data.reward_count)
  end
  for k, v in ipairs(self.secondUIList) do
    local data = self.secondDataList[k - 1]
    local collectCount = NetCmdThemeData:GetCollectItemCount(data.id)
    v:SetReceivedIcon(collectCount >= data.reward_count)
    local secTxt = self.secTextList[k]
    if secTxt then
      secTxt.text = TableData.GetHintById(103124) .. data.reward_count - collectCount
    end
  end
end
function ActivityMusePanel:UpdateRewardCount()
  for k, v in ipairs(self.collectItemList) do
    v:SetData(self.collectDataList[k - 1])
  end
  for k, v in ipairs(self.showCollectList) do
    v:SetData(self.collectDataList[k - 1])
  end
end
function ActivityMusePanel:OnClickTab(index)
  if self.currSelectIndex == index then
    return
  end
  self.currSelectIndex = index
  setactive(self.ui.mTrans_Collect.gameObject, index == 1)
  setactive(self.ui.mTrans_Exchange.gameObject, index == 2)
  for i = 1, #self.tabUIList do
    self.tabUIList[i].mBtn_Self.interactable = index ~= i
  end
  if index == 2 then
    self:UpdateMySubList()
  end
end
function ActivityMusePanel:OnInit(root, data)
  self.themeId = data.themeId
  function ActivityMusePanel.RefreshInfo()
    self:UpdateRewardCount()
    self:UpdateMySubList()
    self:UpdateCollectRedPoint()
    self:UpdateExchangeRedPoint()
  end
  MessageSys:AddListener(CS.GF2.Message.UIEvent.OnThemeCollectUpdate, ActivityMusePanel.RefreshInfo)
end
function ActivityMusePanel:OnShowStart()
  NetCmdThemeData:SendInspirationOrders(self.themeId, function(ret)
    self:UpdateInfo()
    if self.currSelectIndex > 0 then
      self:OnClickTab(self.currSelectIndex)
    else
      self:OnClickTab(1)
    end
  end)
end
function ActivityMusePanel:OnShowFinish()
end
function ActivityMusePanel:OnTop()
  self:UpdateCollectInfo()
  self:UpdateCollectReward()
  self:UpdateRewardCount()
  self:UpdateMySubList()
  self:UpdateExchangeList()
  self:UpdateCollectRedPoint()
  self:UpdateExchangeRedPoint()
end
function ActivityMusePanel:OnBackFrom()
  self:UpdateCollectInfo()
  self:UpdateCollectReward()
  self:UpdateRewardCount()
  self:UpdateMySubList()
  self:UpdateExchangeList()
  self:UpdateCollectRedPoint()
  self:UpdateExchangeRedPoint()
end
function ActivityMusePanel:OnClose()
  self.currSelectIndex = -1
  self.refreshTime = nil
  self.isActiveCollect = false
  if self.comScreenItemV2 then
    self.comScreenItemV2:CleanGameSetCfg()
    self.comScreenItemV2:OnRelease()
    self.comScreenItemV2 = nil
  end
  self:CleanAllTime()
  self:CleanOpenTime()
end
function ActivityMusePanel:OnHide()
end
function ActivityMusePanel:OnHideFinish()
end
function ActivityMusePanel:OnRelease()
  self.currSelectIndex = -1
  self.refreshTime = nil
  self.isActiveCollect = false
  if self.comScreenItemV2 then
    self.comScreenItemV2:CleanGameSetCfg()
    self.comScreenItemV2:OnRelease()
    self.comScreenItemV2 = nil
  end
  self:CleanAllTime()
  self:CleanOpenTime()
end
