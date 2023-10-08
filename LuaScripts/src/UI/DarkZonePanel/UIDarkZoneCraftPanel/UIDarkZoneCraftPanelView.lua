UIDarkZoneCraftPanelView = class("UIDarkZoneCraftPanelView", UIBaseView)
UIDarkZoneCraftPanelView.__index = UIDarkZoneCraftPanelView
function UIDarkZoneCraftPanelView:__InitCtrl()
end
function UIDarkZoneCraftPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
