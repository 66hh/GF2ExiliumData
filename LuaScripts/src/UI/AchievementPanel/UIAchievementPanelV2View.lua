require("UI.UIBaseView")
UIAchievementPanelV2View = class("UIAchievementPanelV2View", UIBaseView)
UIAchievementPanelV2View.__index = UIAchievementPanelV2View
function UIAchievementPanelV2View:__InitCtrl()
end
function UIAchievementPanelV2View:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:LuaUIBindTable(self.mUIRoot, uiTable)
  self:__InitCtrl()
end
