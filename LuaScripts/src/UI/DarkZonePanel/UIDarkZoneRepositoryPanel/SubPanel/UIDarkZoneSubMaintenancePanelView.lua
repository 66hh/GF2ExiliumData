require("UI.UIBasePanel")
UIDarkZoneSubMaintenancePanelView = class("UIDarkZoneSubMaintenancePanel", UIBaseView)
UIDarkZoneSubMaintenancePanelView.__index = UIDarkZoneSubMaintenancePanelView
function UIDarkZoneSubMaintenancePanelView:__InitCtrl()
end
function UIDarkZoneSubMaintenancePanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
