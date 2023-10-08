require("UI.UIBaseView")
UIDarkzoneMatchDialogView = class("UIDarkzoneMatchDialogView", UIBaseView)
UIDarkzoneMatchDialogView.__index = UIDarkzoneMatchDialogView
function UIDarkzoneMatchDialogView:__InitCtrl()
end
function UIDarkzoneMatchDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
