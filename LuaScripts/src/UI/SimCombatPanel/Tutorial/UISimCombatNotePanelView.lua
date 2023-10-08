require("UI.UIBaseView")
UISimCombatNotePanelView = class("UISimCombatNotePanelView", UIBaseView)
UISimCombatNotePanelView.__index = UISimCombatNotePanelView
function UISimCombatNotePanelView:__InitCtrl()
end
function UISimCombatNotePanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
