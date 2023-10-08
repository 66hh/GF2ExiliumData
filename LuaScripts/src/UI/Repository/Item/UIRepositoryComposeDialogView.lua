require("UI.UIBaseView")
UIRepositoryComposeDialogView = class("UIRepositoryComposeDialogView", UIBaseView)
UIRepositoryComposeDialogView.__index = UIRepositoryComposeDialogView
function UIRepositoryComposeDialogView:__InitCtrl()
end
function UIRepositoryComposeDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
