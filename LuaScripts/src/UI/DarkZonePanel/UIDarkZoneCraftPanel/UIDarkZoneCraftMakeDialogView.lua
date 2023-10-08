UIDarkZoneCraftMakeDialogView = class("UIDarkZoneCraftMakeDialogView", UIBaseView)
UIDarkZoneCraftMakeDialogView.__index = UIDarkZoneCraftMakeDialogView
function UIDarkZoneCraftMakeDialogView:__InitCtrl()
end
function UIDarkZoneCraftMakeDialogView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
