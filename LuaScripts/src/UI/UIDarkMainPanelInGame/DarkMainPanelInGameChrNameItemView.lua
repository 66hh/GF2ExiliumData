require("UI.UIBaseView")
DarkMainPanelInGameChrNameItemView = class("DarkMainPanelInGameChrNameItemView", UIBaseView)
DarkMainPanelInGameChrNameItemView.__index = DarkMainPanelInGameChrNameItemView
function DarkMainPanelInGameChrNameItemView:__InitCtrl()
end
function DarkMainPanelInGameChrNameItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
