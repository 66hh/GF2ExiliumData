require("UI.UIBaseView")
UIRepositoryBoxDialogView = class("UIRepositoryBoxDialogView", UIBaseView)
UIRepositoryBoxDialogView.__index = UIRepositoryBoxDialogView
function UIRepositoryBoxDialogView:__InitCtrl()
end
function UIRepositoryBoxDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
