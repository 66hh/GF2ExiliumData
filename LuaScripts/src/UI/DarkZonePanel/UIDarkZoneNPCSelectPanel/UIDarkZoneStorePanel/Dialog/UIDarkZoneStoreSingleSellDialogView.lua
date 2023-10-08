require("UI.UIBaseView")
UIDarkZoneStoreSingleSellDialogView = class("UIDarkZoneStoreSingleSellDialogView", UIBaseView)
UIDarkZoneStoreSingleSellDialogView.__index = UIDarkZoneStoreSingleSellDialogView
function UIDarkZoneStoreSingleSellDialogView:__InitCtrl()
end
function UIDarkZoneStoreSingleSellDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
