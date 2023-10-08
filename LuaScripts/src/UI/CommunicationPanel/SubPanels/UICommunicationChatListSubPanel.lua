require("UI.CommunicationPanel.Items.UIRobotChatInfoItem")
require("UI.CommunicationPanel.Items.UIChatInfoItem")
UICommunicationChatListSubPanel = class("UICommunicationChatListSubPanel", UIBaseView)
UICommunicationChatListSubPanel.__index = UICommunicationChatListSubPanel
UICommunicationChatListSubPanel.curMessageLoopScroll = nil
UICommunicationChatListSubPanel.curChatList = {}
UICommunicationChatListSubPanel.chatMessageItemList = {}
UICommunicationChatListSubPanel.canSwitch = true
UICommunicationChatListSubPanel.RedPointType = {
  RedPointConst.TeamChat
}
UICommunicationChatListSubPanel.SUB_PANEL_ID = {
  FRIEND = 1,
  TEAM = 2,
  SYSTEM = 3
}
function UICommunicationChatListSubPanel:__InitCtrl()
end
function UICommunicationChatListSubPanel:InitCtrl(root, parent)
  self:SetRoot(root)
  self.ui = {}
  self.curChatList = {}
  self:LuaUIBindTable(root, self.ui)
  self:__InitCtrl()
  self.mParent = parent
  self:EnterSubPanel(self.SUB_PANEL_ID.FRIEND)
  self.chatFriendInfoList = {}
  self:RefreshFriendInfoList()
  self:InitButtonGroup()
  function self.deleteChatChannelFunc(msg)
    self:DeleteChatChannel(msg)
  end
  function self.addChatChannelFunc(msg)
    self:AddChatChannel(msg)
  end
  function self.refreshMarkFunc(msg)
    self:RefreshChangeMark(msg)
  end
  function self.updateRedPointFunc(msg)
    self:UpdateChatRedPoint(msg)
  end
  function self.refreshFriendInfoFunc(msg)
    self:RefreshFriendInfoItem(msg)
  end
  function self.refreshRobotInfoFunc(msg)
    self:RefreshRobotInfoItem(msg)
  end
  function self.refreshBPChatFunc(msg)
    self:RefreshBPChatItem(msg)
  end
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.TeamChat, self.ui.mTrans_TeamRedPoint)
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.FriendDel, self.deleteChatChannelFunc)
  MessageSys:AddListener(CS.GF2.Message.ChatEvent.AddChatChannel, self.addChatChannelFunc)
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.FriendChangeMark, self.refreshMarkFunc)
  MessageSys:AddListener(CS.GF2.Message.ChatEvent.UpdateChatRedPoint, self.updateRedPointFunc)
  MessageSys:AddListener(CS.GF2.Message.ChatEvent.UpdateChatList, self.refreshFriendInfoFunc)
  MessageSys:AddListener(CS.GF2.Message.ChatEvent.UpdateRobotChat, self.refreshRobotInfoFunc)
  MessageSys:AddListener(CS.GF2.Message.ChatEvent.UpdateBPChat, self.refreshBPChatFunc)
end
function UICommunicationChatListSubPanel:OnClose()
end
function UICommunicationChatListSubPanel:OnRelease()
  self.chatFriendInfoList = {}
  self.curChatList = {}
  if self.robotItem ~= nil then
    gfdestroy(self.robotItem:GetRoot())
    self.robotItem = nil
  end
  if self.chatMessageItemList ~= nil then
    for k, item in pairs(self.chatMessageItemList) do
      item:ReleaseTimer()
    end
    self.chatMessageItemList = {}
  end
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.TeamChat)
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.FriendDel, self.deleteChatChannelFunc)
  MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.AddChatChannel, self.addChatChannelFunc)
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.FriendChangeMark, self.refreshMarkFunc)
  MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateChatRedPoint, self.updateRedPointFunc)
  MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateChatList, self.refreshFriendInfoFunc)
  MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateRobotChat, self.refreshRobotInfoFunc)
  MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateBPChat, self.refreshBPChatFunc)
  self.canSwitch = true
  self.curMessageLoopScroll = nil
  self.deleteChatChannelFunc = nil
  self.addChatChannelFunc = nil
  self.refreshMarkFunc = nil
  self.updateRedPointFunc = nil
  self.refreshFriendInfoFunc = nil
  self.refreshRobotInfoFunc = nil
