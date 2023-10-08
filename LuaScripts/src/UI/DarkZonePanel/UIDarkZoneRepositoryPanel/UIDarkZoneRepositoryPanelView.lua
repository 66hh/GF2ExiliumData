require("UI.UIBaseView")
UIDarkZoneRepositoryPanelView = class("UIDarkZoneRepositoryPanelView", UIBaseView)
UIDarkZoneRepositoryPanelView.__index = UIDarkZoneRepositoryPanelView
function UIDarkZoneRepositoryPanelView:__InitCtrl()
end
function UIDarkZoneRepositoryPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
