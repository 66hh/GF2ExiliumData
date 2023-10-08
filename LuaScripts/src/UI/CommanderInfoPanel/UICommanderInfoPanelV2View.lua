require("UI.UIBaseView")
UICommanderInfoPanelV2View = class("UICommanderInfoPanelV2View", UIBaseView)
UICommanderInfoPanelV2View.__index = UICommanderInfoPanelV2View
function UICommanderInfoPanelV2View:__InitCtrl()
end
function UICommanderInfoPanelV2View:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:__InitCtrl()
  self:LuaUIBindTable(root, uiTable)
end
