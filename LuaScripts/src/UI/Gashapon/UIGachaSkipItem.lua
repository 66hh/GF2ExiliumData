require("UI.UIBaseCtrl")
UIGachaSkipItem = class("UIGachaSkipItem", UIBaseCtrl)
UIGachaSkipItem.__index = UIGachaSkipItem
UIGachaSkipItem.mBtn_Skip = nil
function UIGachaSkipItem:__InitCtrl()
  self.mBtn_Skip = self:GetButton("Btn_Skip")
end
function UIGachaSkipItem:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
