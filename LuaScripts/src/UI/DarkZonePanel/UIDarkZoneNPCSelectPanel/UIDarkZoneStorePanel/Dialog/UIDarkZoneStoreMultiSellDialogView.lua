require("UI.UIBaseView")
UIDarkZoneStoreMultiSellDialogView = class("UIDarkZoneStoreMultiSellDialogView", UIBaseView)
UIDarkZoneStoreMultiSellDialogView.__index = UIDarkZoneStoreMultiSellDialogView
function UIDarkZoneStoreMultiSellDialogView:__InitCtrl()
end
function UIDarkZoneStoreMultiSellDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
