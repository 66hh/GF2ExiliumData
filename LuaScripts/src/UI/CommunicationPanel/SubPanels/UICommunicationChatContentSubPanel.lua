require("UI.CommunicationPanel.Items.UIRobotReplyItem")
require("UI.CommunicationPanel.Items.UIChatMessageItem")
require("UI.CommunicationPanel.Items.UIChatEmojiItem")
require("UI.CommunicationPanel.GlobalData.UICommunicationGlobal")
UICommunicationChatContentSubPanel = class("UICommunicationChatContentSubPanel", UIBaseView)
UICommunicationChatContentSubPanel.__index = UICommunicationChatContentSubPanel
UICommunicationChatContentSubPanel.RedPointType = {
  RedPointConst.Chat
}
UICommunicationChatContentSubPanel.uid = nil
UICommunicationChatContentSubPanel.curChatData = nil
UICommunicationChatContentSubPanel.curMessageLoopScroll = nil
UICommunicationChatContentSubPanel.chatItemList = nil
UICommunicationChatContentSubPanel.isShowEmoji = false
UICommunicationChatContentSubPanel.emojiList = {}
UICommunicationChatContentSubPanel.cacheInput = {}
UICommunicationChatContentSubPanel.isShowRobotContent = false
UICommunicationChatContentSubPanel.robotReplyItemList = {}
UICommunicationChatContentSubPanel.curRobotChatContentId = 0
UICommunicationChatContentSubPanel.curRobotChatType = nil
UICommunicationChatContentSubPanel.curReplyId = 0
UICommunicationChatContentSubPanel.groupId = 0
UICommunicationChatContentSubPanel.robotChatKind = 0
UICommunicationChatContentSubPanel.needRefreshAni = false
UICommunicationChatContentSubPanel.isSelfSend = false
UICommunicationChatContentSubPanel.isLastEmoji = false
UICommunicationChatContentSubPanel.preIndex = 0
function UICommunicationChatContentSubPanel:__InitCtrl()
end
function UICommunicationChatContentSubPanel:InitCtrl(root, parent, data, type)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
  self.mParent = parent
  self.mindex = 3
  self.curChatData = nil
  self.chatMessageList = {}
  self.emojiList = {}
  self.chatType = type
  self.curFriendData = data
  self.curRobotChatContentId = 0
  self.curRobotChatType = nil
  self.curReplyId = 0
  self.groupId = 0
  self.needRefreshAni = false
  self.isLastEmoji = false
  if self.chatType == UICommunicationGlobal.ChatType.Friend then
    function self.updateMessageFunc(msg)
      self:UpdateMessageList(msg)
    end
    MessageSys:AddListener(CS.GF2.Message.ChatEvent.UpdateChatList, self.updateMessageFunc)
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    function self.updateRobotChatFunc(msg)
      self:UpdateRobotMessageList(msg)
    end
    MessageSys:AddListener(CS.GF2.Message.ChatEvent.UpdateRobotChat, self.updateRobotChatFunc)
  end
  function self.refreshInfoFunc(msg)
    self:RefreshRoleInfo(msg)
  end
  self:SetPanelType()
  self:InitMessageContent()
  self:UpdateContent()
end
function UICommunicationChatContentSubPanel:OnClose()
end
function UICommunicationChatContentSubPanel:OnRelease()
  self:OnCloseRobot()
  self:OnCloseEmoji()
  self.emojiList = {}
  self.chatItemList = nil
  self.curChatData = nil
  self.curMessageLoopScroll = nil
  self.cacheInput = {}
  self.curRobotChatContentId = 0
  self.curRobotChatType = nil
  self.curReplyId = 0
  self.groupId = 0
  if self.chatMessageItemList ~= nil then
    for k, item in pairs(self.chatMessageItemList) do
      item:ReleaseTimer()
    end
    self.chatMessageItemList = {}
  end
  for i, v in pairs(self.robotReplyItemList) do
    gfdestroy(v:GetRoot())
  end
  self.robotReplyItemList = {}
  self.needRefreshAni = false
  self.isLastEmoji = false
  self.isSelfSend = false
  if self.mParent ~= nil and self.mParent.mindex == self.mindex then
    self.mParent.mParent:UnRegistrationAllKeyboard()
  end
  if self.chatType == UICommunicationGlobal.ChatType.Friend and self.updateMessageFunc ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateChatList, self.updateMessageFunc)
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot and self.updateRobotChatFunc ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateRobotChat, self.updateRobotChatFunc)
    NetCmdChatData:SetRobotChatRead(1)
    self.mParent.mParent.mChatListSubPanel:DeactiveRobotRedPoint()
  end
  if self.refreshInfoFunc ~= nil then
  end
  self.updateMessageFunc = nil
  self.updateRobotChatFunc = nil
  self.refreshInfoFunc = nil
