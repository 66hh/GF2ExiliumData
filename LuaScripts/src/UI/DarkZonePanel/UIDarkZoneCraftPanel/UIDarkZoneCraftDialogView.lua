UIDarkZoneCraftDialogView = class("UIDarkZoneCraftDialogView", UIBaseView)
UIDarkZoneCraftDialogView.__index = UIDarkZoneCraftDialogView
function UIDarkZoneCraftDialogView:__InitCtrl()
end
function UIDarkZoneCraftDialogView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
