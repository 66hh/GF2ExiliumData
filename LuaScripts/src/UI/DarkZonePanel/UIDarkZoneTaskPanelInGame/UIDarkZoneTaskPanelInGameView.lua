require("UI.UIBaseView")
UIDarkZoneTaskPanelInGameView = class("UIDarkZoneMainPanelView", UIBaseView)
UIDarkZoneTaskPanelInGameView.__index = UIDarkZoneTaskPanelInGameView
function UIDarkZoneTaskPanelInGameView:__InitCtrl()
end
function UIDarkZoneTaskPanelInGameView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
