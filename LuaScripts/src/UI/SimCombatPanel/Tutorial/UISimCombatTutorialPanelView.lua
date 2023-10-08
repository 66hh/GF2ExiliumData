require("UI.UIBaseView")
UISimCombatTutorialPanelView = class("UISimCombatTutorialPanelView", UIBaseView)
UISimCombatTutorialPanelView.__index = UISimCombatTutorialPanelView
function UISimCombatTutorialPanelView:__InitCtrl()
end
function UISimCombatTutorialPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
