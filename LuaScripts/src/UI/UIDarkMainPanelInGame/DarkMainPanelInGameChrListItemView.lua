require("UI.UIBaseView")
DarkMainPanelInGameChrListItemView = class("DarkMainPanelInGameChrListItemView", UIBaseView)
DarkMainPanelInGameChrListItemView.__index = DarkMainPanelInGameChrListItemView
function DarkMainPanelInGameChrListItemView:__InitCtrl()
end
function DarkMainPanelInGameChrListItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
