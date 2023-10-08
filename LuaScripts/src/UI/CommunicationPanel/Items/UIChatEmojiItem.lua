require("UI.UIBaseCtrl")
UIChatEmojiItem = class("UIChatEmojiItem", UIBaseCtrl)
UIChatEmojiItem.__index = UIChatEmojiItem
function UIChatEmojiItem:ctor()
end
function UIChatEmojiItem:InitCtrl()
  local obj = instantiate(UIUtils.GetGizmosPrefab("Chat/Btn_ChatEmojiItem.prefab", self))
  self:SetRoot(obj.transform)
  self.ui = {}
  self:LuaUIBindTable(self.mUIRoot, self.ui)
  self:__InitCtrl()
end
function UIChatEmojiItem:__InitCtrl()
end
function UIChatEmojiItem:SetData(data)
  self.ui.mImg_Emoji.sprite = IconUtils.GetEmojiIcon(data.icon)
end
