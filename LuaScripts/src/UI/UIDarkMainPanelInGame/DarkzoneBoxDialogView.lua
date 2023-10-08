require("UI.UIBaseView")
DarkzoneBoxDialogView = class("DarkzoneBoxDialogView", UIBaseView)
DarkzoneBoxDialogView.__index = DarkzoneBoxDialogView
function DarkzoneBoxDialogView:__InitCtrl()
end
function DarkzoneBoxDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
