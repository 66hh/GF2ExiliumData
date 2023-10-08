UIStoreBoxBuyDialogView = class("UIStoreBoxBuyDialogView", UIBaseView)
UIStoreBoxBuyDialogView.__index = UIStoreBoxBuyDialogView
function UIStoreBoxBuyDialogView:__InitCtrl()
end
function UIStoreBoxBuyDialogView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
