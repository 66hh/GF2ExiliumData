require("UI.UIBaseView")
UICommonBirthModifyPanelView = class("UICommonBirthModifyPanelView", UIBaseView)
UICommonBirthModifyPanelView.__index = UICommonBirthModifyPanelView
function UICommonBirthModifyPanelView:ctor()
end
function UICommonBirthModifyPanelView:__InitCtrl()
  self.mBtn_Confirm = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpAction/BtnConfirm"))
  self.mBtn_CloseBg = self:GetButton("Root/GrpBg/Btn_Close")
  self.mBtn_Close = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpTop/GrpClose"))
  self.mTrans_MonthContent = self:GetRectTransform("Root/GrpDialog/GrpCenter/GrpMonth/Viewport/Content")
  self.mTrans_DayContent = self:GetRectTransform("Root/GrpDialog/GrpCenter/GrpDay/Viewport/Content")
  self.mMonthList = UIUtils.GetChildCenterScroll(self:GetRectTransform("Root/GrpDialog/GrpCenter/GrpMonth"))
  self.mDayList = UIUtils.GetChildCenterScroll(self:GetRectTransform("Root/GrpDialog/GrpCenter/GrpDay"))
end
function UICommonBirthModifyPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
