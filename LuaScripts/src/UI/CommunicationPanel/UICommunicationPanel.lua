require("UI.UIBasePanel")
require("UI.CommunicationPanel.SubPanels.UICommunicationFriendSubPanel")
require("UI.CommunicationPanel.SubPanels.UICommunicationChatContentSubPanel")
require("UI.CommunicationPanel.SubPanels.UICommunicationChatListSubPanel")
require("UI.AdjutantPanel.UIAdjutantGlobal")
UICommunicationPanel = class("UICommunicationPanel", UIBasePanel)
UICommunicationPanel.__index = UICommunicationPanel
UICommunicationPanel.ui = {}
UICommunicationPanel.mUIRoot = nil
UICommunicationPanel.mFriendSubPanel = nil
UICommunicationPanel.mChatListSubPanel = nil
UICommunicationPanel.mChatContentSubPanel = nil
UICommunicationPanel.SUB_PANEL_ID = {
  FRIEND = 2,
  CHAT_LIST = 1,
  CHAT_CONTENT = 3
}
UICommunicationPanel.RedPointType = {
  RedPointConst.ApplyFriend,
  RedPointConst.Chat
}
function UICommunicationPanel:ctor(csPanel)
  UICommunicationPanel.super:ctor(csPanel)
  csPanel.HideSceneBackground = false
  csPanel.Is3DPanel = true
end
function UICommunicationPanel:OnInit(root, data)
  self:SetRoot(root)
  self.mUIRoot = root
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.tabList = {}
  self.mindex = 0
  self.ui.mAnimator:SetTrigger("GrpEntrance_FadeIn")
  self:InitButtonGroup()
  self.mFriendSubPanel = UICommunicationFriendSubPanel
  self.mFriendSubPanel:InitCtrl(self.ui.mTrans_Friend, self)
  self.mChatListSubPanel = UICommunicationChatListSubPanel
  self.mChatListSubPanel:InitCtrl(self.ui.mTrans_ChatList, self)
  self.mChatContentSubPanel = UICommunicationChatContentSubPanel
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.ApplyFriend, self.ui.mTrans_FriendRedPoint)
  RedPointSystem:GetInstance():AddRedPointListener(RedPointConst.Chat, self.ui.mTrans_ChatRedPoint)
  function self.friendChangeMarkFunc(msg)
    self:OnFriendChangeMark(msg)
  end
  function self.updateChatListFunc(msg)
    self:UpdateRedPoint()
  end
  MessageSys:AddListener(CS.GF2.Message.ChatEvent.UpdateChatList, self.updateChatListFunc)
  MessageSys:AddListener(CS.GF2.Message.FriendEvent.FriendChangeMark, self.friendChangeMarkFunc)
  self.ui.mText_Tittle.text = TableData.GetHintById(100213)
end
function UICommunicationPanel:InithatListSubPanel()
  self.mChatListSubPanel:InitCtrl(self.ui.mTrans_ChatList, self)
end
function UICommunicationPanel:OnShowStart()
  self:UpdateRedPoint()
end
function UICommunicationPanel:OnBackFrom()
  if self.mindex > 0 then
    self.ui.mAnimator:SetTrigger("GrpMain_FadeIn")
  else
    self.ui.mAnimator:SetTrigger("GrpEntrance_FadeIn")
  end
end
function UICommunicationPanel:OnTop()
  if self.mindex == self.SUB_PANEL_ID.CHAT_LIST then
    self.mChatListSubPanel:UpdateChatList()
  end
end
function UICommunicationPanel:OnShowFinish()
end
function UICommunicationPanel:OnUpdate()
  if self.ui.mText_Time ~= nil then
    self.ui.mText_Time.text = string.sub(CS.TimeUtils.GetNowTimeHHMMSS(), 1, 5)
  end
end
function UICommunicationPanel:OnCameraStart()
  return 0.01
end
function UICommunicationPanel:OnCameraBack()
  return 0.01
end
function UICommunicationPanel:OnHide()
end
function UICommunicationPanel:OnClose()
  self.tabList = {}
  self.mindex = 0
  self.mFriendSubPanel:OnRelease()
  self.mChatListSubPanel:OnRelease()
  self.mChatContentSubPanel:OnRelease()
  setactive(self.ui.mTrans_GrpEntrance.gameObject, true)
  setactive(self.ui.mTrans_Friend.gameObject, false)
  setactive(self.ui.mTrans_ChatList.gameObject, false)
  setactive(self.ui.mTrans_ChatContent.gameObject, false)
  SceneSys.currentScene:MovePuppy(false)
end
function UICommunicationPanel:OnRelease()
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.ApplyFriend)
  RedPointSystem:GetInstance():RemoveRedPointListener(RedPointConst.Chat)
  MessageSys:RemoveListener(CS.GF2.Message.ChatEvent.UpdateChatList, self.updateChatListFunc)
  MessageSys:RemoveListener(CS.GF2.Message.FriendEvent.FriendChangeMark, self.friendChangeMarkFunc)
