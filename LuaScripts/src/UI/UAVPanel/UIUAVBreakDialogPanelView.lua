require("UI.UIBaseView")
UIUAVBreakDialogPanelView = class("UIUAVBreakDialogPanelView", UIBaseView)
UIUAVBreakDialogPanelView.__index = UIUAVBreakDialogPanelView
function UIUAVBreakDialogPanelView:__InitCtrl()
end
function UIUAVBreakDialogPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:__InitCtrl()
  self:LuaUIBindTable(root, uitable)
end
