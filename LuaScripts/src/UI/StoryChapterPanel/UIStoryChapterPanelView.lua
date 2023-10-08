require("UI.UIBaseView")
UIStoryChapterPanelView = class("UIStoryChapterPanelView", UIBaseView)
UIStoryChapterPanelView.__index = UIStoryChapterPanelView
function UIStoryChapterPanelView:__InitCtrl()
end
function UIStoryChapterPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
