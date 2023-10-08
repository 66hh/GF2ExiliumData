require("UI.UIBaseView")
UIDarkBagPanelView = class("UIDarkBagPanelView", UIBaseView)
UIDarkBagPanelView.__index = UIDarkBagPanelView
local self = UIDarkBagPanelView
function UIDarkBagPanelView:__InitCtrl()
end
function UIDarkBagPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
