require("UI.UIBaseView")
UIDarkZoneSeasonRewardDialogView = class("UIDarkZoneMainPanelView", UIBaseView)
UIDarkZoneSeasonRewardDialogView.__index = UIDarkZoneSeasonRewardDialogView
function UIDarkZoneSeasonRewardDialogView:__InitCtrl()
end
function UIDarkZoneSeasonRewardDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