end
function UICommunicationChatListSubPanel:InitButtonGroup()
  UIUtils.GetButtonListener(self.ui.mBtn_Friend.gameObject).onClick = function()
    if self.canSwitch then
      self.canSwitch = false
      self:EnterSubPanel(self.SUB_PANEL_ID.FRIEND)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Team.gameObject).onClick = function()
    if self.canSwitch then
      self.canSwitch = false
      NetCmdChatData:ReadTeamAllMessage()
      self:EnterSubPanel(self.SUB_PANEL_ID.TEAM)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_System.gameObject).onClick = function()
    if self.canSwitch then
      self.canSwitch = false
      self:EnterSubPanel(self.SUB_PANEL_ID.SYSTEM)
    end
  end
end
function UICommunicationChatListSubPanel:ReturnClicked()
  self:EnterSubPanel(self.SUB_PANEL_ID.FRIEND)
  self.mParent:EnterSubPanel(0)
end
function UICommunicationChatListSubPanel:EnterSubPanel(index)
  if self.mindex and self.mindex == index then
    return
  end
  self.mParent:AnimatorSetTrigger("GrpMessage_0_Tab_FadeIn")
  local preIndex = self.mindex
  self.mindex = index
  setactive(self.ui.mTrans_NoMessage, false)
  setactive(self.ui.mTrans_GrpFriend.gameObject, index == self.SUB_PANEL_ID.FRIEND)
  setactive(self.ui.mTrans_GrpTeam.gameObject, index == self.SUB_PANEL_ID.TEAM)
  self.ui.mBtn_Friend.interactable = index ~= self.SUB_PANEL_ID.FRIEND
  self.ui.mBtn_Team.interactable = index ~= self.SUB_PANEL_ID.TEAM
  self.ui.mBtn_System.interactable = index ~= self.SUB_PANEL_ID.SYSTEM
  TimerSys:DelayCall(0.5, function()
    self.canSwitch = true
  end)
  if index == self.SUB_PANEL_ID.TEAM then
    self:InitTeamMessageContent()
    self:UpdateMessageContent(true)
    setactive(self.ui.mTrans_NoMessage, self.curChatList.messageList.Count == 0)
  elseif index == self.SUB_PANEL_ID.FRIEND then
    self:RefreshNoMessage()
  end
  local scrollFade = self.ui.mTrans_ListContent:GetComponent(typeof(CS.ScrollFade))
  if scrollFade ~= nil then
    scrollFade:SetOnEnableScrollFade(true)
    scrollFade.enabled = false
    scrollFade.enabled = true
  end
  setactive(self.ui.mTrans_TeamRedPoint.gameObject, 0 < NetCmdChatData:UpdateTeamChatRedPoint())
end
function UICommunicationChatListSubPanel:RefreshNoMessage()
  local noMessage = true
  if self.chatFriendInfoList ~= nil and #self.chatFriendInfoList > 0 then
    noMessage = false
  end
  local robotChatData = NetCmdChatData:GetRobotChatDataById(1)
  if robotChatData and robotChatData.robotMessageList.Count ~= 0 then
    noMessage = false
  end
  self.ui.mBtn_Friend.interactable = self.mindex ~= self.SUB_PANEL_ID.FRIEND
  self.ui.mBtn_Team.interactable = self.mindex ~= self.SUB_PANEL_ID.TEAM
  self.ui.mBtn_System.interactable = self.mindex ~= self.SUB_PANEL_ID.SYSTEM
  setactive(self.ui.mTrans_NoMessage, noMessage)
end
function UICommunicationChatListSubPanel:UpdateChatMessageItemCallback(srcObj, index)
  self.chatMessageItemList = self.chatMessageItemList or {}
  local data
  if self.mindex == self.SUB_PANEL_ID.TEAM then
    data = self.curChatList.messageList[index]
  elseif self.mindex == self.SUB_PANEL_ID.SYSTEM then
  end
  if data then
    local instanceId = srcObj:GetInstanceID()
    local item = self.chatMessageItemList[instanceId]
    if not item then
      item = self:CreateBubbleItem(srcObj)
      self.chatMessageItemList[instanceId] = item
    end
    local userData = data.user
    item:SetData(userData, data, UICommunicationGlobal.ChatType.Team, index)
  end
