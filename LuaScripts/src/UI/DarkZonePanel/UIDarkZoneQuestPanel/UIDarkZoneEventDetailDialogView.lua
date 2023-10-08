require("UI.UIBaseView")
UIDarkZoneEventDetailDialogView = class("UIDarkZoneEventDetailDialogView", UIBaseView)
UIDarkZoneEventDetailDialogView.__index = UIDarkZoneEventDetailDialogView
function UIDarkZoneEventDetailDialogView:__InitCtrl()
end
function UIDarkZoneEventDetailDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
