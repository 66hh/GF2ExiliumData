require("UI.CommunicationPanel.Items.UIFriendListItem")
require("UI.CommunicationPanel.Items.UIRobotFriendItem")
require("UI.CommunicationPanel.Items.UIFriendTabItem")
require("UI.CommunicationPanel.GlobalData.UIFriendGlobal")
UICommunicationFriendSubPanel = class("UICommunicationFriendSubPanel", UIBaseView)
UICommunicationFriendSubPanel.__index = UICommunicationFriendSubPanel
UICommunicationFriendSubPanel.mPath_ChatFriendListItem = "Chat/Btn_ChatFriendListItem.prefab"
UICommunicationFriendSubPanel.curTab = nil
UICommunicationFriendSubPanel.curList = {}
UICommunicationFriendSubPanel.friendItemList = {}
UICommunicationFriendSubPanel.tabList = {}
UICommunicationFriendSubPanel.virtualList = nil
UICommunicationFriendSubPanel.timer = 0
UICommunicationFriendSubPanel.refreshTime = 0
UICommunicationFriendSubPanel.canRefreshRecommend = true
UICommunicationFriendSubPanel.pointer = nil
UICommunicationFriendSubPanel.robotItem = nil
UICommunicationFriendSubPanel.selectItem = nil
UICommunicationFriendSubPanel.RedPointType = {
  RedPointConst.ApplyFriend
}
UICommunicationFriendSubPanel.cdTimer = nil
function UICommunicationFriendSubPanel:__InitCtrl()
end
function UICommunicationFriendSubPanel:InitCtrl(root, parent)
  self.ui = {}
  self:SetRoot(root)
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
  self.mParent = parent
  self.mindex = 1
  self.robotItem = nil
  self.selectItem = nil
  function self.OnItemShow(index)
  end
  function self.friendListChangeFunc(msg)
    self:OnFriendListChange(msg)
  end
  function self.getApproveFunc(msg)
    self:OnGetApproveResult(msg)
  end
  function self.friendChangeMarkFunc(msg)
    self:RefreshChangeMark(msg)
  end
  function self.addBlackFunc(msg)
    self:OnAddBlack(msg)
  end
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.FriendListChange, self.friendListChangeFunc)
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.FriendApproveResult, self.getApproveFunc)
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.FriendChangeMark, self.friendChangeMarkFunc)
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.AddBlack, self.addBlackFunc)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.ApplyFriend, self.ui.mRedPoint_Apply)
  self:InitButtonGroup()
  self:InitTabsData()
end
function UICommunicationFriendSubPanel:OnShowStart()
  TimerSys:DelayCall(0.5, function()
    self.ui.mVirtualList.gameObject:GetComponent(typeof(CS.UnityEngine.CanvasGroup)).blocksRaycasts = true
  end)
end
function UICommunicationFriendSubPanel:HideAllNote()
  if self.selectItem ~= nil then
    self.selectItem:CloseNote()
  end
end
function UICommunicationFriendSubPanel:OnClose()
end
function UICommunicationFriendSubPanel:OnRelease()
  self:OnClickListTab(UIFriendGlobal.ListTab.FriendList)
  self.curTab = nil
  self.curList = {}
  self.tabList = {}
  self.virtualList = nil
  self.timer = 0
  self.canRefreshRecommend = true
  self.pointer = nil
  if self.robotItem ~= nil then
    gfdestroy(self.robotItem:GetRoot())
    self.robotItem = nil
  end
  if self.selectItem ~= nil then
    self.selectItem:CloseNote()
    self.selectItem = nil
  end
  if self.cdTimer then
    self.ui.mBtn_Refresh.interactable = true
    self.cdTimer:Stop()
    self.cdTimer = nil
  end
  if self.friendItemList then
    for i, v in pairs(self.friendItemList) do
      gfdestroy(v.mUIRoot.gameObject)
    end
    self.friendItemList = {}
  end
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.FriendListChange, self.friendListChangeFunc)
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.FriendApproveResult, self.getApproveFunc)
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.FriendChangeMark, self.friendChangeMarkFunc)
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.AddBlack, self.addBlackFunc)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.ApplyFriend)
end
function UICommunicationFriendSubPanel:InitButtonGroup()
  UIUtils.GetButtonListener(self.ui.mBtn_Search.gameObject).onClick = function()
    self:OnSearchFriend()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Paste.gameObject).onClick = function()
    self:OnPastUID()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Refuse.gameObject).onClick = function()
    self:OnRefuseAll()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Refresh.gameObject).onClick = function()
    if self.cdTimer then
    end
    self:OnRefreshRecommendList()
  end
