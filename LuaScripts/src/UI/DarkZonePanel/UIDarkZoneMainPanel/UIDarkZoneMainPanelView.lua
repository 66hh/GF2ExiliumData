require("UI.UIBaseView")
UIDarkZoneMainPanelView = class("UIDarkZoneMainPanelView", UIBaseView)
UIDarkZoneMainPanelView.__index = UIDarkZoneMainPanelView
function UIDarkZoneMainPanelView:__InitCtrl()
end
function UIDarkZoneMainPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
