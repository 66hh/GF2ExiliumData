require("UI.UIBaseView")
UIGachaResultPanelV2View = class("UIGachaResultPanelV2View", UIBaseView)
UIGachaResultPanelV2View.__index = UIGachaResultPanelV2View
function UIGachaResultPanelV2View:__InitCtrl()
end
function UIGachaResultPanelV2View:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
