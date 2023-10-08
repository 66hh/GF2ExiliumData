require("UI.UIBaseCtrl")
UIChatInfoItem = class("UIChatInfoItem ", UIBaseCtrl)
UIChatInfoItem.__index = UIChatInfoItem
function UIChatInfoItem:ctor()
end
function UIChatInfoItem:InitCtrl(parent, content)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Chat/Btn_ChatInfoItem.prefab", self), content)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mParent = parent
  self:__InitCtrl()
end
function UIChatInfoItem:__InitCtrl()
end
function UIChatInfoItem:SetData(data)
  self.playerInfo = data
  if NetCmdChatData:IsRecChatDetail(self.playerInfo.UID) then
    self.chatData = NetCmdChatData:GetChatDataById(self.playerInfo.UID)
  else
    NetCmdChatData:SendGetChatDetail(self.playerInfo.UID, function()
      MessageSys:SendMessage(CS.GF2.Message.ChatEvent.AddChatChannel, self.playerInfo.UID)
    end)
    return
  end
  setactive(self.ui.mRedPoint, NetCmdChatData:NeedShowRedPoint(self.playerInfo.UID))
  UIUtils.GetButtonListener(self.ui.mBtn_ChatInfo.gameObject).onClick = function()
    setactive(self.ui.mRedPoint, false)
    self.mParent.mParent.mChatContentSubPanel:InitCtrl(self.mParent.mParent.ui.mTrans_ChatContent, self.mParent, self.playerInfo, UICommunicationGlobal.ChatType.Friend)
    self.mParent.mParent:EnterSubPanel(self.mParent.mParent.SUB_PANEL_ID.CHAT_CONTENT)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Avatar.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
      self.playerInfo
    })
  end
  if self.playerInfo.Mark == "" or self.playerInfo.Mark == nil then
    self.ui.mText_Name.text = self.playerInfo.Name
    self.ui.mText_Name.color = Color.white
  else
    self.ui.mText_Name.text = self.playerInfo.Mark
    self.ui.mText_Name.color = ColorUtils.BlueColor4
  end
  self.ui.mImg_Avator.sprite = IconUtils.GetPlayerAvatar(self.playerInfo.Icon)
  local text
  if self.chatData.messageList[self.chatData.messageList.Count - 1].bpMessage ~= nil then
    text = TableData.GetHintById(192080)
  elseif self.chatData.messageList[self.chatData.messageList.Count - 1].message ~= "" then
    text = self.chatData.messageList[self.chatData.messageList.Count - 1].message
  else
    text = TableData.GetHintById(100112)
  end
  self.ui.mText_Info.text = text
  local time = self.chatData.messageList[self.chatData.messageList.Count - 1]:TranslationLastTime()
  self.ui.mText_Time.text = time
end
