require("UI.UIBaseView")
UIRepositoryPanelV2View = class("UIRepositoryPanelV2View", UIBaseView)
UIRepositoryPanelV2View.__index = UIRepositoryPanelV2View
function UIRepositoryPanelV2View:__InitCtrl()
end
function UIRepositoryPanelV2View:InitCtrl(root, uiTable)
  self:SetRoot(root)
  self:__InitCtrl()
  self:LuaUIBindTable(root, uiTable)
end
function UIRepositoryPanelV2View:OnRelease()
  self.super.OnRelease(self)
end
