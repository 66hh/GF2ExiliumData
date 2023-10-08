require("UI.UIBaseView")
UIGashaponChrTryDialogView = class("UIGashaponChrTryDialog", UIBaseView)
UIGashaponChrTryDialogView.__index = UIGashaponChrTryDialogView
function UIGashaponChrTryDialogView:ctor()
end
function UIGashaponChrTryDialogView:__InitCtrl()
end
function UIGashaponChrTryDialogView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
