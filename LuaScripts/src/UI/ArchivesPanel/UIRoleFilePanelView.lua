require("UI.UIBaseView")
UIRoleFilePanelView = class("UIRoleFilePanelView", UIBaseView)
UIRoleFilePanelView.__index = UIRoleFilePanelView
function UIRoleFilePanelView:__InitCtrl()
end
function UIRoleFilePanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
