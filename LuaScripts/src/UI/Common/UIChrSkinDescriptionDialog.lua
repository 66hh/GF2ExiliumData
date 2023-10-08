require("UI.Common.UICommonItem")
UIChrSkinDescriptionDialog = class("UIChrSkinDescriptionDialog", UIBasePanel)
UIChrSkinDescriptionDialog.__index = UIChrSkinDescriptionDialog
function UIChrSkinDescriptionDialog:ctor(csPanel)
  UIChrSkinDescriptionDialog.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIChrSkinDescriptionDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrSkinDescriptionDialog:OnInit(root, param)
  self:InitBtnClick()
  self.clothesType = param.clothes_type
  self:SetData()
end
function UIChrSkinDescriptionDialog:OnShowStart()
end
function UIChrSkinDescriptionDialog:OnRecover()
end
function UIChrSkinDescriptionDialog:OnBackFrom()
end
function UIChrSkinDescriptionDialog:OnTop()
end
function UIChrSkinDescriptionDialog:OnShowFinish()
end
function UIChrSkinDescriptionDialog:OnHide()
end
function UIChrSkinDescriptionDialog:OnHideFinish()
end
function UIChrSkinDescriptionDialog:OnClose()
end
function UIChrSkinDescriptionDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIChrSkinDescriptionDialog:SetData()
  if self.clothesType == 1 then
    self.ui.mTextFit_Content.text = TableData.GetHintById(230014)
    self.ui.mText_Type.text = TableData.GetHintById(230012)
    setactive(self.ui.mTrans_All, false)
    setactive(self.ui.mTrans_Several, true)
  elseif self.clothesType == 2 then
    self.ui.mTextFit_Content.text = TableData.GetHintById(230013)
    self.ui.mText_Type.text = TableData.GetHintById(230011)
    setactive(self.ui.mTrans_All, true)
    setactive(self.ui.mTrans_Several, false)
  end
end
function UIChrSkinDescriptionDialog:InitBtnClick()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrSkinDescriptionDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrSkinDescriptionDialog)
  end
end
