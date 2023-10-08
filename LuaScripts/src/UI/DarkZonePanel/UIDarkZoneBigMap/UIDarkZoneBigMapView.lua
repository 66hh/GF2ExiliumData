require("UI.UIBaseView")
UIDarkZoneBigMapView = class("UIDarkZoneMainPanelView", UIBaseView)
UIDarkZoneBigMapView.__index = UIDarkZoneBigMapView
function UIDarkZoneBigMapView:__InitCtrl()
end
function UIDarkZoneBigMapView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
