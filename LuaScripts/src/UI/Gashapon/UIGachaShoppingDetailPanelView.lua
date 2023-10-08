require("UI.UIBaseView")
UIGachaShoppingDetailPanelView = class("UIGachaShoppingDetailPanel", UIBaseView)
UIGachaShoppingDetailPanelView.__index = UIGachaShoppingDetailPanelView
function UIGachaShoppingDetailPanelView:ctor()
end
function UIGachaShoppingDetailPanelView:__InitCtrl()
end
function UIGachaShoppingDetailPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
