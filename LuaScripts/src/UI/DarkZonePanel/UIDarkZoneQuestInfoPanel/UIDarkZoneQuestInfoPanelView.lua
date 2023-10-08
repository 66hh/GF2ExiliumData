require("UI.UIBaseView")
UIDarkZoneQuestInfoPanelView = class("UIDarkZoneQuestInfoPanelView", UIBaseView)
UIDarkZoneQuestInfoPanelView.__index = UIDarkZoneQuestInfoPanelView
function UIDarkZoneQuestInfoPanelView:__InitCtrl()
end
function UIDarkZoneQuestInfoPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
