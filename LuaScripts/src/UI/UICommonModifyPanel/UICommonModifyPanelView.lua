require("UI.UIBaseView")
UICommonModifyPanelView = class("UICommonModifyPanelView", UIBaseView)
UICommonModifyPanelView.__index = UICommonModifyPanelView
function UICommonModifyPanelView:ctor()
end
function UICommonModifyPanelView:__InitCtrl()
  self.mBtn_Cancel = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpAction/BtnCancel"))
  self.mBtn_Confirm = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpAction/BtnConfirm"))
  self.mBtn_Close = UIUtils.GetTempBtn(self:GetRectTransform("Root/GrpDialog/GrpTop/GrpClose"))
  self.mBtn_CloseBg = self:GetButton("Root/GrpBg/Btn_Close")
  self.mTrans_TextLimit = self:GetRectTransform("Root/GrpDialog/GrpTextLimit")
  self.mText_Num = self:GetText("Root/GrpDialog/GrpTextLimit/GrpTextLimit/Text_Num")
  self.mText_AllNum = self:GetText("Root/GrpDialog/GrpTextLimit/GrpTextLimit/Text_NumAll")
  self.mText_InputField = self:GetInputField("Root/GrpDialog/GrpInputField/Btn_InputField")
  self.mText_Placeholder = self:GetText("Root/GrpDialog/GrpInputField/Btn_InputField/Placeholder")
end
function UICommonModifyPanelView:InitCtrl(root)
  self:SetRoot(root)
  self:__InitCtrl()
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.ui.mText_Title.text = TableData.GetHintById(100040)
end
