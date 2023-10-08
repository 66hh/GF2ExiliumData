require("UI.UIBaseView")
UIDarkzoneAttackDialogView = class("UIDarkzoneAttackDialogView", UIBaseView)
UIDarkzoneAttackDialogView.__index = UIDarkzoneAttackDialogView
function UIDarkzoneAttackDialogView:__InitCtrl()
end
function UIDarkzoneAttackDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