end
function UICommunicationChatContentSubPanel:SetPanelType()
  setactive(self.ui.mTrans_InputField.gameObject, self.chatType == UICommunicationGlobal.ChatType.Friend)
  setactive(self.ui.mTrans_InputBox.gameObject, self.chatType == UICommunicationGlobal.ChatType.Robot)
  if self.chatType == UICommunicationGlobal.ChatType.Friend then
    UIUtils.GetButtonListener(self.ui.mBtn_Bg.gameObject).onClick = function()
      self:OnCloseEmoji()
    end
    UIUtils.GetButtonListener(self.ui.mBtn_Emoji.gameObject).onClick = function()
      self:OnClickEmojiList()
    end
    UIUtils.GetButtonListener(self.ui.mBtn_Send.gameObject).onClick = function()
      self:SendFriendMessage()
    end
    self.ui.mInput_Message.characterLimit = TableData.GlobalSystemData.ChatMessageLimit
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    UIUtils.GetButtonListener(self.ui.mBtn_Bg.gameObject).onClick = function()
      self:OnClickInputBox()
    end
    UIUtils.GetButtonListener(self.ui.mBtn_Send.gameObject).onClick = function()
      self:SendRobotMessage()
    end
    UIUtils.GetButtonListener(self.ui.mBtn_InputBox.gameObject).onClick = function()
      self:OnClickInputBox()
    end
    self.ui.mLayoutElement_Auto.minHeight = 0
    self.ui.mText_InputBox.text = ""
    self.ui.mInput_Message.characterLimit = TableData.GlobalSystemData.ChatMessageLimit
  end
