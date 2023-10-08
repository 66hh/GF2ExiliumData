require("UI.UIBaseView")
UIGachaSkipPanelView = class("UIGachaSkipPanelView", UIBaseView)
UIGachaSkipPanelView.__index = UIGachaSkipPanelView
function UIGachaSkipPanelView:__InitCtrl()
end
function UIGachaSkipPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
