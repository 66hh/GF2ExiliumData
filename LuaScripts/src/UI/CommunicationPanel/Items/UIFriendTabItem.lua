require("UI.UIBaseCtrl")
UIFriendTabItem = class("UIFriendTabItem", UIBaseCtrl)
UIFriendTabItem.__index = UIFriendTabItem
function UIFriendTabItem:ctor()
  self.tabId = 0
  self.virtualList = nil
  self.isFirstClick = true
  self.canBeEmpty = false
end
function UIFriendTabItem:__InitCtrl()
end
function UIFriendTabItem:InitCtrl(btn_Object)
  self:SetRoot(btn_Object.gameObject.transform)
  self:__InitCtrl()
  self.mBtn_Select = btn_Object
end
function UIFriendTabItem:OnRelease()
end
function UIFriendTabItem:SetData(tagId, virtualList)
  self.tabId = tagId
  self.virtualList = virtualList
end
function UIFriendTabItem:SetSelect(isSelcet)
  self.mBtn_Select.interactable = not isSelcet
end
function UIFriendTabItem:SetIsFirstClick(isFirst)
  self.isFirstClick = isFirst
end
