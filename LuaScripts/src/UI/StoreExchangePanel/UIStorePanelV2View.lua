UIStorePanelV2View = class("UIStorePanelV2View", UIBaseView)
UIStorePanelV2View.__index = UIStorePanelV2View
function UIStorePanelV2View:__InitCtrl()
end
function UIStorePanelV2View:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
