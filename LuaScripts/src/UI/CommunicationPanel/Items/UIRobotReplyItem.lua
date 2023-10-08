require("UI.UIBaseCtrl")
UIRobotReplyItem = class("UIRobotReplyItem", UIBaseCtrl)
UIRobotReplyItem.__index = UIRobotReplyItem
function UIRobotReplyItem:ctor()
  self.contentId = 0
  self.replyId = 0
  self.robotChatType = UICommunicationGlobal.RobotChatKind.None
end
function UIRobotReplyItem:__InitCtrl()
end
function UIRobotReplyItem:InitCtrl(parent, isSelfTheme)
  local obj
  if isSelfTheme then
    obj = instantiate(UIUtils.GetGizmosPrefab("Chat/Btn_ChatAutomaticItem.prefab", self), parent)
  else
    obj = instantiate(UIUtils.GetGizmosPrefab("Chat/Btn_RobotQuoteItem.prefab", self), parent)
  end
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIRobotReplyItem:OnRelease()
end
function UIRobotReplyItem:SetData(text, contentId, replyId, groupId)
  self.ui.mText_Reply.text = text
  self.contentId = contentId
  self.replyId = replyId
  self.groupId = groupId
  self.robotChatType = UICommunicationGlobal.RobotChatKind.Common
end
