require("UI.UIBaseView")
UIDarkZoneMessageDialogView = class("UIDarkZoneMessageDialogView", UIBaseView)
UIDarkZoneMessageDialogView.__index = UIDarkZoneMessageDialogView
function UIDarkZoneMessageDialogView:__InitCtrl()
end
function UIDarkZoneMessageDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