end
function UICommunicationChatContentSubPanel:OnClickInputBox()
  setactive(self.ui.mBtn_Bg.gameObject, not self.isShowRobotContent)
  if self.isShowRobotContent then
    local stack = 0
    local oriHeight = self.ui.mLayoutElement_Auto.minHeight
    TimerSys:DelayCall(0.01, function()
      stack = stack + 1
      if stack <= 4 then
        if self.ui.mCanvasGroup_Auto then
          self.ui.mCanvasGroup_Auto.alpha = 1 - stack * 0.25
        end
        if stack == 4 then
          for i = 1, #self.robotReplyItemList do
            gfdestroy(self.robotReplyItemList[i]:GetRoot())
          end
          self.robotReplyItemList = {}
          setactive(self.ui.mTrans_GrpRobot.gameObject, false)
          self.isShowRobotContent = false
        end
      elseif self.ui.mLayoutElement_Auto ~= nil then
        self.ui.mLayoutElement_Auto.minHeight = oriHeight - (stack - 4) * (oriHeight / 4)
      end
    end, nil, 8)
  else
    self.curChatData = NetCmdChatData:GetRobotChatDataById(self.curFriendData.id)
    local replyList = {}
    if self.curChatData ~= nil then
      for key, value in pairs(self.curChatData.ReceivedDic) do
        if value == false then
          local aiChatData = TableData.listAiChatDatas:GetDataById(key)
          local aiChatPushGroupData = TableData.listAiChatPushGroupDatas:GetDataById(aiChatData.content_group)
          if 0 < aiChatPushGroupData.player_chat.Count and aiChatPushGroupData.player_chat[0] ~= 0 then
            table.insert(replyList, key)
          end
        end
      end
    end
    local replyCount = 0
    if 0 < #replyList then
      setactive(self.ui.mTrans_GrpRobot.gameObject, not self.isShowRobotContent)
      local aiChatData = TableData.listAiChatDatas:GetDataById(replyList[1])
      local aiChatPushGroupData = TableData.listAiChatPushGroupDatas:GetDataById(aiChatData.content_group)
      for i = 0, aiChatPushGroupData.player_chat.Count - 1 do
        do
          local aiChatContentData = TableData.listAiChatContentDatas:GetDataById(aiChatPushGroupData.player_chat[i])
          local contentId = aiChatPushGroupData.player_chat[i]
          local replyId = aiChatPushGroupData.ai_chat_start
          local groupId = replyList[1]
          local text = aiChatContentData.content
          replyCount = replyCount + 1
          local robotReplyItem = UIRobotReplyItem.New()
          robotReplyItem:InitCtrl(self.ui.mTrans_GrpRobot, false)
          table.insert(self.robotReplyItemList, robotReplyItem)
          robotReplyItem:SetData(text, contentId, replyId, groupId)
          UIUtils.GetButtonListener(robotReplyItem:GetRoot()).onClick = function()
            self.robotChatKind = CS.ProtoCsmsg.RobotChatKind.Special
            self:OnClickRobotReplyItem(text, contentId, replyId, groupId)
          end
        end
      end
    else
      setactive(self.ui.mTrans_GrpRobot.gameObject, self.isShowRobotContent)
      do
        local selfThemeDataList = TableData.listAiChatSelfThemeByCharacterDatas:GetDataById(self.curFriendData.id)
        for i = 1, selfThemeDataList.Id.Count do
          do
            local selfThemeData = TableData.listAiChatSelfThemeDatas:GetDataById(selfThemeDataList.Id[i - 1])
            local aiChatContentData = TableData.listAiChatContentDatas:GetDataById(selfThemeData.self_theme)
            local contentId = selfThemeData.self_theme
            local groupId = selfThemeData.id
            local text = aiChatContentData.content
            replyCount = replyCount + 1
            local robotReplyItem = UIRobotReplyItem.New()
            robotReplyItem:InitCtrl(self.ui.mTrans_Automatic, true)
            table.insert(self.robotReplyItemList, robotReplyItem)
            robotReplyItem:SetData(text, contentId, 0, groupId)
            setactive(robotReplyItem:GetRoot(), false)
            UIUtils.GetButtonListener(robotReplyItem:GetRoot()).onClick = function()
              self.robotChatKind = CS.ProtoCsmsg.RobotChatKind.Common
              self:OnClickRobotReplyItem(text, contentId, 0, groupId)
            end
          end
        end
        self.curMessageLoopScroll.inertia = false
        local stack = 0
        self.ui.mCanvasGroup_Auto.alpha = 1
        local shrinkContent = self.ui.mTrans_ListContent.sizeDelta.y > self.ui.mTrans_ListContent.parent.sizeDelta.y
        TimerSys:DelayCall(0.01, function()
          stack = stack + 1
          if stack <= 4 then
            if self.ui.mLayoutElement_Auto ~= nil then
              self.ui.mLayoutElement_Auto.minHeight = 58 * replyCount / 4 * stack
            end
            if self.ui.mTrans_ListContent ~= nil and shrinkContent then
              self.ui.mTrans_ListContent.localPosition = Vector3(self.ui.mTrans_ListContent.localPosition.x, self.ui.mTrans_ListContent.localPosition.y + 58 * replyCount / 4, self.ui.mTrans_ListContent.localPosition.z)
            end
            if stack == 4 then
              for _, robotReplyItem in pairs(self.robotReplyItemList) do
                setactive(robotReplyItem:GetRoot(), true)
              end
            end
          elseif self.ui.mCanvasGroup_Auto then
            self.ui.mCanvasGroup_Auto.alpha = 0 + (stack - 4) * 0.25
          end
        end, nil, 8)
        TimerSys:DelayCall(0.3, function()
          if self.curMessageLoopScroll ~= nil then
            self.curMessageLoopScroll.inertia = true
          end
        end)
      end
    end
  end
  self.isShowRobotContent = not self.isShowRobotContent
end
function UICommunicationChatContentSubPanel:OnClickRobotReplyItem(text, contentId, replyId, groupId)
  self.ui.mText_InputBox.text = text
  self.curRobotChatContentId = contentId
  self.curReplyId = replyId
  self.groupId = groupId
