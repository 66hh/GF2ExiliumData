require("UI.UIBaseView")
UIDarkZoneQuestPanelView = class("UIDarkZoneQuestPanelView", UIBaseView)
UIDarkZoneQuestPanelView.__index = UIDarkZoneQuestPanelView
function UIDarkZoneQuestPanelView:__InitCtrl()
end
function UIDarkZoneQuestPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
