require("UI.UIBaseCtrl")
UIChatMessageItem = class("UIChatMessageItem", UIBaseCtrl)
UIChatMessageItem.__index = UIChatMessageItem
function UIChatMessageItem:ctor()
  self.messageData = nil
  self.userData = nil
  self.type = nil
  self.teamIndex = nil
  self.cdTimer = nil
  self.otherChat = nil
  self.selfChat = nil
  self.endTime = 0
  self.mLayoutElement = nil
  self.mLayoutGroup = nil
end
function UIChatMessageItem:InitCtrl(parent)
  self:SetRoot(parent.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIChatMessageItem:__InitCtrl()
  self.otherChat = self:InitChatContent(self.ui.mTrans_OtherPlayer)
  self.selfChat = self:InitChatContent(self.ui.mTrans_PlayerSelf)
end
function UIChatMessageItem:InitChatContent(obj)
  local content = {}
  content.obj = obj
  if obj == self.ui.mTrans_PlayerSelf then
    content.imgAvatar = self.ui.mImg_SelfAvatar
    content.txtContent = self.ui.mText_SelfContent
    content.transContent = self.ui.mTrans_SelfContent
    content.imgEmoji = self.ui.mImg_SelfEmoji
    content.transQuest = self.ui.mTrans_SelfQuest
    content.txtTeamTitle = self.ui.mText_SelfTitle
    content.txtTeamEnd = self.ui.mText_SelfEnd
    content.txtTeamTime = self.ui.mText_SelfTime
    content.txtTeamSubtitle = self.ui.mText_SelfSubtitle
    content.txtTeamContent = self.ui.mText_SelfTeamContent
    content.btnTeam = self.ui.mBtn_SelfTeam
    content.imgLine = self.ui.mImg_SelfLine
    content.bpAccept = self.ui.mTrans_SelfBPAccept
    content.bpFinish = self.ui.mTrans_SelfBPFinish
  elseif obj == self.ui.mTrans_OtherPlayer then
    content.imgAvatar = self.ui.mImg_OtherAvatar
    content.txtContent = self.ui.mText_OtherContent
    content.transContent = self.ui.mTrans_OtherContent
    content.imgEmoji = self.ui.mImg_OtherEmoji
    content.btnAvatar = self.ui.mBtn_OtherAvatar
    content.transQuest = self.ui.mTrans_OtherQuest
    content.txtTeamTitle = self.ui.mText_OtherTitle
    content.txtTeamEnd = self.ui.mText_OtherEnd
    content.txtTeamTime = self.ui.mText_OtherTime
    content.txtTeamSubtitle = self.ui.mText_OtherSubtitle
    content.txtTeamContent = self.ui.mText_OtherTeamContent
    content.btnTeam = self.ui.mBtn_OtherTeam
    content.imgLine = self.ui.mImg_OtherLine
    content.bpAccept = self.ui.mTrans_OtherBPAccept
    content.bpFinish = self.ui.mTrans_OtherBPFinish
    UIUtils.GetButtonListener(content.btnAvatar.gameObject).onClick = function()
      self:OnClickPlayerInfo()
    end
  end
  UIUtils.GetButtonListener(content.btnTeam.gameObject).onClick = function()
    self:OnClickTeam()
  end
  return content
end
function UIChatMessageItem:SetData(userData, messageData, type, teamIndex)
  self.userData = userData
  self.messageData = messageData
  self.mIsAcceptTask = false
  self.type = type
  if teamIndex then
    self.teamIndex = teamIndex
  end
  if messageData then
    local bubble
    if self.type == UICommunicationGlobal.ChatType.Friend then
      if messageData.bpMessage ~= nil then
        self.type = UICommunicationGlobal.ChatType.Team
      end
      if messageData.active then
        bubble = self.selfChat
      else
        bubble = self.otherChat
      end
    elseif self.type == UICommunicationGlobal.ChatType.Robot then
      if messageData.speaker then
        bubble = self.selfChat
      else
        bubble = self.otherChat
      end
    elseif self.type == UICommunicationGlobal.ChatType.Team then
      if messageData.active then
        bubble = self.selfChat
      else
        bubble = self.otherChat
      end
    end
    setactive(bubble.imgEmoji.gameObject, self.type == UICommunicationGlobal.ChatType.Friend and messageData.emoji > 0)
    setactive(bubble.txtContent.gameObject, self.type == UICommunicationGlobal.ChatType.Robot or messageData.emoji == 0)
    setactive(bubble.transContent.gameObject, self.type ~= UICommunicationGlobal.ChatType.Team and (self.type == UICommunicationGlobal.ChatType.Robot or messageData.emoji == 0))
    setactive(bubble.transQuest.gameObject, self.type == UICommunicationGlobal.ChatType.Team)
    if self.type == UICommunicationGlobal.ChatType.Friend then
      setactive(self.ui.mBtn_Quote.gameObject, false)
      if messageData.emoji > 0 then
        local emojiData = TableData.listEmojiDatas:GetDataById(messageData.emoji)
        if emojiData then
          bubble.imgEmoji.sprite = IconUtils.GetEmojiIcon(emojiData.icon)
        end
      else
        bubble.txtContent.text = messageData.message
      end
    elseif self.type == UICommunicationGlobal.ChatType.Robot then
      bubble.txtContent.text = TableData.listAiChatContentDatas:GetDataById(messageData.sentanceId).content
      setactive(self.ui.mBtn_Quote.gameObject, false)
      if messageData.replyId ~= 0 and messageData.replyId ~= nil then
        setactive(self.ui.mBtn_Quote.gameObject, true)
        local robotData = TableData.listAiInfoDatas:GetDataById(1)
        self.ui.mText_Quote.text = robotData.name .. ":" .. TableData.listAiChatContentDatas:GetDataById(messageData.replyId).content
      end
    elseif self.type == UICommunicationGlobal.ChatType.Team then
      local bpTaskId = messageData.bpMessage.StcId
      local taskData = TableData.listBpTaskDatas:GetDataById(bpTaskId)
      bubble.txtTeamEnd.text = TableData.GetHintById(192046)
      bubble.txtTeamTitle.text = TableData.GetHintById(192047)
      if taskData ~= nil then
        bubble.txtTeamSubtitle.text = taskData.name
        bubble.txtTeamContent.text = taskData.des
      end
      local nowTime = CGameTime:GetTimestamp()
      local expireTime = CGameTime:GetTimestamp() + TableData.GlobalSystemData.BattlepassTaskShareTimelimit < NetCmdBattlePassData.ShareExpire and CGameTime:GetTimestamp() + TableData.GlobalSystemData.BattlepassTaskShareTimelimit or NetCmdBattlePassData.ShareExpire
      self.endTime = messageData.bpMessage.ExpireTime
      local isAccept = NetCmdBattlePassData:IsTaskAccept(self.messageData.bpMessage.TaskId)
      local status = NetCmdBattlePassData:GetBPTaskStatus(self.messageData.bpMessage.TaskId)
      if isAccept then
        local bpTaskPackData = NetCmdBattlePassData:GetTaskById(self.messageData.bpMessage.TaskId)
        if bpTaskPackData ~= nil and bpTaskPackData.bpAcceptedTaskInfo ~= nil then
          self.mIsAcceptTask = true
          self.endTime = bpTaskPackData.bpAcceptedTaskInfo.AcceptTask.EndTime
        end
      end
      setactive(bubble.bpAccept, isAccept and status == 0)
      setactive(bubble.bpFinish, isAccept and 0 < status)
      setactive(bubble.txtTeamTime.gameObject, nowTime < self.endTime)
      setactive(bubble.txtTeamEnd.gameObject, nowTime >= self.endTime)
      if nowTime < self.endTime then
        bubble.imgLine.color = ColorUtils.StringToColor("CC9B21")
        bubble.txtTeamTime.text = CS.TimeUtils.GetLeftTimeHHMMSS(self.endTime)
        self:UpdateCountDownTime()
      else
        bubble.imgLine.color = ColorUtils.StringToColor("5F6B6F")
      end
    end
    if userData then
      if self.type == UICommunicationGlobal.ChatType.Friend then
        bubble.imgAvatar.sprite = IconUtils.GetPlayerAvatar(userData.Icon)
      elseif self.type == UICommunicationGlobal.ChatType.Robot then
        if messageData.speaker then
          bubble.imgAvatar.sprite = IconUtils.GetPlayerAvatar(userData.Icon)
        else
          bubble.imgAvatar.sprite = IconUtils.GetPlayerAvatar(userData.head_icon)
        end
      elseif self.type == UICommunicationGlobal.ChatType.Team then
        bubble.imgAvatar.sprite = IconUtils.GetPlayerAvatar(userData.Icon)
      end
    end
    setactive(self.ui.mTrans_Time.gameObject, messageData.needShowTime)
    if messageData.needShowTime then
      local time = self.messageData:TranslationTime()
      self.ui.mText_Time.text = time
    end
    if self.type == UICommunicationGlobal.ChatType.Friend then
      setactive(self.selfChat.obj, messageData.active)
      setactive(self.otherChat.obj, not messageData.active)
    elseif self.type == UICommunicationGlobal.ChatType.Robot then
      setactive(self.selfChat.obj, messageData.speaker)
      setactive(self.otherChat.obj, not messageData.speaker)
    elseif self.type == UICommunicationGlobal.ChatType.Team then
      setactive(self.selfChat.obj, messageData.active)
      setactive(self.otherChat.obj, not messageData.active)
    end
  end
end
function UIChatMessageItem:OnClickPlayerInfo()
  if self.type == UICommunicationGlobal.ChatType.Robot then
    local robotData = TableData.listAiInfoDatas:GetDataById(1)
    UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
      AccountNetCmdHandler:GetRoleInfoData(),
      robotData
    })
  elseif (self.type == UICommunicationGlobal.ChatType.Friend or self.type == UICommunicationGlobal.ChatType.Team) and self.userData then
    NetCmdFriendData:SendSocialFriendSearch(tostring(self.userData.UID), function()
      local userData = NetCmdFriendData:GetCurSearchFriendData()
      if userData then
        UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
          self.userData
        })
      end
    end)
  end
