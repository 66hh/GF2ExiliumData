require("UI.UIBaseCtrl")
UIBaseView = class("UIBaseView", UIBaseCtrl)
UIBaseView.__index = UIBaseView
function UIBaseView:ctor()
  UIBaseView.super.ctor(self)
end
