require("UI.UIBaseView")
UISimCombatTutorialEntrancePanelView = class("UISimCombatTutorialEntrancePanelView", UIBaseView)
UISimCombatTutorialEntrancePanelView.__index = UISimCombatTutorialEntrancePanelView
function UISimCombatTutorialEntrancePanelView:__InitCtrl()
end
function UISimCombatTutorialEntrancePanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
