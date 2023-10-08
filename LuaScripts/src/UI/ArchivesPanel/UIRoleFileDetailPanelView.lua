require("UI.UIBaseView")
UIRoleFileDetailPanelView = class("UIRoleFileDetailPanelView", UIBaseView)
UIRoleFileDetailPanelView.__index = UIRoleFileDetailPanelView
function UIRoleFileDetailPanelView:__InitCtrl()
end
function UIRoleFileDetailPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
