require("UI.UIBaseView")
UIDarkZoneTeamReNameDialogView = class("UIDarkZoneTeamReNameDialogView", UIBaseView)
UIDarkZoneTeamReNameDialogView.__index = UIDarkZoneTeamReNameDialogView
function UIDarkZoneTeamReNameDialogView:__InitCtrl()
end
function UIDarkZoneTeamReNameDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