end
function UICommunicationFriendSubPanel:InitTabsData()
  for i, tabId in ipairs(UIFriendGlobal.EnumTab) do
    local tab = UIFriendTabItem.New()
    if i == 1 then
      tab:InitCtrl(self.ui.mBtn_FriendList)
    elseif i == 2 then
      tab:InitCtrl(self.ui.mBtn_ApplyList)
    elseif i == 3 then
      tab:InitCtrl(self.ui.mBtn_AddList)
    elseif i == 4 then
      tab:InitCtrl(self.ui.mBtn_BlackList)
    end
    tab:SetData(tabId, self.ui.mVirtualList)
    UIUtils.GetButtonListener(tab.mBtn_Select.gameObject).onClick = function()
      self:OnClickListTab(tabId)
    end
    self.tabList[tabId] = tab
  end
end
function UICommunicationFriendSubPanel:OnSearchFriend()
  local txt = self.ui.mText_InputField.text
  if txt == "" then
    return
  end
  local selfData = AccountNetCmdHandler:GetRoleInfoData()
  if selfData.UID == tonumber(txt) then
    UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
      selfData,
      nil,
      true
    })
  else
    NetCmdFriendData:SendSocialFriendSearch(txt, function(ret)
      if ret == ErrorCodeSuc then
        self:OnSearchFriendCallBack()
      end
    end)
  end
end
function UICommunicationFriendSubPanel:OnSearchFriendCallBack()
  local playerData = NetCmdFriendData:GetCurSearchFriendData()
  if playerData then
    UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {playerData})
  else
    UIUtils.PopupHintMessage(100024)
  end
end
function UICommunicationFriendSubPanel:OnPastUID()
  self.ui.mText_InputField.text = ""
  if CS.UnityEngine.GUIUtility.systemCopyBuffer ~= "" then
    UIUtils.PopupPositiveHintMessage(100049)
  end
  self.ui.mText_InputField.text = self.ui.mText_InputField.text .. CS.UnityEngine.GUIUtility.systemCopyBuffer
end
function UICommunicationFriendSubPanel:OnRefuseAll()
  NetCmdFriendData:SendFriendApproveApplication(0, false)
end
function UICommunicationFriendSubPanel:OnRefreshRecommendList()
  if self.cdTimer then
    return
  end
  self.cdTimer = TimerSys:DelayCall(6, function()
    self.ui.mBtn_Refresh.interactable = true
    self.cdTimer:Stop()
    self.cdTimer = nil
    self.ui.mVirtualList.gameObject:GetComponent(typeof(CS.UnityEngine.CanvasGroup)).blocksRaycasts = true
  end)
  if self.canRefreshRecommend then
    NetCmdFriendData:SendSocialFriendRecommend(function(ret)
      self.ui.mBtn_Refresh.interactable = false
      UIUtils.PopupPositiveHintMessage(100046)
      self:OnFriendListCallBack(ret)
      self.ui.mTrans_ListContent:GetComponent(typeof(CS.ScrollFade)).enabled = false
      self.ui.mTrans_ListContent:GetComponent(typeof(CS.ScrollFade)).enabled = true
    end)
  end
end
function UICommunicationFriendSubPanel:OnAddBlack(msg)
  NetCmdFriendData:SendGetFriendBlackList()
  if self.curTab.tabId == UIFriendGlobal.ListTab.AddList then
    NetCmdFriendData:SendSocialFriendRecommend(function(ret)
      self:OnFriendListCallBack(ret)
    end)
  end
end
function UICommunicationFriendSubPanel:OnFriendListChange(msg)
  if self.curTab ~= nil then
    self:UpdatePanelList(self.curTab)
  end
end
function UICommunicationFriendSubPanel:UpdateRedPoint()
  setactive(self.ui.mRedPoint_Apply.gameObject, NetCmdFriendData:GetApplyList().Count > 0)
end
function UICommunicationFriendSubPanel:UpdateFriendListText()
  local max = TableData.GetFriendLimit()
  local number = #self.curList
  self.ui.mText_ListTittle.text = TableData.GetHintById(100010) .. number .. "/" .. max
end
function UICommunicationFriendSubPanel:UpdateApplyListText()
  local max = TableData.GetFriendLimit()
  local number = #self.curList
  self.ui.mText_ListTittle.text = TableData.GetHintById(100011) .. number .. "/" .. max
end
function UICommunicationFriendSubPanel:UpdateBlackListText()
  local max = TableData.GlobalSystemData.BlackListUpperLimit
  local number = #self.curList
  self.ui.mText_ListTittle.text = TableData.GetHintById(100022) .. number .. "/" .. max
end
function UICommunicationFriendSubPanel:ReturnClicked()
  self.mParent.ui.mText_Tittle.text = TableData.GetHintById(100213)
  if self.selectItem ~= nil then
    self.selectItem:CloseNote()
    self.selectItem = nil
  end
  self.mParent:EnterSubPanel(0)
