require("UI.UIBaseView")
DarkzoneBuffDialogView = class("DarkzoneBuffDialogView", UIBaseView)
DarkzoneBuffDialogView.__index = DarkzoneBuffDialogView
function DarkzoneBuffDialogView:__InitCtrl()
end
function DarkzoneBuffDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
