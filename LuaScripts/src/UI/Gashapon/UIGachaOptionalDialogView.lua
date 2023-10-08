require("UI.UIBaseView")
UIGachaOptionalDialogView = class("UIGachaOptionalDialog", UIBaseView)
UIGachaOptionalDialogView.__index = UIGachaOptionalDialogView
function UIGachaOptionalDialogView:ctor()
end
function UIGachaOptionalDialogView:__InitCtrl()
end
function UIGachaOptionalDialogView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
