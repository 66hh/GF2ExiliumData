require("UI.UIBaseView")
UIDarkMainPanelInGameView = class("UIDarkMainPanelInGameView", UIBaseView)
UIDarkMainPanelInGameView.__index = UIDarkMainPanelInGameView
function UIDarkMainPanelInGameView:__InitCtrl()
end
function UIDarkMainPanelInGameView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
