require("UI.UIBaseView")
UISimCombatRiddlePanelView = class("UISimCombatRiddlePanelView", UIBaseView)
UISimCombatRiddlePanelView.__index = UISimCombatRiddlePanelView
function UISimCombatRiddlePanelView:__InitCtrl()
end
function UISimCombatRiddlePanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
