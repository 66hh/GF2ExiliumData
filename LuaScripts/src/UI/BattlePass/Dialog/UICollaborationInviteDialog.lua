require("UI.BattlePass.UIBattlePassGlobal")
require("UI.BattlePass.Item.BpInviteFriendListItem")
require("UI.Common.UICommonLeftTabItemV2")
UICollaborationInviteDialog = class("UICollaborationInviteDialog", UIBasePanel)
UICollaborationInviteDialog.__index = UICollaborationInviteDialog
function UICollaborationInviteDialog:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICollaborationInviteDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UICollaborationInviteDialog:OnInit(root, data)
  self.mBpTaskPackData = data
  self.mTabItems = {}
  self.mShareItems = {}
  self:AddBtnListen()
  self:ShowInfo()
end
function UICollaborationInviteDialog:OnShowStart()
end
function UICollaborationInviteDialog:OnShowFinish()
end
function UICollaborationInviteDialog:ShowInfo()
  local leftTabPrefab = UIUtils.GetGizmosPrefab("UICommonFramework/ComLeftTab1ItemV2.prefab", self)
  local channelItem = UICommonLeftTabItemV2.New()
  local obj = instantiate(leftTabPrefab, self.ui.mSListChild_Content.transform)
  channelItem:InitCtrl(obj.transform)
  channelItem:SetName(2, TableData.GetHintById(192056))
  table.insert(self.mTabItems, channelItem)
  UIUtils.GetButtonListener(channelItem.ui.mBtn_Self.gameObject).onClick = function()
    self:OnChannelTabClick(2)
  end
  local friendItem = UICommonLeftTabItemV2.New()
  local obj = instantiate(leftTabPrefab, self.ui.mSListChild_Content.transform)
  friendItem:InitCtrl(obj.transform)
  friendItem:SetName(1, TableData.GetHintById(192055))
  table.insert(self.mTabItems, friendItem)
  UIUtils.GetButtonListener(friendItem.ui.mBtn_Self.gameObject).onClick = function(tempItem)
    self:OnChatTabClick(1)
  end
  self.mCurTabId = 2
  self:OnChannelTabClick(self.mCurTabId)
  self.bgUI = {}
  self:LuaUIBindTable(self.ui.mObj_GrpBg.transform, self.bgUI)
  setactive(self.bgUI.mTrans_Bg3, false)
end
function UICollaborationInviteDialog:OnChatTabClick(tagId)
  self.mCurTabId = tagId
  for k, v in pairs(self.mTabItems) do
    v:SetItemState(false)
    if tagId == v.tagId then
      v:SetItemState(true)
    end
  end
  NetCmdFriendData:SendRefreshFriends(function(ret)
    if ret == ErrorCodeSuc then
      self:OnRefreshFriend()
    end
  end)
end
function UICollaborationInviteDialog:OnRefreshFriend()
  local friendList = NetCmdFriendData:GetBpFriendList(self.mBpTaskPackData)
  setactive(self.ui.mTrans_None, false)
  setactive(self.ui.mTrans_GrpFriend, false)
  setactive(self.ui.mTrans_GrpTeam, false)
  if friendList == nil then
    setactive(self.ui.mTrans_None, true)
  else
    setactive(self.ui.mTrans_GrpFriend, true)
    for _, item in pairs(self.mShareItems) do
      setactive(item:GetRoot(), false)
    end
    local index = 1
    for k, v in pairs(friendList) do
      local item = self.mShareItems[index]
      if item == nil then
        item = BpInviteFriendListItem.New()
        table.insert(self.mShareItems, item)
        item:InitCtrl(self.ui.mSListChild_Content1.transform)
      end
      item:SetData(friendList[index - 1], self.mBpTaskPackData)
      setactive(item:GetRoot(), true)
      index = index + 1
    end
  end
end
function UICollaborationInviteDialog:IsShared(data, taskData)
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
function UICollaborationInviteDialog:OnChannelTabClick(tagId)
  setactive(self.ui.mTrans_None, false)
  setactive(self.ui.mTrans_GrpFriend, false)
  setactive(self.ui.mTrans_GrpTeam, true)
  local delayShowTime = CGameTime:GetTimestamp() - NetCmdBattlePassData:GetLaskShareTime(self.mBpTaskPackData.TaskId)
  if self.mBpTaskPackData.bpReleasedTask == nil then
    setactive(self.ui.mBtn_BtnShare, true)
  elseif 0 <= delayShowTime and delayShowTime <= TableData.GlobalSystemData.BattlepassShareTeamTimelimit then
    setactive(self.ui.mBtn_BtnShare, false)
  else
    setactive(self.ui.mBtn_BtnShare, true)
  end
  self.mCurTabId = tagId
  for k, v in pairs(self.mTabItems) do
    v:SetItemState(false)
    if tagId == v.tagId then
      v:SetItemState(true)
    end
  end
end
function UICollaborationInviteDialog:Refresh()
end
function UICollaborationInviteDialog:OnClose()
  for _, item in pairs(self.mTabItems) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.mShareItems) do
    gfdestroy(item:GetRoot())
  end
  if self.mTimer ~= nil then
    self.mTimer:Stop()
  end
  MessageSys:RemoveListener(CS.GF2.Message.UIEvent.BpTaskShareSucc, self.RefreshFun)
end
function UICollaborationInviteDialog:OnRelease()
  self.ui = nil
  self.mData = nil
end
function UICollaborationInviteDialog:AddBtnListen()
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.transform).onClick = function()
    UIManager.CloseUI(UIDef.UICollaborationInviteDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.transform).onClick = function()
    UIManager.CloseUI(UIDef.UICollaborationInviteDialog)
  end
  local OnRefreshShare = function(ret)
    if ret == ErrorCodeSuc then
      if self.mCurTabId == 1 then
        self:OnChatTabClick(self.mCurTabId)
      else
        self:OnChannelTabClick(self.mCurTabId)
        local hint = TableData.GetHintById(192061)
        local channelHint = TableData.GetHintById(192065)
        hint = string_format(hint, channelHint)
        CS.PopupMessageManager.PopupPositiveString(hint)
        self.mTimer = TimerSys:DelayCall(TableData.GlobalSystemData.BattlepassShareTeamTimelimit, function()
          setactive(self.ui.mBtn_BtnShare, true)
        end)
      end
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnShare.transform).onClick = function()
    NetCmdBattlePassData:SendBattlepassReleaseTask(self.mBpTaskPackData.Id, 0, OnRefreshShare)
  end
  function self.RefreshFun()
    self:Refresh()
  end
  MessageSys:AddListener(UIEvent.BpTaskShareSucc, self.RefreshFun)
end
