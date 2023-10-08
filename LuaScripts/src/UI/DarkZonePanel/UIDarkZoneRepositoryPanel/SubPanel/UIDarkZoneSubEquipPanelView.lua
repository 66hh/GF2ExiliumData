require("UI.UIBasePanel")
UIDarkZoneSubEquipPanelView = class("UIDarkZoneSubEquipPanel", UIBaseView)
UIDarkZoneSubEquipPanelView.__index = UIDarkZoneSubEquipPanelView
function UIDarkZoneSubEquipPanelView:__InitCtrl()
end
function UIDarkZoneSubEquipPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
