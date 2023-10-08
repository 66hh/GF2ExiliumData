require("UI.UIBaseView")
UIDarkZoneStoreBuyDialogView = class("UIDarkZoneStoreBuyDialogView", UIBaseView)
UIDarkZoneStoreBuyDialogView.__index = UIDarkZoneStoreBuyDialogView
function UIDarkZoneStoreBuyDialogView:__InitCtrl()
end
function UIDarkZoneStoreBuyDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
