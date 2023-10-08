require("UI.UIBaseView")
DarkzoneMakeItemDialogView = class("DarkzoneMakeItemDialogView", UIBaseView)
DarkzoneMakeItemDialogView.__index = DarkzoneMakeItemDialogView
function DarkzoneMakeItemDialogView:__InitCtrl()
end
function DarkzoneMakeItemDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
