require("UI.UIBaseView")
UIDarkZoneStoreQuoteDialogView = class("UIDarkZoneStoreQuoteDialogView", UIBaseView)
UIDarkZoneStoreQuoteDialogView.__index = UIDarkZoneStoreQuoteDialogView
function UIDarkZoneStoreQuoteDialogView:__InitCtrl()
end
function UIDarkZoneStoreQuoteDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
