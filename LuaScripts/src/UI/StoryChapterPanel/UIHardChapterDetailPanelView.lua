require("UI.UIBaseView")
UIHardChapterDetailPanelView = class("UIHardChapterDetailPanelView", UIBaseView)
UIHardChapterDetailPanelView.__index = UIHardChapterDetailPanelView
function UIHardChapterDetailPanelView:__InitCtrl()
end
function UIHardChapterDetailPanelView:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(root, uiTable)
  self:__InitCtrl()
end
