UIComDiamondExchangeDialogView = class("UIComDiamondExchangeDialogView", UIBaseView)
UIComDiamondExchangeDialogView.__index = UIComDiamondExchangeDialogView
function UIComDiamondExchangeDialogView:__InitCtrl()
end
function UIComDiamondExchangeDialogView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
