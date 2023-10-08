require("UI.UIBasePanel")
require("UI.BattlePass.UIBattlePassGlobal")
require("UI.BattlePass.Item.BpAssistQuestItem")
require("UI.Common.UICommonItem")
UICollaborationTaskDetailPanel = class("UICollaborationTaskDetailPanel", UIBasePanel)
UICollaborationTaskDetailPanel.__index = UICollaborationTaskDetailPanel
function UICollaborationTaskDetailPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UICollaborationTaskDetailPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Close.transform).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close1.transform).onClick = function()
    self:Close()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnReceive.transform).onClick = function()
    if self.mBpTaskPackData.bpAcceptedTaskInfo ~= nil then
      NetCmdBattlePassData:SendCS_BattlepassGetUniqueQuestReward(self.mBpTaskPackData.UniqueID, function(ret)
        if ret == ErrorCodeSuc then
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
        end
      end)
    else
      NetCmdBattlePassData:SendBattlepassGetShareTaskReward(self.mBpTaskPackData.TaskId, function(ret)
        if ret == ErrorCodeSuc then
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
        end
      end)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpAvatar.transform).onClick = function()
    self:TempFun(nil, nil)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnGoto.transform).onClick = function()
    if NetCmdBattlePassData.ShareExpire < CGameTime:GetTimestamp() or self.mBpTaskPackData.bpAcceptedTaskInfo ~= nil and self.mBpTaskPackData.bpAcceptedTaskInfo.AcceptTask.EndTime < CGameTime:GetTimestamp() then
      local title = TableData.GetHintById(208)
      MessageBox.ShowMidBtn(title, TableData.GetHintById(192084), nil, nil, nil)
      return
    end
    SceneSwitch:SwitchByID(tonumber(self.mBpTaskPackData.link))
  end
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
end
function UICollaborationTaskDetailPanel:OnInit(root, bpTaskPackData)
  self.mIsShowForceCommand = false
  self.mIsShowXiezuo = false
  self.mIsOpenXieZuoForceCommand = false
  self.mBpTaskPackData = bpTaskPackData
  self.mRewardItem = {}
  self.mAssistQuestItem = {}
  self:ShowInfo(self.mBpTaskPackData)
  self.mBpTaskPackData.isNewAddFlag = false
  local cacheKey = AccountNetCmdHandler:GetUID() .. NetCmdBattlePassData.BpTaskStr .. tostring(self.mBpTaskPackData.Id)
  if PlayerPrefs.HasKey(cacheKey) then
    PlayerPrefs.DeleteKey(cacheKey)
  end
  local OnRes = function(ret)
    if ret == ErrorCodeSuc then
      self:ShowInfo(self.mBpTaskPackData)
    end
  end
  local OnBpJoinNotice = function(sender, content)
    if self.mBpTaskPackData.TaskId == sender.Sender then
      self.mUser = CS.AccountNetCmdHandler.ConvertByteToUser(sender.Content)
      local hint = TableData.GetHintById(192086)
      hint = string_format(hint, self.mUser.Name)
      CS.PopupMessageManager.PopupPositiveString(hint)
      NetCmdBattlePassData:SendBattlepassTaskDetail(self.mBpTaskPackData.TaskId, OnRes)
    end
  end
  local BpTaskShareSucc = function()
    if self.mBpTaskPackData.TaskId ~= 0 then
      NetCmdBattlePassData:SendBattlepassTaskDetail(self.mBpTaskPackData.TaskId, OnRes)
    end
  end
  local OnBpTaskFish = function(msg)
    if self.mBpTaskPackData.TaskId == msg.Sender then
      self.mUser = CS.AccountNetCmdHandler.ConvertByteToUser(msg.Content)
      local hint = TableData.GetHintById(192082)
      local hint = string_format(hint, self.mUser.Name)
      CS.PopupMessageManager.PopupPositiveString(hint)
      NetCmdBattlePassData:SendBattlepassTaskDetail(self.mBpTaskPackData.TaskId, OnRes)
    end
  end
  function self.BpJoinNotice(sender, content)
    OnBpJoinNotice(sender, content)
  end
  function self.BpTaskShareSucc()
    BpTaskShareSucc()
  end
  function self.BpTaskFish(msg)
    OnBpTaskFish(msg)
  end
  MessageSys:AddListener(UIEvent.BpTaskShareSucc, self.BpTaskShareSucc)
  MessageSys:AddListener(UIEvent.BpJoinNotice, self.BpJoinNotice)
  MessageSys:AddListener(UIEvent.BpTaskFish, self.BpTaskFish)
