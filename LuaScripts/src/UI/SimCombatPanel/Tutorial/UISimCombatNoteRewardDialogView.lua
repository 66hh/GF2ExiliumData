require("UI.UIBaseView")
UISimCombatNoteRewardDialogView = class("UISimCombatNoteRewardDialogView", UIBaseView)
UISimCombatNoteRewardDialogView.__index = UISimCombatNoteRewardDialogView
function UISimCombatNoteRewardDialogView:__InitCtrl()
end
function UISimCombatNoteRewardDialogView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