end
function UICommunicationPanel:ReturnClicked()
  UIManager.CloseUI(UIDef.UICommunicationPanel)
end
function UICommunicationPanel:InitButtonGroup()
  self.tabList[self.SUB_PANEL_ID.FRIEND] = self.ui.mBtn_Friend.gameObject
  self.tabList[self.SUB_PANEL_ID.CHAT_LIST] = self.ui.mBtn_ChatList.gameObject
  UIUtils.GetButtonListener(self.ui.mBtn_Friend.gameObject).onClick = function()
    self.mFriendSubPanel:OnClickListTab(UIFriendGlobal.ListTab.FriendList)
    self.mFriendSubPanel:OnShowStart()
    self:EnterSubPanel(self.SUB_PANEL_ID.FRIEND)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ChatList.gameObject).onClick = function()
    self:EnterSubPanel(self.SUB_PANEL_ID.CHAT_LIST)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:ReturnClicked()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    self:ReturnClicked()
  end
end
function UICommunicationPanel:EnterSubPanel(index, name)
  local preIndex = self.mindex
  self.mindex = index
  self:RefreshTop(index, name)
  setactive(self.ui.mTrans_GrpEntrance.gameObject, index == 0 or preIndex == 0)
  setactive(self.ui.mTrans_Friend.gameObject, index == self.SUB_PANEL_ID.FRIEND or preIndex == self.SUB_PANEL_ID.FRIEND)
  setactive(self.ui.mTrans_ChatList.gameObject, index == self.SUB_PANEL_ID.CHAT_LIST or preIndex == self.SUB_PANEL_ID.CHAT_LIST)
  setactive(self.ui.mTrans_ChatContent.gameObject, index == self.SUB_PANEL_ID.CHAT_CONTENT or preIndex == self.SUB_PANEL_ID.CHAT_CONTENT)
  local delayTime = 0.5
  if 0 < index then
    if 0 < preIndex then
      self.ui.mAnimator:SetInteger("GrpMain_Switch", index - 1)
      delayTime = 0
    else
      self.ui.mAnimator:SetTrigger("GrpMain_FadeIn")
    end
  else
    self.ui.mAnimator:SetTrigger("GrpEntrance_FadeIn")
  end
  TimerSys:DelayCall(delayTime, function()
    setactive(self.ui.mTrans_GrpEntrance.gameObject, index == 0)
    setactive(self.ui.mTrans_Friend.gameObject, index == self.SUB_PANEL_ID.FRIEND)
    setactive(self.ui.mTrans_ChatList.gameObject, index == self.SUB_PANEL_ID.CHAT_LIST)
    setactive(self.ui.mTrans_ChatContent.gameObject, index == self.SUB_PANEL_ID.CHAT_CONTENT)
  end)
  if index == self.SUB_PANEL_ID.FRIEND then
    self.mChatListSubPanel:RefreshFriendInfoList()
    self.mFriendSubPanel:OnShowStart()
  elseif index == self.SUB_PANEL_ID.CHAT_CONTENT then
    self.mChatContentSubPanel:RegistrationKeyboard(preIndex)
  elseif index == self.SUB_PANEL_ID.CHAT_LIST then
    self.mChatListSubPanel:RefreshNoMessage()
  end
  self:UpdateRedPoint()
end
function UICommunicationPanel:AnimatorSetTrigger(name)
  self.ui.mAnimator:SetTrigger(name)
end
function UICommunicationPanel:RefreshTop(index)
  if index == 0 then
    self.ui.mText_Tittle.text = TableData.GetHintById(100213)
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      self:ReturnClicked()
    end
  elseif index == self.SUB_PANEL_ID.FRIEND then
    self.mFriendSubPanel:RenderTitle()
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      self.mFriendSubPanel:ReturnClicked()
    end
  elseif index == self.SUB_PANEL_ID.CHAT_LIST then
    self.ui.mText_Tittle.text = TableData.GetHintById(100211)
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      self.mChatListSubPanel:ReturnClicked()
    end
  elseif index == self.SUB_PANEL_ID.CHAT_CONTENT then
    UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
      self.mChatContentSubPanel:ReturnClicked()
    end
  end
end
function UICommunicationPanel:OnFriendChangeMark(msg)
  if self.mindex == self.SUB_PANEL_ID.CHAT_CONTENT then
    local friend = NetCmdFriendData:GetFriendDataById(tonumber(msg.Sender))
    if friend then
      self.ui.mText_Tittle.color = ColorUtils.BlueColor4
      self.ui.mText_Tittle.text = friend.Mark
    end
  end
end
