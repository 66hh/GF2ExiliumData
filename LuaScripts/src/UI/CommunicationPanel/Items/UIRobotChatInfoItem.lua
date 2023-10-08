require("UI.UIBaseCtrl")
UIRobotChatInfoItem = class("UIRobotChatInfoItem", UIBaseCtrl)
UIRobotChatInfoItem.__index = UIRobotChatInfoItem
function UIRobotChatInfoItem:ctor()
end
function UIRobotChatInfoItem:InitCtrl(root, parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Chat/Btn_ChatInfoItem.prefab", self), root)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mParent = parent
  self:__InitCtrl()
end
function UIRobotChatInfoItem:__InitCtrl()
end
function UIRobotChatInfoItem:SetData(data, chatData)
  self.robotData = data
  self.chatData = chatData
  self.ui.mImg_Avator.sprite = IconUtils.GetPlayerAvatar(self.robotData.head_icon)
  self.ui.mText_Name.text = self.robotData.name
  if self.chatData and self.chatData.robotMessageList.Count ~= 0 then
    local aiContentData = TableData.listAiChatContentDatas:GetDataById(self.chatData.robotMessageList[self.chatData.robotMessageList.Count - 1].sentanceId)
    self.ui.mText_Info.text = aiContentData.content
    self.ui.mText_Time.text = self.chatData.robotMessageList[self.chatData.robotMessageList.Count - 1]:TranslationLastTime()
  end
  setactive(self.ui.mRedPoint, NetCmdChatData:RobotNeedShowRedPoint(1))
  UIUtils.GetButtonListener(self.ui.mBtn_ChatInfo.gameObject).onClick = function()
    setactive(self.ui.mRedPoint, false)
    self.mParent.mParent.mChatContentSubPanel:InitCtrl(self.mParent.mParent.ui.mTrans_ChatContent, self.mParent, self.robotData, UICommunicationGlobal.ChatType.Robot)
    self.mParent.mParent:EnterSubPanel(self.mParent.mParent.SUB_PANEL_ID.CHAT_CONTENT)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Avatar.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIPlayerInfoDialog, {
      AccountNetCmdHandler:GetRoleInfoData(),
      self.robotData
    })
  end
end
function UIRobotChatInfoItem:SetRedPoint(isActive)
  setactive(self.ui.mRedPoint, isActive)
end
