require("UI.UIBaseView")
UIMailPanelV2View = class("UIMailPanelV2View", UIBaseView)
UIMailPanelV2View.__index = UIMailPanelV2View
function UIMailPanelV2View:__InitCtrl()
end
function UIMailPanelV2View:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