end
function UICommunicationFriendSubPanel:OnClickListTab(index)
  if index and 0 < index then
    if self.curTab ~= nil and self.curTab.tabId == index then
      return
    end
    local chooseTab = self.tabList[index]
    if index ~= 0 then
      if self.curTab ~= nil and self.curTab.tabId ~= index then
        self.curTab:SetSelect(false)
        self.curTab.canBeEmpty = false
      end
      chooseTab:SetSelect(true)
      self.curTab = chooseTab
    end
    if self.ui.mAnimator then
      self.ui.mAnimator:SetTrigger("GrpPhonebook_Tab_Refresh")
    end
    self.ui.mTrans_ListContent:GetComponent(typeof(CS.ScrollFade)).enabled = false
    self.ui.mTrans_ListContent:GetComponent(typeof(CS.ScrollFade)).enabled = true
    self:UpdatePanelList(chooseTab)
    self:RenderTitle()
  end
end
function UICommunicationFriendSubPanel:UpdatePanelList(chooseTab)
  local index = chooseTab.tabId
  if index == UIFriendGlobal.ListTab.FriendList then
    NetCmdFriendData:SendRefreshFriends(function(ret)
      self:OnFriendListCallBack(ret)
    end)
  elseif index == UIFriendGlobal.ListTab.ApplyList then
    if chooseTab.isFirstClick then
      self:OnFriendListCallBack(ErrorCodeSuc)
    else
      self:InitFriendList(NetCmdFriendData:GetApplyList())
    end
  elseif index == UIFriendGlobal.ListTab.AddList then
    if chooseTab.isFirstClick then
      self.ui.mBtn_Refresh.interactable = false
      self.cdTimer = TimerSys:DelayCall(6, function()
        self.ui.mBtn_Refresh.interactable = true
        self.cdTimer:Stop()
        self.cdTimer = nil
        self.ui.mVirtualList.gameObject:GetComponent(typeof(CS.UnityEngine.CanvasGroup)).blocksRaycasts = true
      end)
      NetCmdFriendData:SendSocialFriendRecommend(function(ret)
        self:OnFriendListCallBack(ret)
      end)
    else
      self:InitFriendList(NetCmdFriendData:GetRecommendList())
    end
  elseif index == UIFriendGlobal.ListTab.BlackList then
    if chooseTab.isFirstClick then
      NetCmdFriendData:SendGetFriendBlackList(function(ret)
        self:OnFriendListCallBack(ret)
      end)
    else
      self:InitFriendList(NetCmdFriendData:GetBlackList())
    end
  end
  self:UpdateRedPoint()
end
function UICommunicationFriendSubPanel:OnFriendListCallBack(ret)
  if ret == ErrorCodeSuc and self.curTab ~= nil then
    self.curTab:SetIsFirstClick(false)
    local tabId = self.curTab.tabId
    local list
    if tabId == UIFriendGlobal.ListTab.FriendList then
      list = NetCmdFriendData:GetFriendList()
    elseif tabId == UIFriendGlobal.ListTab.ApplyList then
      list = NetCmdFriendData:GetApplyList()
    elseif tabId == UIFriendGlobal.ListTab.AddList then
      list = NetCmdFriendData:GetRecommendList()
    elseif tabId == UIFriendGlobal.ListTab.BlackList then
      list = NetCmdFriendData:GetBlackList()
    end
    self:InitFriendList(list)
  end
end
function UICommunicationFriendSubPanel:InitFriendList(list)
  self.curList = {}
  if list ~= nil and list.Count > 0 then
    for i = 0, list.Count - 1 do
      table.insert(self.curList, list[i])
    end
  end
  self:UpdateFriendList(self.curList)
end
function UICommunicationFriendSubPanel:RenderTitle()
  if self.curTab.tabId == UIFriendGlobal.ListTab.FriendList then
    self.mParent.ui.mText_Tittle.text = TableData.GetHintById(100010)
  elseif self.curTab.tabId == UIFriendGlobal.ListTab.ApplyList then
    self.mParent.ui.mText_Tittle.text = TableData.GetHintById(100011)
  elseif self.curTab.tabId == UIFriendGlobal.ListTab.AddList then
    self.mParent.ui.mText_Tittle.text = TableData.GetHintById(100012)
  elseif self.curTab.tabId == UIFriendGlobal.ListTab.BlackList then
    self.mParent.ui.mText_Tittle.text = TableData.GetHintById(100022)
  end
