require("UI.UIBaseView")
DarkMainPanelInGameBuffItemView = class("DarkMainPanelInGameBuffItemView", UIBaseView)
DarkMainPanelInGameBuffItemView.__index = DarkMainPanelInGameBuffItemView
function DarkMainPanelInGameBuffItemView:__InitCtrl()
end
function DarkMainPanelInGameBuffItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
