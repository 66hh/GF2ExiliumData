require("UI.UIBaseView")
UICommonSimpleView = class("UIDarkZoneMainPanelView", UIBaseView)
UICommonSimpleView.__index = UICommonSimpleView
function UICommonSimpleView:__InitCtrl()
end
function UICommonSimpleView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
