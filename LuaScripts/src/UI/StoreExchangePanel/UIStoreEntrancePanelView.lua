UIStoreEntrancePanelView = class("UIStoreEntrancePanelView", UIBaseView)
UIStoreEntrancePanelView.__index = UIStoreEntrancePanelView
function UIStoreEntrancePanelView:__InitCtrl()
end
function UIStoreEntrancePanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
