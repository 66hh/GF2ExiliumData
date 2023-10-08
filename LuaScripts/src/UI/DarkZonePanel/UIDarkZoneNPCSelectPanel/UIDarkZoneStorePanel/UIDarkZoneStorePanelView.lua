require("UI.UIBaseView")
UIDarkZoneStorePanelView = class("UIDarkZoneStorePanelView", UIBaseView)
UIDarkZoneStorePanelView.__index = UIDarkZoneStorePanelView
function UIDarkZoneStorePanelView:__InitCtrl()
end
function UIDarkZoneStorePanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
