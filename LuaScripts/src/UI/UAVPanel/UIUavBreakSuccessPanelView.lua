require("UI.UIBaseView")
UIUavBreakSuccessPanelView = class("UIUavBreakSuccessPanelView", UIBaseView)
UIUavBreakSuccessPanelView.__index = UIUavBreakSuccessPanelView
function UIUavBreakSuccessPanelView:__InitCtrl()
end
function UIUavBreakSuccessPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