end
function UICommunicationChatContentSubPanel:SetQuoteActive(isClose)
  if isClose == true and self.isShowRobotContent then
    local stack = 0
    local oriHeight = self.ui.mLayoutElement_Auto.minHeight
    TimerSys:DelayCall(0.01, function()
      stack = stack + 1
      if stack <= 2 then
        if self.ui.mCanvasGroup_Auto then
          self.ui.mCanvasGroup_Auto.alpha = 1 - stack * 0.5
        end
        if stack == 2 then
          for i = 1, #self.robotReplyItemList do
            gfdestroy(self.robotReplyItemList[i]:GetRoot())
          end
          self.robotReplyItemList = {}
          setactive(self.ui.mTrans_GrpRobot.gameObject, false)
          self.isShowRobotContent = false
        end
      elseif self.ui.mLayoutElement_Auto ~= nil then
        self.ui.mLayoutElement_Auto.minHeight = oriHeight - (stack - 2) * (oriHeight / 4)
      end
    end, nil, 6)
  end
end
function UICommunicationChatContentSubPanel:UpdateRobotContent()
end
function UICommunicationChatContentSubPanel:SendRobotMessage()
  local text = self.ui.mText_InputBox.text
  if text == nil or text == "" or self.groupId == 0 then
    UIUtils.PopupHintMessage(100109)
    return
  end
  self.isSelfSend = true
  self.isLastEmoji = false
  if self.curMessageLoopScroll then
    self.curMessageLoopScroll.velocity = vector2zero
    self.curMessageLoopScroll.verticalNormalizedPosition = 1
  end
  NetCmdChatData:SendRobotChatMessageData(self.groupId, 0, self.curRobotChatContentId, self.curReplyId, self.robotChatKind, false, function()
    setactive(self.ui.mBtn_Bg.gameObject, false)
    self.ui.mText_InputBox.text = ""
    self:SetQuoteActive(true)
  end)
end
function UICommunicationChatContentSubPanel:SendFriendMessage()
  if self.curChatData.lastSpeakTime > 0 then
    UIUtils.PopupHintMessage(100108)
    return
  end
  local text = self.ui.mInput_Message.text
  if text == nil or text == "" then
    UIUtils.PopupHintMessage(100109)
    return
  end
  if not NetCmdChatData:StringCanSend(text) then
    UIUtils.PopupHintMessage(60076)
    return
  end
  self.isSelfSend = true
  self.isLastEmoji = false
  if self.curMessageLoopScroll then
    self.curMessageLoopScroll.velocity = vector2zero
    self.curMessageLoopScroll.verticalNormalizedPosition = 1
  end
  if not NetCmdFriendData:IsFriend(self.curFriendData.UID) then
    self.ui.mInput_Message.text = ""
    NetCmdChatData:AddCachedMessage(self.curFriendData.UID, 0, text)
    self.curChatData = NetCmdChatData:GetCachedChatDataById(self.curFriendData.UID)
    if self.curChatData then
      self:UpdateMessageContent(true)
    end
    return
  end
  NetCmdChatData:SendChat(self.curFriendData.UID, 0, text, function()
    self.ui.mInput_Message.text = ""
  end)
end
function UICommunicationChatContentSubPanel:InitMessageContent()
  self.curMessageLoopScroll = self.ui.mLoopScroll_MessageContent
  self.curMessageLoopScroll:ClearCells()
  function self.curMessageLoopScroll.itemUpdateCallback(srcObj, index)
    self:UpdateChatMessageItemCallback(srcObj, index)
  end
end
function UICommunicationChatContentSubPanel:UpdateChatMessageItemCallback(srcObj, index)
  self.chatMessageItemList = self.chatMessageItemList or {}
  local data
  if self.chatType == UICommunicationGlobal.ChatType.Friend then
    data = self.curChatData.messageList[index]
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    data = self.curChatData.robotMessageList[index]
  end
  if data then
    local instanceId = srcObj:GetInstanceID()
    local item = self.chatMessageItemList[instanceId]
    if not item then
      item = self:CreateBubbleItem(srcObj)
      self.chatMessageItemList[instanceId] = item
    end
    local userData
    if self.chatType == UICommunicationGlobal.ChatType.Friend or self.chatType == UICommunicationGlobal.ChatType.Team then
      userData = data.active and AccountNetCmdHandler:GetRoleInfoData() or self.curFriendData
    elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
      userData = data.speaker and AccountNetCmdHandler:GetRoleInfoData() or self.curFriendData
    end
    item:SetData(userData, data, self.chatType)
    local Count
    if self.chatType == UICommunicationGlobal.ChatType.Friend then
      Count = self.curChatData.messageList.Count
    elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
      Count = self.curChatData.robotMessageList.Count
    end
    if index == Count - 1 then
      self.newMessageCount = 0
      if self.needRefreshAni then
        CS.LuaUIUtils.RefreshChatBubbleAni(srcObj, 0.2)
        self.needRefreshAni = false
      end
    end
  end
