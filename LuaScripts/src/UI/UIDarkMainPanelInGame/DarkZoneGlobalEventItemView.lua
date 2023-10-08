require("UI.UIBaseView")
DarkZoneGlobalEventItemView = class("DarkZoneGlobalEventItemView", UIBaseView)
DarkZoneGlobalEventItemView.__index = DarkZoneGlobalEventItemView
function DarkZoneGlobalEventItemView:__InitCtrl()
end
function DarkZoneGlobalEventItemView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
