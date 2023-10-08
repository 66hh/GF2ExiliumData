require("UI.UIBaseView")
DarkMainPanelInGameQuickItemView = class("DarkMainPanelInGameQuickItemView", UIBaseView)
DarkMainPanelInGameQuickItemView.__index = DarkMainPanelInGameQuickItemView
function DarkMainPanelInGameQuickItemView:__InitCtrl()
end
function DarkMainPanelInGameQuickItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