end
function UICommunicationChatListSubPanel:CreateBubbleItem(srcObj)
  if srcObj then
    local item = UIChatMessageItem.New()
    item:InitCtrl(srcObj)
    return item
  end
  return nil
end
function UICommunicationChatListSubPanel:UpdateMessageContent(needToEnd)
  if self.curMessageLoopScroll then
    self.curMessageLoopScroll.inertia = false
    local messageCount = 0
    if self.mindex == self.SUB_PANEL_ID.TEAM then
      messageCount = self.curChatList.messageList.Count
    elseif self.mindex == self.SUB_PANEL_ID.SYSTEM then
    end
    self.curMessageLoopScroll.totalCount = messageCount
    local scrollToEnd = messageCount - 1 == self.curMessageLoopScroll.GetItemTypeEnd
    if needToEnd ~= nil and needToEnd == false then
      if scrollToEnd or self.isSelfSend then
        self.isSelfSend = false
        self.curMessageLoopScroll:RefillCellsFromEnd()
        TimerSys:DelayFrameCall(1, function()
          if self.curMessageLoopScroll ~= nil then
            self.curMessageLoopScroll.verticalNormalizedPosition = 1
            self.curMessageLoopScroll.inertia = true
          end
        end)
      else
        self.curMessageLoopScroll.verticalNormalizedPosition = 1
        self.curMessageLoopScroll.inertia = true
      end
    else
      self.curMessageLoopScroll:RefillCellsFromEnd()
      TimerSys:DelayFrameCall(1, function()
        if self.curMessageLoopScroll ~= nil then
          self.curMessageLoopScroll.velocity = vector2zero
          if self.isLastEmoji then
            self.curMessageLoopScroll.verticalNormalizedPosition = 1
          else
            self.curMessageLoopScroll.verticalNormalizedPosition = 0.995
          end
        end
      end)
      TimerSys:DelayFrameCall(5, function()
        if self.curMessageLoopScroll ~= nil then
          self.curMessageLoopScroll.velocity = vector2zero
          self.curMessageLoopScroll.verticalNormalizedPosition = 1
          self.curMessageLoopScroll.inertia = true
        end
      end)
    end
  end
end
function UICommunicationChatListSubPanel:InitTeamMessageContent()
  self.curChatList = NetCmdChatData:GetTeamChat()
  self.curMessageLoopScroll = self.ui.mLoopScroll_TeamContent
  self.curMessageLoopScroll:ClearCells()
  function self.curMessageLoopScroll.itemUpdateCallback(srcObj, index)
    self:UpdateChatMessageItemCallback(srcObj, index)
  end
end
function UICommunicationChatListSubPanel:GetFriendData(uid)
  if uid == nil then
    return nil
  end
  for i, data in ipairs(self.chatFriendInfoList) do
    if data.UID == uid then
      return data
    end
  end
  return nil
end
function UICommunicationChatListSubPanel:SetMessageData()
end
function UICommunicationChatListSubPanel:InitRobotInfoItem()
  self.allMessageCount = #self.chatFriendInfoList or 0
  if self.robotItem == nil then
  end
  self:RefreshNoMessage()
end
function UICommunicationChatListSubPanel:RefreshChangeMark(msg)
  self:RefreshFriendInfoList()
end
function UICommunicationChatListSubPanel:RefreshFriendInfoList()
  self:InitInfoList()
  self:UpdateFriendInfoList()
end
function UICommunicationChatListSubPanel:InitInfoList()
  self.chatFriendInfoList = {}
  local list = NetCmdChatData:GetHaveChatFriend()
  if list ~= nil and list.Count > 0 then
    for i = 0, list.Count - 1 do
      table.insert(self.chatFriendInfoList, list[i])
    end
  end
  function self.ui.mVirtualList.itemProvider()
    local item = self:ChatInfoItemProvider()
    return item
  end
  function self.ui.mVirtualList.itemRenderer(index, renderDataItem)
    self:ChatInfoItemRenderer(index, renderDataItem)
  end