end
function UICommunicationChatContentSubPanel:CreateBubbleItem(srcObj)
  if srcObj then
    local item = UIChatMessageItem.New()
    item:InitCtrl(srcObj)
    return item
  end
  return nil
end
function UICommunicationChatContentSubPanel:UpdateContent()
  self:UpdateInputMessage()
  if self.chatType == UICommunicationGlobal.ChatType.Friend then
    self:GetChatData(self.curFriendData.UID)
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    self:GetChatData(self.curFriendData.id)
  end
  self:UpdateFriendInfo()
  self.needRefreshAni = false
end
function UICommunicationChatContentSubPanel:GetChatData(uid)
  if uid == nil then
    self.curChatData = nil
    self:UpdateMessageContent(true)
    return
  end
  if self.chatType == UICommunicationGlobal.ChatType.Friend then
    if NetCmdChatData:IsRecChatDetail(uid) then
      self.curChatData = NetCmdChatData:GetChatDataById(uid)
      if self.curChatData then
        self:UpdateMessageContent(true)
        NetCmdChatData:SendChatRead(uid)
        NetCmdChatData:ReadFriendAllMessage(uid)
      end
    else
      NetCmdChatData:SendGetChatDetail(uid, function(ret)
        if ret == ErrorCodeSuc then
          self.curChatData = NetCmdChatData:GetChatDataById(uid)
          if self.curChatData then
            self:UpdateMessageContent(true)
          end
          NetCmdChatData:SendChatRead(uid)
          NetCmdChatData:ReadFriendAllMessage(uid)
        end
      end)
    end
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    if NetCmdChatData:IsRecRobotChatData(uid) then
      self.curChatData = NetCmdChatData:GetRobotChatDataById(uid)
      if self.curChatData then
        self:UpdateMessageContent(true)
      end
      NetCmdChatData:SetRobotChatRead(uid)
    else
      NetCmdChatData:SendGetRobotChats(function(ret)
        if ret == ErrorCodeSuc then
          self.curChatData = NetCmdChatData:GetRobotChatDataById(uid)
          if self.curChatData then
            self:UpdateMessageContent(true)
          end
          NetCmdChatData:SetRobotChatRead(uid)
        end
      end)
    end
  end
end
function UICommunicationChatContentSubPanel:UpdateFriendInfo()
  if self.chatType == UICommunicationGlobal.ChatType.Friend then
    if self.curFriendData.Mark == "" or self.curFriendData.Mark == nil then
      self.ui.mText_FriendName.text = self.curFriendData.Name
      self.ui.mText_FriendName.color = Color.white
    else
      self.ui.mText_FriendName.text = self.curFriendData.Mark
      self.ui.mText_FriendName.color = ColorUtils.BlueColor4
    end
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    self.ui.mText_FriendName.text = self.curFriendData.name
  end
end
function UICommunicationChatContentSubPanel:UpdateMessageContent(needToEnd)
  if self.curMessageLoopScroll then
    self.curMessageLoopScroll.inertia = false
    local messageCount = 0
    if self.curChatData then
      if self.chatType == UICommunicationGlobal.ChatType.Friend then
        messageCount = self.curChatData.messageList.Count
      elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
        messageCount = self.curChatData.robotMessageList.Count
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
            self.curMessageLoopScroll.verticalNormalizedPosition = 1
            self.curMessageLoopScroll.inertia = false
          end
        end)
        TimerSys:DelayFrameCall(5, function()
          if self.curMessageLoopScroll ~= nil then
            self.curMessageLoopScroll.inertia = true
          end
        end)
      end
    end
  end
