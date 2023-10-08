require("UI.UIBaseView")
UIDarkZoneRepositoryExistDialogView = class("UIDarkZoneRepositoryExistDialogView", UIBaseView)
UIDarkZoneRepositoryExistDialogView.__index = UIDarkZoneRepositoryExistDialogView
function UIDarkZoneRepositoryExistDialogView:__InitCtrl()
end
function UIDarkZoneRepositoryExistDialogView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