end
function UICommunicationChatListSubPanel:UpdateFriendInfoList()
  table.sort(self.chatFriendInfoList, function(a, b)
    if NetCmdChatData:NeedShowRedPoint(a.UID) and not NetCmdChatData:NeedShowRedPoint(b.UID) then
      return true
    elseif NetCmdChatData:NeedShowRedPoint(b.UID) and not NetCmdChatData:NeedShowRedPoint(a.UID) then
      return false
    end
    local timeA = 0
    local timeB = 0
    local chatDataA = NetCmdChatData:GetChatDataById(a.UID)
    local chatDataB = NetCmdChatData:GetChatDataById(b.UID)
    if chatDataA ~= nil then
      timeA = chatDataA.messageList[chatDataA.messageList.Count - 1].time
    end
    if chatDataB ~= nil then
      timeB = chatDataB.messageList[chatDataB.messageList.Count - 1].time
    end
    return timeA > timeB
  end)
  self.ui.mVirtualList.numItems = #self.chatFriendInfoList
  self.ui.mVirtualList:Refresh()
  self:InitRobotInfoItem()
end
function UICommunicationChatListSubPanel:ChatInfoItemProvider()
  local itemView = UIChatInfoItem.New()
  itemView:InitCtrl(self, self.ui.mTrans_ListContent)
  local renderDataItem = CS.RenderDataItem()
  renderDataItem.renderItem = itemView.mUIRoot.gameObject
  renderDataItem.data = itemView
  if self.robotItem ~= nil then
    self.robotItem:GetRoot():SetAsFirstSibling()
  end
  return renderDataItem
end
function UICommunicationChatListSubPanel:ChatInfoItemRenderer(index, renderDataItem)
  local itemData = self.chatFriendInfoList[index + 1]
  local item = renderDataItem.data
  item:SetData(itemData)
end
function UICommunicationChatListSubPanel:DeleteChatChannel(msg)
  local uid = tonumber(msg.Sender)
  if uid == self.uid then
    UIUtils.PopupHintMessage(100048)
  end
  for i, v in ipairs(self.chatFriendInfoList) do
    if v.UID == uid then
      NetCmdChatData:RemoveChatFriend(uid)
      break
    end
  end
  self:RefreshFriendInfoList()
end
function UICommunicationChatListSubPanel:AddChatChannel(msg)
  local uid = tonumber(msg.Sender)
  self:RefreshFriendInfoList()
end
function UICommunicationChatListSubPanel:UpdateChatRedPoint(msg)
  self:UpdateFriendRedPoint(tonumber(msg.Sender))
end
function UICommunicationChatListSubPanel:UpdateFriendRedPoint(uid)
  local item = self:GetFriendData(uid)
  if item then
    self.ui.mVirtualList:RefreshItem(item.index)
  end
end
function UICommunicationChatListSubPanel:RefreshFriendInfoItem(msg)
  self.chatFriendInfoList = {}
  local list = NetCmdChatData:GetHaveChatFriend()
  if list ~= nil and list.Count > 0 then
    for i = 0, list.Count - 1 do
      table.insert(self.chatFriendInfoList, list[i])
    end
  end
  self:UpdateFriendInfoList()
end
function UICommunicationChatListSubPanel:RefreshBPChatItem(msg, needToEnd)
  if self.mindex == self.SUB_PANEL_ID.TEAM then
    self:InitTeamMessageContent()
    self:UpdateMessageContent(needToEnd or true)
    setactive(self.ui.mTrans_NoMessage, false)
    NetCmdChatData:ReadTeamAllMessage()
    MessageSys:SendMessage(CS.GF2.Message.RedPointEvent.RedPointUpdate, "Chat")
  end
end
function UICommunicationChatListSubPanel:UpdateChatList()
  if self.mindex == self.SUB_PANEL_ID.TEAM then
    self.curChatList = NetCmdChatData:GetTeamChat()
    local index = 0
    for _, item in pairs(self.chatMessageItemList) do
      if self.ui.mTrans_GrpTeam:Find("Viewport/Content/" .. item:GetRoot().gameObject.name) ~= nil then
        local data = self.curChatList.messageList[item.teamIndex]
        if data then
          local userData = data.user
          item:SetData(userData, data, UICommunicationGlobal.ChatType.Team)
        end
      end
    end
  end
end
function UICommunicationChatListSubPanel:RefreshRobotInfoItem(msg)
  if self.robotItem ~= nil then
    local robotData = TableData.listAiInfoDatas:GetDataById(1)
    local robotChatData = NetCmdChatData:GetRobotChatDataById(1)
    self.robotItem:SetData(robotData, robotChatData)
  end
end
function UICommunicationChatListSubPanel:DeactiveRobotRedPoint()
  if self.robotItem ~= nil then
    self.robotItem:SetRedPoint(false)
  end
end
