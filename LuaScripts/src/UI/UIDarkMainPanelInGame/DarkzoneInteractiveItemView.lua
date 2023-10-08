require("UI.UIBaseView")
DarkzoneInteractiveItemView = class("DarkzoneInteractiveItemView", UIBaseView)
DarkzoneInteractiveItemView.__index = DarkzoneInteractiveItemView
function DarkzoneInteractiveItemView:__InitCtrl()
end
function DarkzoneInteractiveItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
