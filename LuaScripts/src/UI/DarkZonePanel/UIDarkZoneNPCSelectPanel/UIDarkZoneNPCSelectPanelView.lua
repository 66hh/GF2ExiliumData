require("UI.UIBaseView")
UIDarkZoneNPCSelectPanelView = class("UIDarkZoneNPCSelectPanelView", UIBaseView)
UIDarkZoneNPCSelectPanelView.__index = UIDarkZoneNPCSelectPanelView
function UIDarkZoneNPCSelectPanelView:__InitCtrl()
end
function UIDarkZoneNPCSelectPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