end
function UICommunicationFriendSubPanel:UpdateFriendList(list)
  self.curTab.canBeEmpty = #list <= 0
  setactive(self.ui.mTrans_GrpFriend, true)
  setactive(self.ui.mTrans_GrpFriendTittle, true)
  setactive(self.ui.mTrans_GrpSearch, self.curTab.tabId == UIFriendGlobal.ListTab.AddList)
  setactive(self.ui.mTrans_BtnRefresh, self.curTab.tabId == UIFriendGlobal.ListTab.AddList)
  setactive(self.ui.mBtn_Refuse, 0 < #list and self.curTab.tabId == UIFriendGlobal.ListTab.ApplyList)
  setactive(self.ui.mTrans_GrpRobot, false)
  if self.curTab.tabId == UIFriendGlobal.ListTab.FriendList then
    if #list == 0 then
      setactive(self.ui.mText_None, true)
      setactive(self.ui.mTrans_GrpFriendTittle, false)
      self.ui.mText_None.text = TableData.GetHintById(100002)
    else
      setactive(self.ui.mText_None, false)
    end
    self:UpdateFriendListText()
  end
  if self.curTab.tabId == UIFriendGlobal.ListTab.ApplyList then
    if #list == 0 then
      setactive(self.ui.mText_None, true)
      setactive(self.ui.mTrans_GrpFriendTittle, false)
      self.ui.mText_None.text = TableData.GetHintById(100003)
    else
      setactive(self.ui.mText_None, false)
    end
    self:UpdateApplyListText()
  end
  if self.curTab.tabId == UIFriendGlobal.ListTab.AddList then
    self.ui.mText_InputField.text = ""
    if #list == 0 then
      setactive(self.ui.mText_None, true)
      setactive(self.ui.mTrans_GrpFriendTittle, true)
      self.ui.mText_None.text = TableData.GetHintById(100039)
    else
      setactive(self.ui.mText_None, false)
    end
    self.ui.mText_ListTittle.text = TableData.GetHintById(100012)
  end
  if self.curTab.tabId == UIFriendGlobal.ListTab.BlackList then
    if #list == 0 then
      setactive(self.ui.mText_None, true)
      setactive(self.ui.mTrans_GrpFriendTittle, false)
      self.ui.mText_None.text = TableData.GetHintById(100212)
    else
      setactive(self.ui.mText_None, false)
    end
    self:UpdateBlackListText()
  end
  function self.ui.mVirtualList.itemProvider()
    local item = self:FriendItemProvider()
    return item
  end
  function self.ui.mVirtualList.itemRenderer(index, renderDataItem)
    self:FriendItemRenderer(index, renderDataItem)
  end
  self.ui.mVirtualList.numItems = #list
  self.ui.mVirtualList:Refresh()
end
function UICommunicationFriendSubPanel:InitRobotFriendItem(value)
  if value then
    setactive(self.ui.mTrans_GrpRobotTittle, true)
    setactive(self.ui.mTrans_GrpRobot, true)
    if self.robotItem == nil then
      self.robotItem = UIRobotFriendItem.New()
      self.robotItem:InitCtrl(self.ui.mTrans_GrpRobot, self)
      local robotData = TableData.listAiInfoDatas:GetDataById(1)
      if robotData ~= nil then
        self.robotItem:SetData(robotData)
      else
      end
    end
  else
    setactive(self.ui.mTrans_GrpRobot, false)
    setactive(self.ui.mTrans_GrpRobotTittle, false)
  end
end
function UICommunicationFriendSubPanel:FriendItemProvider()
  local template = self.ui.mScrollItem_Content.childItem
  local go = instantiate(template, self.ui.mTrans_ListContent)
  local itemView = UIFriendListItem.New()
  itemView:InitCtrl(self, go)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView.mUIRoot.gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UICommunicationFriendSubPanel:FriendItemRenderer(index, renderDataItem)
  local itemData = self.curList[index + 1]
  local item = renderDataItem.data
  item:SetData(itemData, self.curTab.tabId)
end
function UICommunicationFriendSubPanel:OnGetApproveResult(msg)
  local result = msg.Content
  local hint
  if result == 0 then
    hint = 100042
    UIUtils.PopupPositiveHintMessage(hint)
  elseif result == 1 then
    hint = 100043
    UIUtils.PopupPositiveHintMessage(hint)
  elseif result == 2 then
    hint = 100044
    UIUtils.PopupHintMessage(hint)
  elseif result == 3 then
    hint = 100045
    UIUtils.PopupHintMessage(hint)
  else
    hint = 60022
    UIUtils.PopupHintMessage(hint)
  end
end
function UICommunicationFriendSubPanel:RefreshChangeMark(msg)
  local item = self:GetFriendData(tonumber(msg.Sender))
  if item then
    self.ui.mVirtualList:RefreshItem(item.index)
  end
end
function UICommunicationFriendSubPanel:GetFriendData(uid)
  if uid == nil then
    return nil
  end
  for i, data in ipairs(self.curList) do
    if data.UID == uid then
      return data
    end
  end
  return nil
end