end
function UICollaborationTaskDetailPanel:OnShowStart()
  setactive(self.mUIRoot.gameObject, false)
  setactive(self.mUIRoot.gameObject, true)
end
function UICollaborationTaskDetailPanel:OnShowFinish()
end
function UICollaborationTaskDetailPanel:OnTop()
  if self.mBpTaskPackData.TaskId == 0 then
    self:ShowInfo(self.mBpTaskPackData)
  else
    NetCmdBattlePassData:SendBattlepassTaskDetail(self.mBpTaskPackData.TaskId, function(ret)
      if ret == ErrorCodeSuc then
        self:ShowInfo(self.mBpTaskPackData)
      end
    end)
  end
end
function UICollaborationTaskDetailPanel:ShowInfo(bpTaskPackData)
  self.ui.mText_Title.text = bpTaskPackData.name
  self.ui.mText_Name.text = AccountNetCmdHandler:GetName()
  self.ui.mText_Text.text = AccountNetCmdHandler:GetMotto() ~= "" and AccountNetCmdHandler:GetMotto() or TableData.GetHintById(100013)
  self.uiAvatar = {}
  self:LuaUIBindTable(self.ui.mBtn_GrpAvatar.transform, self.uiAvatar)
  self.mUserData = AccountNetCmdHandler:GetRoleInfoData()
  self.uiAvatar.mImg_Avatar.sprite = IconUtils.GetPlayerAvatar(AccountNetCmdHandler:GetBustAvatar())
  UIUtils.GetButtonListener(self.uiAvatar.mBtn_GrpAvatarInvitation.gameObject).onClick = function()
    NetCmdFriendData:SendSocialFriendApply(NetCmdBattlePassData.TaskDetail.Task.Owner, function()
      UIUtils.PopupPositiveHintMessage(100027)
      NetCmdBattlePassData:SetTaskAddFriend(bpTaskPackData.TaskId, NetCmdBattlePassData.TaskDetail.Task.Owner)
      self:ShowInfo(self.mBpTaskPackData)
    end)
  end
  setactive(self.uiAvatar.mBtn_GrpAvatarInvitation, false)
  if NetCmdBattlePassData.TaskDetail ~= nil and NetCmdBattlePassData.TaskDetail.Users.Length > 0 then
    for i = 0, NetCmdBattlePassData.TaskDetail.Users.Count - 1 do
      local userData = NetCmdBattlePassData.TaskDetail.Users[i]
      local user = CS.AccountNetCmdHandler.ConvertByteToUser(userData)
      local rolePublicCmdData = CS.RolePublicCmdData(user)
      if rolePublicCmdData.UID == NetCmdBattlePassData.TaskDetail.Task.Owner then
        self.ui.mText_Name.text = rolePublicCmdData.Name
        self.ui.mText_Text.text = rolePublicCmdData.PlayerMotto ~= "" and rolePublicCmdData.PlayerMotto or TableData.GetHintById(100013)
        self.uiAvatar.mImg_Avatar.sprite = IconUtils.GetPlayerAvatar(rolePublicCmdData.BustIcon)
        self.mUserData = rolePublicCmdData
      end
      if rolePublicCmdData.UID == AccountNetCmdHandler:GetUID() and rolePublicCmdData.UID ~= NetCmdBattlePassData.TaskDetail.Task.Owner then
        local isFriend = NetCmdFriendData:IsFriend(NetCmdBattlePassData.TaskDetail.Task.Owner)
        local isMyself = NetCmdBattlePassData.TaskDetail.Task.Owner == AccountNetCmdHandler:GetUID()
        local hasSendFriendApply = NetCmdBattlePassData:CheckTaskHasAddFriend(bpTaskPackData.TaskId, NetCmdBattlePassData.TaskDetail.Task.Owner)
        local isComplete = false
        if bpTaskPackData.bpAcceptedTaskInfo ~= nil then
          isComplete = bpTaskPackData.isComplete
        end
        setactive(self.uiAvatar.mBtn_GrpAvatarInvitation, not isMyself and not isFriend and not hasSendFriendApply and isComplete)
      end
    end
  end
  self.ui.mText_TaskTarget.text = bpTaskPackData.description .. string_format(TableData.GetHintById(192091), bpTaskPackData:GetRatioStr())
  if bpTaskPackData.Reward ~= nil then
    local index = 1
    for k, v in pairs(bpTaskPackData.Reward) do
      local item = self.mRewardItem[index]
      if self.mRewardItem[index] == nil then
        item = UICommonItem.New()
        item:InitCtrl(self.ui.mSListChild_GrpItemList.transform)
        table.insert(self.mRewardItem, item)
      end
      item:SetItemData(k, v)
      index = index + 1
    end
  end
  setactive(self.ui.mBtn_BtnReceive.transform.parent, false)
  setactive(self.ui.mBtn_BtnGoto.transform.parent, false)
  setactive(self.ui.mTrans_Compelte, false)
  setactive(self.ui.mTrans_ImgUnCompelte, true)
  setactive(self.ui.mTrans_ImgCompelte, false)
  setactive(self.ui.mTrans_Received, false)
  self.ui.mAni_GrpPublisherInfo:SetBool("Complete", false)
  setactive(self.uiAvatar.mTrans_Complete, false)
  if bpTaskPackData.bpReleasedTask == nil and bpTaskPackData.bpAcceptedTaskInfo == nil then
    setactive(self.ui.mBtn_BtnGoto.transform.parent, not bpTaskPackData.isComplete)
    setactive(self.ui.mTrans_Compelte, bpTaskPackData.isComplete and bpTaskPackData.isReceived == false)
    setactive(self.ui.mTrans_ImgCompelte, bpTaskPackData.isComplete)
    setactive(self.ui.mTrans_ImgUnCompelte, not bpTaskPackData.isComplete)
    self.ui.mAni_GrpPublisherInfo:SetBool("Complete", bpTaskPackData.isComplete)
  elseif bpTaskPackData.bpReleasedTask ~= nil then
    local stageType = CS.ProtoObject.BpReleaseTaskState.__CastFrom(bpTaskPackData.bpReleasedTask.State)
    setactive(self.ui.mBtn_BtnGoto.transform.parent, bpTaskPackData.isComplete == false)
    setactive(self.ui.mBtn_BtnReceive.transform.parent, stageType == CS.ProtoObject.BpReleaseTaskState.RewardNotGet)
    setactive(self.ui.mTrans_Compelte, bpTaskPackData.isComplete and stageType == CS.ProtoObject.BpReleaseTaskState.None)
    setactive(self.ui.mTrans_Received, bpTaskPackData.isReceived == true)
    self.ui.mAni_GrpPublisherInfo:SetBool("Complete", bpTaskPackData.isComplete)
    setactive(self.uiAvatar.mTrans_Complete, bpTaskPackData.isComplete)
    setactive(self.ui.mTrans_ImgCompelte, bpTaskPackData.isComplete)
    setactive(self.ui.mTrans_ImgUnCompelte, not bpTaskPackData.isComplete)
    if bpTaskPackData.bpReleasedTask.State == 1 then
      setactive(self.ui.mBtn_BtnReceive.transform.parent, true)
    end
  elseif bpTaskPackData.bpAcceptedTaskInfo ~= nil then
    setactive(self.ui.mBtn_BtnGoto.transform.parent, bpTaskPackData.isComplete == false)
    setactive(self.ui.mBtn_BtnReceive.transform.parent, bpTaskPackData.isComplete and not bpTaskPackData.isReceived)
    setactive(self.ui.mTrans_Compelte, bpTaskPackData.isComplete)
    setactive(self.ui.mTrans_Received, bpTaskPackData.isReceived == true)
    self.ui.mAni_GrpPublisherInfo:SetBool("Complete", true)
    setactive(self.uiAvatar.mTrans_Complete, true)
    setactive(self.ui.mTrans_ImgCompelte, bpTaskPackData.isComplete)
    setactive(self.ui.mTrans_ImgUnCompelte, not bpTaskPackData.isComplete)
    self.mIsShowXiezuo = self.mBpTaskPackData.bpAcceptedTaskInfo ~= nil and self.mBpTaskPackData.bpAcceptedTaskInfo.AcceptTask.EndTime > CGameTime:GetTimestamp()
    if self.mBpTaskPackData.bpAcceptedTaskInfo ~= nil and 0 < self.mBpTaskPackData.bpAcceptedTaskInfo.AcceptTask.EndTime then
      self.mIsShowXiezuo = true
    end
  end
  for i = 1, 5 do
    local item = self.mAssistQuestItem[i]
    if self.mAssistQuestItem[i] == nil then
      item = BpAssistQuestItem.New()
      item:InitCtrl(self.ui.mSListChild_GrpPlayerAvatar.transform)
    end
    local userData
    if (bpTaskPackData.bpReleasedTask ~= nil or bpTaskPackData.bpAcceptedTaskInfo) and i < NetCmdBattlePassData.TaskDetail.Users.Length then
      userData = NetCmdBattlePassData.TaskDetail.Users[i]
    end
    item:SetData(userData, bpTaskPackData)
    table.insert(self.mAssistQuestItem, item)
  end
  self.ui.mBtn_GrpAvatar.interactable = self.mUserData.UID ~= AccountNetCmdHandler:GetUID()
