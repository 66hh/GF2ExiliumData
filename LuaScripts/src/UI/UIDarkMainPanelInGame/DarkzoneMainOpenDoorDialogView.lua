require("UI.UIBaseView")
DarkzoneMainOpenDoorDialogView = class("DarkzoneMainOpenDoorDialogView", UIBaseView)
DarkzoneMainOpenDoorDialogView.__index = DarkzoneMainOpenDoorDialogView
function DarkzoneMainOpenDoorDialogView:__InitCtrl()
end
function DarkzoneMainOpenDoorDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
