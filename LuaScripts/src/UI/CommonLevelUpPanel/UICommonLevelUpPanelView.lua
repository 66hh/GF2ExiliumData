require("UI.UIBaseView")
UICommonLevelUpPanelView = class("UICommonLevelUpPanelView", UIBaseView)
UICommonLevelUpPanelView.__index = UICommonLevelUpPanelView
function UICommonLevelUpPanelView:ctor()
end
function UICommonLevelUpPanelView:__InitCtrl()
end
function UICommonLevelUpPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
