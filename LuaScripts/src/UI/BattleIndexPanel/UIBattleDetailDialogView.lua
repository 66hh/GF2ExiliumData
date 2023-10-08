require("UI.UIBaseView")
UIBattleDetailDialogView = class("UIBattleDetailDialogView", UIBaseView)
UIBattleDetailDialogView.__index = UIBattleDetailDialogView
function UIBattleDetailDialogView:__InitCtrl(uiTable)
  uiTable.mText_BattleHint = UIUtils.GetText(uiTable.mBtn_Start.transform, "Root/GrpText/Text_Name")
end
function UIBattleDetailDialogView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl(uiTable)
end
