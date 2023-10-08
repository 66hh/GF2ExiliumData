require("UI.UIBaseCtrl")
ActivityTourCommandCtrlBase = class("ActivityTourCommandCtrlBase", UIBaseCtrl)
ActivityTourCommandCtrlBase.__index = ActivityTourCommandCtrlBase
function ActivityTourCommandCtrlBase:ShowOrderInfo(data)
  setactive(self.ui.mTrans_SelectEntity, true)
  setactive(self.ui.mTrans_SelectMove, false)
  self.ui.mText_CommandDescName.text = data.name.str
  self.ui.mText_CommandDescDesc.text = data.order_desc.str
  self.ui.mText_CommandDescMove.text = TableData.GetActivityTourStepContent(data)
end
function ActivityTourCommandCtrlBase:EnableConfirmBtn(enable)
  self.ui.mAnimator_Confirm:SetBool("Lock", enable)
  UIUtils.EnableBtn(self.ui.mBtn_Confirm, enable)
end