end
function UICollaborationTaskDetailPanel:OnUpdate()
  if self.ui ~= nil then
    for _, item in pairs(self.mAssistQuestItem) do
      if item ~= nil then
        item:OnUpdate()
      end
    end
    self.ui.mText_Time.text = string_format(TableData.GetHintById(192053), NetCmdBattlePassData:GetDailyTime())
  end
  if NetCmdBattlePassData.ShareExpire < CGameTime:GetTimestamp() then
    self:OnForceJumpToMainPanel()
  end
  if self.mIsShowXiezuo == true and self.mIsOpenXieZuoForceCommand == false and self.mBpTaskPackData ~= nil and self.mBpTaskPackData.bpAcceptedTaskInfo ~= nil and self.mBpTaskPackData.bpAcceptedTaskInfo.AcceptTask.EndTime < CGameTime:GetTimestamp() and not self.mBpTaskPackData.isComplete then
    self.mIsOpenXieZuoForceCommand = true
    local title = TableData.GetHintById(192100)
    local hint = TableData.GetHintById(192101)
    MessageBox.ShowMidBtn(hint, title, nil, nil, function()
      NetCmdBattlePassData:RemoveOutTimeTask(self.mBpTaskPackData)
      self:Close()
    end)
  end
end
function UICollaborationTaskDetailPanel:OnForceJumpToMainPanel()
  if self.mIsShowForceCommand == false then
    self.mIsShowForceCommand = true
    local title = TableData.GetHintById(208)
    local hint = TableData.GetHintById(192096)
    MessageBox.ShowMidBtn(title, hint, nil, nil, function()
      self:OnCommanderCenter()
    end)
  end
end
function UICollaborationTaskDetailPanel:Close()
  UIManager.CloseUI(UIDef.UICollaborationTaskDetailPanel)
end
function UICollaborationTaskDetailPanel:OnClose()
  for _, item in pairs(self.mRewardItem) do
    gfdestroy(item:GetRoot())
  end
  for _, item in pairs(self.mAssistQuestItem) do
    item:OnRelease()
  end
  MessageSys:RemoveListener(UIEvent.BpJoinNotice, self.BpJoinNotice)
  MessageSys:RemoveListener(UIEvent.BpTaskShareSucc, self.BpTaskShareSucc)
  MessageSys:RemoveListener(UIEvent.BpTaskFish, self.BpTaskFish)
  self:UnRegistrationAllKeyboard()
end
function UICollaborationTaskDetailPanel:OnCommanderCenter()
  UIManager.JumpToMainPanel()
end
function UICollaborationTaskDetailPanel:TempFun(temp1, temp2)
  UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
    self.mUserData
  })
end
