require("UI.UIBaseCtrl")
UIItemSample = class("UIItemSample", UIBaseCtrl)
UIItemSample.__index = UIItemSample
function UIItemSample:ctor()
  UIItemSample.super.ctor(self)
end
function UIItemSample:InitCtrl(root)
  self:SetRoot(root)
end