end
function UICommunicationChatContentSubPanel:CacheInputMessage()
  local text = self.ui.mInput_Message.text
  if text == nil or text == "" then
    return
  end
  if self.curFriendData then
    self.cacheInput[self.curFriendData.UID] = text
  end
end
function UICommunicationChatContentSubPanel:UpdateInputMessage()
  self.ui.mInput_Message.text = ""
  if self.cacheInput[self.curFriendData.UID] then
    self.ui.mInput_Message.text = self.cacheInput[self.curFriendData.UID]
  end
end
function UICommunicationChatContentSubPanel:InitEmojiList()
  local list = TableData.listEmojiDatas:GetList()
  if list ~= nil and list.Count > 0 then
    for i = 0, list.Count - 1 do
      table.insert(self.emojiList, list[i])
    end
  end
  local virtualList = self.ui.mVirtualList_Emoji
  function virtualList.itemProvider()
    local item = self:EmojiItemProvider()
    return item
  end
  function virtualList.itemRenderer(index, renderDataItem)
    self:EmojiItemRenderer(index, renderDataItem)
  end
  virtualList.numItems = list.Count
  virtualList:Refresh()
end
function UICommunicationChatContentSubPanel:EmojiItemProvider()
  local itemView = UIChatEmojiItem.New()
  local renderDataItem = CS.RenderDataItem()
  itemView:InitCtrl()
  renderDataItem.renderItem = itemView:GetRoot().gameObject
  renderDataItem.data = itemView
  return renderDataItem
end
function UICommunicationChatContentSubPanel:EmojiItemRenderer(index, renderDataItem)
  local itemData = self.emojiList[index + 1]
  local item = renderDataItem.data
  UIUtils.GetButtonListener(UIUtils.GetButton(renderDataItem.renderItem).gameObject).onClick = function()
    self:OnClickEmoji(itemData)
  end
  item:SetData(itemData)
end
function UICommunicationChatContentSubPanel:OnClickEmojiList()
  self.isShowEmoji = not self.isShowEmoji
  setactive(self.ui.mTrans_EmojiList, self.isShowEmoji)
  setactive(self.ui.mBtn_Bg.gameObject, self.isShowEmoji)
  if self.isShowEmoji and #self.emojiList == 0 then
    self:InitEmojiList()
  end
end
function UICommunicationChatContentSubPanel:OnClickEmoji(data)
  if data == nil or data.id <= 0 then
    return
  end
  self.isSelfSend = true
  self.isLastEmoji = true
  if not NetCmdFriendData:IsFriend(self.curFriendData.UID) then
    self:OnClickEmojiList()
    NetCmdChatData:AddCachedMessage(self.curFriendData.UID, data.id, "")
    self.curChatData = NetCmdChatData:GetCachedChatDataById(self.curFriendData.UID)
    if self.curChatData then
      self:UpdateMessageContent(true)
    end
    return
  end
  NetCmdChatData:SendChat(self.curFriendData.UID, data.id, "", function()
    self:OnClickEmojiList()
  end)
end
function UICommunicationChatContentSubPanel:OnCloseEmoji()
  if self.isShowEmoji then
    self:OnClickEmojiList()
  end
end
function UICommunicationChatContentSubPanel:OnCloseRobot()
  if self.isShowRobotContent then
    self.isShowRobotContent = false
    setactive(self.ui.mTrans_GrpRobot.gameObject, false)
    setactive(self.ui.mBtn_Bg.gameObject, false)
  end