end
function UIChatMessageItem:OnClickTeam()
  if CGameTime:GetTimestamp() <= self.endTime then
    local isAccept = NetCmdBattlePassData:IsTaskAccept(self.messageData.bpMessage.TaskId)
    local OnRes = function(ret)
      if ret == ErrorCodeSuc then
        if NetCmdBattlePassData.TaskDetail.Task.Owner == AccountNetCmdHandler:GetUID() then
          UIUtils.PopupHintMessage(192104)
          return
        end
        local bpTaskPackData = NetCmdBattlePassData:GetTaskById(self.messageData.bpMessage.TaskId)
        if bpTaskPackData ~= nil and (bpTaskPackData.bpReleasedTask ~= nil or isAccept == true) then
          UIManager.OpenUIByParam(UIDef.UICollaborationTaskDetailPanel, bpTaskPackData)
        else
          UIManager.OpenUIByParam(UIDef.UICollaborationAcceptDialog, self.messageData)
        end
      end
    end
    NetCmdBattlePassData:SendBattlepassTaskDetail(self.messageData.bpMessage.TaskId, OnRes)
  elseif NetCmdBattlePassData.CostAcceptCount >= TableData.GlobalSystemData.BattlepassTaskShareToplimit2 then
    UIUtils.PopupHintMessage(192048)
  else
    UIUtils.PopupHintMessage(192049)
  end
end
function UIChatMessageItem:UpdateCountDownTime()
  self:ReleaseTimer()
  self.cdTimer = TimerSys:DelayCall(1, function()
    local bubble
    if self.messageData.active then
      bubble = self.selfChat
    else
      bubble = self.otherChat
    end
    if CGameTime:GetTimestamp() <= self.endTime then
      if bubble.txtTeamTime == nil then
        self:ReleaseTimer()
      else
        bubble.txtTeamTime.text = CS.TimeUtils.GetLeftTimeHHMMSS(self.endTime)
      end
    else
      if self.mIsAcceptTask then
        self.endTime = self.messageData.bpMessage.ExpireTime
        setactive(bubble.bpAccept.gameObject, false)
        self.mIsAcceptTask = false
        return
      end
      setactive(bubble.txtTeamTime.gameObject, false)
      setactive(bubble.txtTeamEnd.gameObject, true)
      setactive(bubble.bpAccept.gameObject, false)
      bubble.imgLine.color = ColorUtils.StringToColor("5F6B6F")
      self:ReleaseTimer()
    end
  end, nil, -1)
end
function UIChatMessageItem:ReleaseTimer()
  if self.cdTimer then
    self.cdTimer:Stop()
    self.cdTimer = nil
  end
end
