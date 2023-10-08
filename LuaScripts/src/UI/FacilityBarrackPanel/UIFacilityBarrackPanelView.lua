require("UI.UIBaseView")
UIFacilityBarrackPanelView = class("UIFacilityBarrackPanelView", UIBaseView)
UIFacilityBarrackPanelView.__index = UIFacilityBarrackPanelView
function UIFacilityBarrackPanelView:__InitCtrl()
end
function UIFacilityBarrackPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
