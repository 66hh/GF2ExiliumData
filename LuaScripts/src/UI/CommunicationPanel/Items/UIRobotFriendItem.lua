require("UI.UIBaseCtrl")
UIRobotFriendItem = class("UIRobotFriendItem", UIBaseCtrl)
UIRobotFriendItem.__index = UIRobotFriendItem
function UIRobotFriendItem:ctor()
  UIRobotFriendItem.super.ctor(self)
  self.robotData = nil
  self.titleObj = nil
end
function UIRobotFriendItem:__InitCtrl()
end
function UIRobotFriendItem:InitCtrl(root, parent)
  local obj = instantiate(UIUtils.GetGizmosPrefab("Chat/Btn_ChatFriendListItem.prefab", self), root)
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self.mParent = parent
  self.titleObj = instantiate(UIUtils.GetGizmosPrefab("UICommonFramework/ComReputationTitleItem_S.prefab", self), self.ui.mTrans_Title)
  self:__InitCtrl()
end
function UIRobotFriendItem:OnRelease()
end
function UIRobotFriendItem:SetData(data)
  self.robotData = data
  setactive(self.ui.mTrans_MoreNote, false)
  setactive(self.ui.mBtn_More, false)
  setactive(self.ui.mTrans_GrpInfo, true)
  setactive(self.ui.mTrans_StateText, true)
  setactive(self.ui.mText_Time, false)
  self.ui.mText_ChrName.text = self.robotData.name
  self.ui.mImg_Avatar.sprite = IconUtils.GetPlayerAvatar(self.robotData.head_icon)
  setactive(self.ui.mTrans_Title, self.robotData.title ~= nil and self.robotData.title ~= 0)
  self.titleObj.transform:GetChild(1):GetComponent("Text").text = TableData.listIdcardTitleDatas:GetDataById(self.robotData.title).title.str
  UIUtils.GetButtonListener(self.ui.mBtn_self.gameObject).onClick = function()
    self.mParent:HideAllNote()
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
