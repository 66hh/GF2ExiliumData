require("UI.UIBaseCtrl")
BpInviteFriendListItem = class("BpInviteFriendListItem", UIBaseCtrl)
BpInviteFriendListItem.__index = BpInviteFriendListItem
function BpInviteFriendListItem:__InitCtrl()
end
function BpInviteFriendListItem:InitCtrl(parent)
  self.obj = instantiate(UIUtils.GetGizmosPrefab("AssistQuest/InviteFriendListItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self:__InitCtrl()
  self.mAvatarItem = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComPlayerAvatarItemV2.prefab", self))
  CS.LuaUIUtils.SetParent(self.mAvatarItem.gameObject, self.ui.mTrans_Avatar.gameObject, false)
  self.mAvatarUI = {}
  self:LuaUIBindTable(self.mAvatarItem, self.mAvatarUI)
  UIUtils.GetButtonListener(self.mAvatarUI.mBtn_Avatar.transform).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
      self.mData
    })
  end
  local OnRefreshShare = function(ret)
    if ret == ErrorCodeSuc then
      local hint = TableData.GetHintById(192061)
      hint = string_format(hint, self.mData.Name)
      CS.PopupMessageManager.PopupPositiveString(hint)
      self:SetData(self.mData, self.mTaskData)
      MessageSys:SendMessage(UIEvent.BpTaskShareSucc, nil)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnShare.transform).onClick = function()
    local isFriend = NetCmdFriendData:IsFriend(self.mData.UID)
    if isFriend == true then
      if self.mTaskData.bpReleasedTask == nil then
        NetCmdBattlePassData:SendBattlepassReleaseTask(self.mTaskData.Id, self.mData.UID, OnRefreshShare)
      else
        NetCmdChatData:SendBPChat(self.mData.UID, self.mTaskData.bpReleasedTask.TaskId, self.mTaskData.Id, NetCmdBattlePassData.ShareExpire, OnRefreshShare)
      end
    else
      local hint = TableData.GetHintById(192061)
      hint = string_format(hint, self.mData.Name)
      CS.PopupMessageManager.PopupPositiveString(hint)
      MessageSys:SendMessage(UIEvent.BpTaskShareSucc, nil)
    end
  end
end
function BpInviteFriendListItem:SetData(data, taskData)
  self.mData = data
  self.mTaskData = taskData
  setactive(self.ui.mTrans_Offline, not self.mData.IsOnline)
  setactive(self.ui.mTrans_Online, self.mData.IsOnline)
  if self.mData.IsOnline == false then
    local time = self.mData.GetOnlineOrOfflineTime
    if time < 3600 then
      self.ui.mText_Time.text = TableData.GetHintReplaceById(100036, tostring(time // 60))
    elseif 3600 < time and time / 3600 < 24 then
      self.ui.mText_Time.text = TableData.GetHintReplaceById(100035, tostring(time // 3600))
    elseif 86400 <= time and time / 86400 < 30 then
      self.ui.mText_Time.text = TableData.GetHintReplaceById(100034, tostring(time // 86400))
    else
      self.ui.mText_Time.text = TableData.GetHintById(100119)
    end
  end
  setactive(self.ui.mTrans_Shared, false)
  setactive(self.ui.mBtn_BtnShare.transform.parent, false)
  setactive(self.ui.mTrans_Acceped, false)
  self.ui.mText_Name.text = data.Name
  if taskData.bpReleasedTask == nil then
    setactive(self.ui.mBtn_BtnShare.transform.parent, self.mData.IsOnline)
  else
    local isShared = NetCmdChatData:IsBpShared(data.UID, taskData.TaskId)
    local isAccept = NetCmdBattlePassData:IsUsrAccept(data, taskData)
    setactive(self.ui.mTrans_Shared, isShared and not isAccept)
    setactive(self.ui.mBtn_BtnShare.transform.parent, not isShared and self.mData.IsOnline and not isAccept)
    setactive(self.ui.mTrans_Accept, isAccept)
  end
end
function BpInviteFriendListItem:IsShared(data, taskData)
  local userList = NetCmdBattlePassData.TaskDetailUsersList
  if userList == nil then
    return false
  end
  local isShared = false
  for i = 0, userList.Count - 1 do
    if userList[i].Uid == data.UID then
      isShared = true
    end
  end
  local chatData = NetCmdChatData:GetChatDataById(data.UID)
  if chatData ~= nil then
    for i = 0, chatData.messageList.Count - 1 do
      local chatMessage = chatData.messageList[i]
      if chatMessage.bpMessage ~= nil and chatMessage.bpMessage.TaskId == taskData.bpReleasedTask.TaskId then
        isShared = true
      end
    end
  end
  return isShared
end
function BpInviteFriendListItem:SetInteractable(interactable)
end
function BpInviteFriendListItem:OnRelease()
  gfdestroy(self.obj)
end
function BpInviteFriendListItem:UpdateRedPoint(show)
end
