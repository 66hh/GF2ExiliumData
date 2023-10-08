require("UI.UIBaseView")
UIBattleIndexPanelV2View = class("UIBattleIndexPanelV2View", UIBaseView)
UIBattleIndexPanelV2View.__index = UIBattleIndexPanelV2View
function UIBattleIndexPanelV2View:__InitCtrl()
end
function UIBattleIndexPanelV2View:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
