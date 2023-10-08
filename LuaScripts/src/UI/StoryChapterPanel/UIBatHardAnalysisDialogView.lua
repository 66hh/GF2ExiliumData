require("UI.UIBaseView")
UIBatHardAnalysisDialogView = class("UIBatHardAnalysisDialogView", UIBaseView)
UIBatHardAnalysisDialogView.__index = UIBatHardAnalysisDialogView
function UIBatHardAnalysisDialogView:__InitCtrl()
end
function UIBatHardAnalysisDialogView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
