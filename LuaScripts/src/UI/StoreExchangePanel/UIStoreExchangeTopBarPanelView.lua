require("UI.UIBaseView")
UIStoreExchangeTopBarPanelView = class("UIStoreExchangeTopBarPanelView", UIBaseView)
UIStoreExchangeTopBarPanelView.__index = UIStoreExchangeTopBarPanelView
UIStoreExchangeTopBarPanelView.mImage_TipsPanel = nil
UIStoreExchangeTopBarPanelView.mTrans_ResList = nil
UIStoreExchangeTopBarPanelView.mTrans_SysList = nil
UIStoreExchangeTopBarPanelView.mTrans_TipsPanel = nil
function UIStoreExchangeTopBarPanelView:__InitCtrl()
  self.mImage_TipsPanel = self:GetImage("Trans_Image_TipsPanel")
  self.mTrans_ResList = self:GetRectTransform("UIUniTopbarList/Trans_ResList")
  self.mTrans_SysList = self:GetRectTransform("UIUniTopbarList/Trans_SysList")
  self.mTrans_TipsPanel = self:GetRectTransform("Trans_Image_TipsPanel")
end
function UIStoreExchangeTopBarPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
  root.gameObject.name = "UIStoreExchangeTopBar"
end
