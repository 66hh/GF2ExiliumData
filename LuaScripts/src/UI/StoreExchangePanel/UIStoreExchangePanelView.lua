require("UI.UIBaseView")
UIStoreExchangePanelView = class("UIStoreExchangePanelView", UIBaseView)
UIStoreExchangePanelView.__index = UIStoreExchangePanelView
UIStoreExchangePanelView.mBtn_CommandCenter = nil
UIStoreExchangePanelView.mBtn_HButtonUp0 = nil
UIStoreExchangePanelView.mBtn_HButtonUp1 = nil
UIStoreExchangePanelView.mBtn_HButtonUp2 = nil
UIStoreExchangePanelView.mBtn_Return = nil
UIStoreExchangePanelView.mBtn_RenewButton = nil
UIStoreExchangePanelView.mImage_CostItem = nil
UIStoreExchangePanelView.mText_CountDown = nil
UIStoreExchangePanelView.mText_CostNum = nil
UIStoreExchangePanelView.mLayout_List = nil
UIStoreExchangePanelView.mTrans_HButtonUp0_Off = nil
UIStoreExchangePanelView.mTrans_HButtonUp0_On = nil
UIStoreExchangePanelView.mTrans_HButtonUp1_Off = nil
UIStoreExchangePanelView.mTrans_HButtonUp1_On = nil
UIStoreExchangePanelView.mTrans_HButtonUp2_Off = nil
UIStoreExchangePanelView.mTrans_HButtonUp2_On = nil
UIStoreExchangePanelView.mTrans_ButtonList = nil
UIStoreExchangePanelView.mTrans_BottomPanel = nil
UIStoreExchangePanelView.mTrans_TopTabContent = nil
UIStoreExchangePanelView.mTrans_Refresh = nil
function UIStoreExchangePanelView:__InitCtrl()
  self.mBtn_CommandCenter = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpTop/BtnHome"))
  self.mBtn_Return = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpTop/BtnBack"))
  self.mBtn_RenewButton = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpRight/GrpContent/Trans_GrpTextCountdown/GrpBtnFresh"))
  self.mImage_CostItem = self:GetImage("Root/GrpRight/GrpContent/Trans_GrpTextCountdown/GrpFresh/GrpIcon/Img_Icon")
  self.mText_CountDown = self:GetText("Root/GrpRight/GrpContent/Trans_GrpTextCountdown/GrpText/Text_Name")
  self.mText_CostNum = self:GetText("Root/GrpRight/GrpContent/Trans_GrpTextCountdown/GrpFresh/Text_CostNum")
  self.mLayout_List = self:GetGridLayoutGroup("Root/GrpRight/GrpContent/GrpItemList/Viewport/Content")
  self.mTrans_Content = self:GetRectTransform("Root/GrpRight/GrpContent/GrpItemList/Viewport/Content")
  self.mTrans_ItemList = self:GetRectTransform("Root/GrpRight/GrpContent/GrpItemList")
  self.mVirtualList = self:GetVirtualListEx("Root/GrpRight/GrpContent/GrpItemList")
  self.mTrans_ButtonList = self:GetRectTransform("Root/GrpLeft/Content/GrpTabList/Viewport/Content")
  self.mTrans_TopTabContent = self:GetRectTransform("Root/GrpRight/GrpContent/Trans_GrpTopTab")
  self.mTrans_Refresh = self:GetRectTransform("Root/GrpRight/GrpContent/Trans_GrpTextCountdown/GrpFresh")
end
function UIStoreExchangePanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
