require("UI.UIBaseView")
UIDarkZoneMainTipsDialogView = class("UIDarkZoneMainTipsDialogView", UIBaseView)
UIDarkZoneMainTipsDialogView.__index = UIDarkZoneMainTipsDialogView
function UIDarkZoneMainTipsDialogView:__InitCtrl()
end
function UIDarkZoneMainTipsDialogView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
