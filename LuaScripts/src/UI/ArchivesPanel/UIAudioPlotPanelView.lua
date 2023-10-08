require("UI.UIBaseView")
UIAudioPlotPanelView = class("UIAudioPlotPanelView", UIBaseView)
UIAudioPlotPanelView.__index = UIAudioPlotPanelView
function UIAudioPlotPanelView:__InitCtrl()
end
function UIAudioPlotPanelView:InitCtrl(root, uitable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uitable)
  self:__InitCtrl()
end
