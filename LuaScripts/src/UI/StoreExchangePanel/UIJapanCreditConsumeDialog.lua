require("UI.StoreExchangePanel.UIJapanCreditConsumeDialogView")
require("UI.UIBasePanel")
UIJapanCreditConsumeDialog = class("UIJapanCreditConsumeDialog", UIBasePanel)
UIJapanCreditConsumeDialog.__index = UIJapanCreditConsumeDialog
function UIJapanCreditConsumeDialog:ctor(csPanel)
  UIJapanCreditConsumeDialog.super.ctor(UIJapanCreditConsumeDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIJapanCreditConsumeDialog.Open()
  UIJapanCreditConsumeDialog.OpenUI(UIDef.UIJapanCreditConsumeDialog)
end
function UIJapanCreditConsumeDialog.Close()
  UIManager.CloseUI(UIDef.UIJapanCreditConsumeDialog)
end
function UIJapanCreditConsumeDialog:OnInit(root, data)
  UIJapanCreditConsumeDialog.super.SetRoot(UIJapanCreditConsumeDialog, root)
  self.mView = UIJapanCreditConsumeDialogView.New()
  self.ui = {}
  self.mView:LuaUIBindTable(self.mUIRoot, self.ui)
  local priceType = TableData.GetItemData(data.price_type)
  local curFree = GlobalData.credit_free
  local curPaid = GlobalData.credit_pay
  self.ui.mText_Content.text = TableData.GetHintReplaceById(106052, data.price .. "" .. priceType.name)
  if data.price_type == GlobalConfig.ResourceType.CreditFree then
    self.ui.mText_BeforeFreeNum.text = curFree
    self.ui.mText_AfterFreeNum.text = curFree < data.price and 0 or curFree - data.price
    self.ui.mText_BeforePaidNum.text = curPaid
    self.ui.mText_AfterPaidNum.text = curFree < data.price and curFree + curPaid - data.price or curPaid
  elseif data.price_type == GlobalConfig.ResourceType.CreditPay then
    self.ui.mText_BeforeFreeNum.text = curFree
    self.ui.mText_AfterFreeNum.text = curFree
    self.ui.mText_BeforePaidNum.text = curPaid
    self.ui.mText_AfterPaidNum.text = curPaid - data.price
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIJapanCreditConsumeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIJapanCreditConsumeDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    data.callback()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIJapanCreditConsumeDialog)
  end
  setactive(self.ui.mTrans_Free, data.price_type == GlobalConfig.ResourceType.CreditFree and curFree ~= 0)
  setactive(self.ui.mTrans_Paid, data.price_type == GlobalConfig.ResourceType.CreditPay or curFree < data.price)
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
end
function UIJapanCreditConsumeDialog:OnShowStart()
end
function UIJapanCreditConsumeDialog:OnRelease()
  self:UnRegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Close)
end
