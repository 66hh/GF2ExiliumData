UIDarkZonePropertyDetailDialogView = class("UIDarkZonePropertyDetailDialogView", UIBaseView)
UIDarkZonePropertyDetailDialogView.__index = UIDarkZonePropertyDetailDialogView
function UIDarkZonePropertyDetailDialogView:__InitCtrl()
end
function UIDarkZonePropertyDetailDialogView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
