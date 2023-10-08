require("UI.UIBaseView")
DarkzoneInteractiveTipsItemView = class("DarkzoneInteractiveTipsItemView", UIBaseView)
DarkzoneInteractiveTipsItemView.__index = DarkzoneInteractiveTipsItemView
function DarkzoneInteractiveTipsItemView:__InitCtrl()
end
function DarkzoneInteractiveTipsItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
