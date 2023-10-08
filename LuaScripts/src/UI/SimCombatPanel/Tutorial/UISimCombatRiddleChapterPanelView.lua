require("UI.UIBaseView")
UISimCombatRiddleChapterPanelView = class("UISimCombatRiddleChapterPanelView", UIBaseView)
UISimCombatRiddleChapterPanelView.__index = UISimCombatRiddleChapterPanelView
function UISimCombatRiddleChapterPanelView:__InitCtrl()
end
function UISimCombatRiddleChapterPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