end
function UICommunicationChatContentSubPanel:AddMessageItem(message)
  self.curMessageLoopScroll.totalCount = self.curMessageLoopScroll.totalCount + 1
  self.curMessageLoopScroll.GetItemTypeEnd = self.curMessageLoopScroll.GetItemTypeEnd + 1
  local scrollListChild = self.ui.mTrans_ListContent:GetComponent(typeof(CS.ScrollListChild))
  local instObj = instantiate(scrollListChild.childItem, self.ui.mTrans_ListContent)
  local instanceId = instObj:GetInstanceID()
  local item = self:CreateBubbleItem(instObj)
  self.chatMessageItemList = self.chatMessageItemList or {}
  self.chatMessageItemList[instanceId] = item
  local chatData, userData
  if self.chatType == UICommunicationGlobal.ChatType.Friend or self.chatType == UICommunicationGlobal.ChatType.Team then
    for _, msg in pairs(self.curChatData.messageList) do
      if msg.id == message.Id then
        chatData = msg
        break
      end
    end
    userData = message.Active and AccountNetCmdHandler:GetRoleInfoData() or self.curFriendData
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    userData = message.IsCommanderSpeak and AccountNetCmdHandler:GetRoleInfoData() or self.curFriendData
    chatData = {}
    chatData.sentanceId = message.Sentence
    chatData.speaker = message.IsCommanderSpeak
    chatData.replyId = message.Reply
    chatData.isRead = true
    chatData.time = message.Time
    chatData.needShowTime = false
  end
  item:SetData(userData, chatData, self.chatType)
  setactive(instObj, true)
  if self.ui.mTrans_ListContent.sizeDelta.y > self.ui.mTrans_ListContent.parent.sizeDelta.y then
    TimerSys:DelayCall(0.3, function()
      self.curMessageLoopScroll.verticalNormalizedPosition = 1
    end)
  end
end
function UICommunicationChatContentSubPanel:UpdateMessageList(msg)
  local uid = msg.Sender
  if uid and self.curFriendData and self.curFriendData.UID == uid then
    self.curChatData = NetCmdChatData:GetChatDataById(self.curFriendData.UID)
    if self.curChatData then
      self:AddMessageItem(msg.Content)
      NetCmdChatData:SendChatRead(self.curFriendData.UID)
      NetCmdChatData:ReadFriendAllMessage(self.curFriendData.UID)
    end
  end
end
function UICommunicationChatContentSubPanel:UpdateRobotMessageList(msg)
  local uid = msg.Sender.GunId
  self.curChatData = NetCmdChatData:GetRobotChatDataById(uid)
  if self.curChatData then
    self:AddMessageItem(msg.Sender)
  else
    NetCmdChatData:SendGetRobotChats(function(ret)
      if ret == ErrorCodeSuc then
        self.curChatData = NetCmdChatData:GetRobotChatDataById(uid)
        if self.curChatData then
          self:AddMessageItem(msg.Sender)
        end
      end
    end)
  end
end
function UICommunicationChatContentSubPanel:UpdateChatRedPoint(msg)
end
function UICommunicationChatContentSubPanel:RefreshRoleInfo(msg)
  local uid = tonumber(msg.Sender)
  self.curFriendData = NetCmdFriendData:GetFriendDataById(uid)
  self:UpdateFriendInfo()
  self.curMessageLoopScroll:RefreshCells()
end
function UICommunicationChatContentSubPanel:ReturnClicked()
  for i, v in pairs(self.robotReplyItemList) do
    gfdestroy(v:GetRoot())
  end
  self.robotReplyItemList = {}
  self.ui.mLayoutElement_Auto.minHeight = 0
  self.mParent.mParent:UnRegistrationAllKeyboard()
  self.ui.mText_FriendName.color = Color.white
  if self.chatType == UICommunicationGlobal.ChatType.Friend then
    self:CacheInputMessage()
    MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateChatList, self.updateMessageFunc)
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    NetCmdChatData:SetRobotChatRead(1)
    self.mParent.mParent.mChatListSubPanel:DeactiveRobotRedPoint()
    MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateRobotChat, self.updateRobotChatFunc)
  end
  self.ui.mText_InputBox.text = ""
  self:OnCloseEmoji()
  self:OnCloseRobot()
  local index = self.preIndex
  if self.chatType == UICommunicationGlobal.ChatType.Friend then
    NetCmdFriendData:SendSocialFriendSearch(tostring(self.curFriendData.UID), function()
      self.mParent.mParent:EnterSubPanel(index)
    end)
  elseif self.chatType == UICommunicationGlobal.ChatType.Robot then
    self.mParent.mParent:EnterSubPanel(index)
  end
end
function UICommunicationChatContentSubPanel:RegistrationKeyboard(index)
  self.preIndex = index
  self.mParent.mParent:RegistrationKeyboard(KeyCode.Return, self.ui.mBtn_Send)
end
