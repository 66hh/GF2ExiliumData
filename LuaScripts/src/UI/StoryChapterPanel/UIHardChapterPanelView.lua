require("UI.UIBaseView")
UIHardChapterPanelView = class("UIHardChapterPanelView", UIBaseView)
UIHardChapterPanelView.__index = UIHardChapterPanelView
function UIHardChapterPanelView:__InitCtrl()
end
function UIHardChapterPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
