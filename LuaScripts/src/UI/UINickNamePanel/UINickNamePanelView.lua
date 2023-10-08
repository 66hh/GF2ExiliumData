require("UI.UIBaseView")
UINickNamePanelView = class("UINickNamePanelView", UIBaseView)
UINickNamePanelView.__index = UINickNamePanelView
function UINickNamePanelView:ctor()
end
function UINickNamePanelView:__InitCtrl()
  self.mInputField = self:GetInputField("Root/GrpName/GrpInputField")
  self.mTrans_Editor = self:GetRectTransform("Root/GrpName/GrpInputField/Placeholder")
  self.mBtn_Confirm = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpAction/BtnConfirm"))
  self.mBtn_Man = self:GetButton("Root/GrpGender/BtnGenderSel/Btn_Man")
  self.mBtn_Woman = self:GetButton("Root/GrpGender/BtnGenderSel/Btn_Woman")
  self.mBtn_Birth = self:GetButton("Root/GrpBirthDay/BtnBirthDaySel/Btn_BirthDaySel")
  self.mText_Month = self:GetText("Root/GrpBirthDay/BtnBirthDaySel/Btn_BirthDaySel/GrpText/Text_NumMonth")
  self.mText_Day = self:GetText("Root/GrpBirthDay/BtnBirthDaySel/Btn_BirthDaySel/GrpText/Text_NumDay")
end
function UINickNamePanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
end
