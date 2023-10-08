require("UI.UIBaseView")
UIDarkZoneMapSelectPanelView = class("UIDarkZoneMapSelectPanelView", UIBaseView)
UIDarkZoneMapSelectPanelView.__index = UIDarkZoneMapSelectPanelView
function UIDarkZoneMapSelectPanelView:__InitCtrl()
end
function UIDarkZoneMapSelectPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
