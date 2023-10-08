require("UI.UIBaseView")
UIDarkZoneRepositoryBuyDialogView = class("UIDarkZoneRepositoryBuyDialogView", UIBaseView)
UIDarkZoneRepositoryBuyDialogView.__index = UIDarkZoneRepositoryBuyDialogView
function UIDarkZoneRepositoryBuyDialogView:__InitCtrl()
end
function UIDarkZoneRepositoryBuyDialogView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
