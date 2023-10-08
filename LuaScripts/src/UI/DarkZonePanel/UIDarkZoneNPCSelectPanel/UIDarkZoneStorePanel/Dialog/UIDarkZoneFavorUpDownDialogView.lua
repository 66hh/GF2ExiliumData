require("UI.UIBaseView")
UIDarkZoneFavorUpDownDialogView = class("UIDarkZoneFavorUpDownDialogView", UIBaseView)
UIDarkZoneFavorUpDownDialogView.__index = UIDarkZoneFavorUpDownDialogView
function UIDarkZoneFavorUpDownDialogView:__InitCtrl()
end
function UIDarkZoneFavorUpDownDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
