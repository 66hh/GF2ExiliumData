require("UI.UIBaseView")
UIDarkZoneSeasonQuestPanelView = class("UIDarkZoneMainPanelView", UIBaseView)
UIDarkZoneSeasonQuestPanelView.__index = UIDarkZoneSeasonQuestPanelView
function UIDarkZoneSeasonQuestPanelView:__InitCtrl()
end
function UIDarkZoneSeasonQuestPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
