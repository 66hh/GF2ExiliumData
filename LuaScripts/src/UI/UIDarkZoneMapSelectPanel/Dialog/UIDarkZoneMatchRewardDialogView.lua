require("UI.UIBaseView")
UIDarkZoneMatchRewardDialogView = class("UIDarkZoneMatchRewardDialogView", UIBaseView)
UIDarkZoneMatchRewardDialogView.__index = UIDarkZoneMatchRewardDialogView
function UIDarkZoneMatchRewardDialogView:__InitCtrl()
end
function UIDarkZoneMatchRewardDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
