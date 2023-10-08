require("UI.UIBaseCtrl")
BpAssistQuestItem = class("BpAssistQuestItem", UIBaseCtrl)
BpAssistQuestItem.__index = BpAssistQuestItem
function BpAssistQuestItem:__InitCtrl()
end
function BpAssistQuestItem:InitCtrl(parent)
  self.obj = instantiate(UIUtils.GetGizmosPrefab("AssistQuest/Btn_AssistQuestListItem.prefab", self))
  if parent then
    CS.LuaUIUtils.SetParent(self.obj.gameObject, parent.gameObject, false)
  end
  self.ui = {}
  self:LuaUIBindTable(self.obj, self.ui)
  self:SetRoot(self.obj.transform)
  self:__InitCtrl()
  self.mAvatarObj = instantiate(UIUtils.GetGizmosPrefab("AssistQuest/Btn_AssistQuestAvatarItem.prefab", self))
  CS.LuaUIUtils.SetParent(self.mAvatarObj.gameObject, self.ui.mSListChild_GrpPlayerAvatar.gameObject, false)
  self.mEndTime = 0
  self.AvatarUI = {}
  self.mSetEmpty = false
  self:LuaUIBindTable(self.mAvatarObj, self.AvatarUI)
end
function BpAssistQuestItem:SetData(data, bpTaskPackData)
  self.mData = data
  UIUtils.GetButtonListener(self.ui.mBtn_AssistQuestListItem.gameObject).onClick = function()
    if bpTaskPackData.isComplete == false then
      local hint = TableData.GetHintById(192072)
      CS.PopupMessageManager.PopupString(hint)
    else
      UIManager.OpenUIByParam(UIDef.UICollaborationInviteDialog, bpTaskPackData)
    end
  end
  setactive(self.ui.mTrans_Add, bpTaskPackData.bpAcceptedTaskInfo == nil and self.mData == nil)
  self.ui.mBtn_AssistQuestListItem.interactable = bpTaskPackData.bpAcceptedTaskInfo == nil and self.mData == nil
  self.mEndTime = 0
  if self.mData == nil then
    self.ui.mAni_AssistQuestListItem:SetInteger("Switch", 0)
    self.ui.mText_Name.text = TableData.GetHintById(192076)
    setactive(self.mAvatarObj, false)
  else
    setactive(self.mAvatarObj, true)
    self.mUser = CS.AccountNetCmdHandler.ConvertByteToUser(data)
    self.ui.mText_Name.text = self.mUser.Name
    local avatarData = TableData.GetPlayerAvatarBustById(self.mUser.Portrait, self.mUser.Sex.value__)
    self.AvatarUI.mImg_Avatar.sprite = IconUtils.GetPlayerAvatar(avatarData)
    self.mRolePublicCmdData = CS.RolePublicCmdData(self.mUser)
    UIUtils.GetButtonListener(self.AvatarUI.mBtn_AssistQuestAvatarItem.gameObject).onClick = function()
      UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
        self.mRolePublicCmdData
      })
    end
    self.AvatarUI.mBtn_AssistQuestAvatarItem.interactable = self.mRolePublicCmdData.UID ~= AccountNetCmdHandler:GetUID()
    UIUtils.GetButtonListener(self.AvatarUI.mBtn_GrpAvatarInvitation.gameObject).onClick = function()
      NetCmdFriendData:SendSocialFriendApply(self.mRolePublicCmdData.UID, function()
        UIUtils.PopupPositiveHintMessage(100027)
        NetCmdBattlePassData:SetTaskAddFriend(bpTaskPackData.TaskId, NetCmdBattlePassData.TaskDetail.Task.Owner)
        self:SetData(self.mData, bpTaskPackData)
      end)
    end
    setactive(self.AvatarUI.mBtn_GrpAvatarInvitation, false)
    for i = 0, NetCmdBattlePassData.TaskDetail.Task.ShareUid.Count - 1 do
      local v = NetCmdBattlePassData.TaskDetail.Task.ShareUid[i]
      if v.Uid == self.mRolePublicCmdData.UID then
        if v.EndTime == 0 then
          self.ui.mAni_AssistQuestListItem:SetInteger("Switch", 2)
          setactive(self.AvatarUI.mTrans_Complete, true)
          local isFriend = NetCmdFriendData:IsFriend(NetCmdBattlePassData.TaskDetail.Task.Owner)
          local isMyself = NetCmdBattlePassData.TaskDetail.Task.Owner == AccountNetCmdHandler:GetUID()
          local hasSendFriendApply = NetCmdBattlePassData:CheckTaskHasAddFriend(bpTaskPackData.TaskId, NetCmdBattlePassData.TaskDetail.Task.Owner)
          local isComplete = false
          if bpTaskPackData.bpReleasedTask ~= nil then
            local rewardState = bpTaskPackData.bpReleasedTask.State
            isComplete = rewardState ~= 0
          end
          if bpTaskPackData.bpAcceptedTaskInfo ~= nil then
            isComplete = false
          end
          setactive(self.AvatarUI.mBtn_GrpAvatarInvitation, not isMyself and not isFriend and not hasSendFriendApply and isComplete)
        elseif CGameTime:GetTimestamp() > v.EndTime then
          self.ui.mAni_AssistQuestListItem:SetInteger("Switch", 0)
          self.ui.mText_Name.text = TableData.GetHintById(192076)
          setactive(self.mAvatarObj, false)
          setactive(self.ui.mTrans_Add, true)
          self.ui.mBtn_AssistQuestListItem.interactable = true
          local isMyself = NetCmdBattlePassData.TaskDetail.Task.Owner == AccountNetCmdHandler:GetUID()
          setactive(self.ui.mTrans_Add, isMyself)
        else
          self.ui.mAni_AssistQuestListItem:SetInteger("Switch", 1)
          setactive(self.AvatarUI.mTrans_Complete, false)
        end
        self.mEndTime = v.EndTime
      end
    end
  end
end
function BpAssistQuestItem:SetInteractable(interactable)
end
function BpAssistQuestItem:OnUpdate()
  setactive(self.ui.mText_Time, false)
  if self.mEndTime ~= nil and self.mEndTime > 0 and CGameTime:GetTimestamp() <= self.mEndTime then
    setactive(self.ui.mText_Time, true)
    self.ui.mText_Time.text = CS.TimeUtils.GetLeftTimeHHMMSS(self.mEndTime)
  end
  if self.mEndTime ~= nil and self.mEndTime > 0 and CGameTime:GetTimestamp() > self.mEndTime and self.mSetEmpty == false then
    self.ui.mAni_AssistQuestListItem:SetInteger("Switch", 0)
    self.ui.mText_Name.text = TableData.GetHintById(192076)
    setactive(self.mAvatarObj, false)
    self.ui.mBtn_AssistQuestListItem.interactable = true
    self.mSetEmpty = true
    local isMyself = NetCmdBattlePassData.TaskDetail.Task.Owner == AccountNetCmdHandler:GetUID()
    setactive(self.ui.mTrans_Add, isMyself)
  end
end
function BpAssistQuestItem:OnRelease()
  self.super.OnRelease(self, true)
end
function BpAssistQuestItem:UpdateRedPoint(show)
end
