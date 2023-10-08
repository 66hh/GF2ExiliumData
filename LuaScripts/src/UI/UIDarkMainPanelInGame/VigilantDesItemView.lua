require("UI.UIBaseView")
VigilantDesItemView = class("VigilantDesItemView", UIBaseView)
VigilantDesItemView.__index = VigilantDesItemView
function VigilantDesItemView:__InitCtrl()
end
function VigilantDesItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
