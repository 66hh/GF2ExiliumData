require("UI.UIBaseView")
UIGachaDialogPanelView = class("UIGachaDialogPanel", UIBaseView)
UIGachaDialogPanelView.__index = UIGachaDialogPanelView
function UIGachaDialogPanelView:ctor()
end
function UIGachaDialogPanelView:__InitCtrl()
end
function UIGachaDialogPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
