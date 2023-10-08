require("UI.UIBaseView")
UIDarkZoneTeamPanelView = class("UIDarkZoneTeamPanelView", UIBaseView)
UIDarkZoneTeamPanelView.__index = UIDarkZoneTeamPanelView
function UIDarkZoneTeamPanelView:__InitCtrl()
end
function UIDarkZoneTeamPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
