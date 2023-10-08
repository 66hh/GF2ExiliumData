require("UI.UIBaseView")
UIViewSample = class("UIViewSample", UIBaseView)
UIViewSample.__index = UIViewSample
function UIViewSample:ctor()
  UIViewSample.super.ctor(self)
end
function UIViewSample:InitCtrl(root)
  self:SetRoot(root)
end
