require("UI.UIBaseView")
UISimCombatTutorialChapterPanelView = class("UISimCombatTutorialChapterPanelView", UIBaseView)
UISimCombatTutorialChapterPanelView.__index = UISimCombatTutorialChapterPanelView
function UISimCombatTutorialChapterPanelView:__InitCtrl()
end
function UISimCombatTutorialChapterPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
