require("UI.UIBaseView")
UIComTodayTipsDialogView = class("UIComTodayTipsDialogView", UIBaseView)
UIComTodayTipsDialogView.__index = UIComTodayTipsDialogView
function UIComTodayTipsDialogView:__InitCtrl()
end
function UIComTodayTipsDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
