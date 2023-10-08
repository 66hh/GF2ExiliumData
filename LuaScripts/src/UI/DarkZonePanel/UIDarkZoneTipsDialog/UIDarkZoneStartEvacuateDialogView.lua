require("UI.UIBaseView")
UIDarkZoneStartEvacuateDialogView = class("UIDarkZoneStartEvacuateDialogView", UIBaseView)
UIDarkZoneStartEvacuateDialogView.__index = UIDarkZoneStartEvacuateDialogView
function UIDarkZoneStartEvacuateDialogView:__InitCtrl()
end
function UIDarkZoneStartEvacuateDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
