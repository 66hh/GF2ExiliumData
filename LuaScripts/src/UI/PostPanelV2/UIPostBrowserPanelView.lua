require("UI.UIBaseView")
UIPostBrowserPanelView = class("UIPostBrowserPanelView", UIBaseView)
UIPostBrowserPanelView.__index = UIPostBrowserPanelView
function UIPostBrowserPanelView:__InitCtrl()
end
function UIPostBrowserPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
