require("UI.UIBaseView")
UIDarkZoneNewSeasonOpenDialogView = class("UIDarkZoneMainPanelView", UIBaseView)
UIDarkZoneNewSeasonOpenDialogView.__index = UIDarkZoneNewSeasonOpenDialogView
function UIDarkZoneNewSeasonOpenDialogView:__InitCtrl()
end
function UIDarkZoneNewSeasonOpenDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
