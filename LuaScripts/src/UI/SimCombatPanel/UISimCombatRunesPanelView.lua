require("UI.UIBaseView")
UISimCombatRunesPanelView = class("UISimCombatRunesPanelView", UIBaseView)
UISimCombatRunesPanelView.__index = UISimCombatRunesPanelView
function UISimCombatRunesPanelView:__InitCtrl()
  self.mTrans_RuneType = self:GetRectTransform("Root/GrpLeft/GrpTypeSelList/Viewport/Content")
  self.mTrans_RuneList = self:GetRectTransform("Root/GrpRight/GrpDetailsList/Viewport/Content")
  self.mBtn_Close = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpTop/BtnBack"))
  self.mTrans_CombatLauncher = self:GetRectTransform("Trans_GrpCombatLauncher")
  self.mBtn_CloseLaunch = self:GetButton("Scroll_EquipList")
  self.mBtn_CommanderCenter = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpTop/BtnHome"))
  self.mScroll = UIUtils.GetScrollRectEx(self.mUIRoot, "Root/GrpRight/GrpDetailsList")
  self.mAnimator = self:GetRectTransform("Root"):GetComponent("Animator")
end
function UISimCombatRunesPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
  self.mTrans_TopCurrency = self:GetRectTransform("Root/GrpTop/GrpCurrency")
end
