require("UI.UIBaseView")
DarkMainPanelInGameSlotItemView = class("DarkMainPanelInGameSlotItemView", UIBaseView)
DarkMainPanelInGameSlotItemView.__index = DarkMainPanelInGameSlotItemView
function DarkMainPanelInGameSlotItemView:__InitCtrl()
end
function DarkMainPanelInGameSlotItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
