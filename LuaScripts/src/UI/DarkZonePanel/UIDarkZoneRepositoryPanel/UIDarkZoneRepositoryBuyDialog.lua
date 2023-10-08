require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.UIDarkZoneRepositoryBuyDialogView")
require("UI.UIBasePanel")
UIDarkZoneRepositoryBuyDialog = class("UIDarkZoneRepositoryBuyDialog", UIBasePanel)
UIDarkZoneRepositoryBuyDialog.__index = UIDarkZoneRepositoryBuyDialog
UIDarkZoneRepositoryBuyDialog.MinCount = 1
UIDarkZoneRepositoryBuyDialog.CostItemId = 2
function UIDarkZoneRepositoryBuyDialog:ctor(csPanel)
  UIDarkZoneRepositoryBuyDialog.super.ctor(UIDarkZoneRepositoryBuyDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneRepositoryBuyDialog:OnInit(root)
  self:SetRoot(root)
  self.ui = {}
  self.mView = UIDarkZoneRepositoryBuyDialogView.New()
  self.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneRepositoryBuyDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneRepositoryBuyDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneRepositoryBuyDialog)
  end
  self.priceList = DarkZoneNetRepoCmdData.CurPriceList
  self.maxBuyCount = self.priceList.Count
  self.ui.mText_MinNum.text = UIDarkZoneRepositoryBuyDialog.MinCount .. ""
  self.ui.mText_MaxNum.text = self.maxBuyCount .. ""
  self.curBuyCount = 1
  self.ui.mSlider_Line.minValue = UIDarkZoneRepositoryBuyDialog.MinCount
  self.ui.mSlider_Line.maxValue = self.maxBuyCount
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if NetCmdItemData:GetResItemCount(self.CostItemId) >= self.price then
      DarkZoneNetRepoCmdData:SendCS_DarkZoneBuyStorage(self.curBuyCount)
      UIManager.CloseUI(UIDef.UIDarkZoneRepositoryBuyDialog)
    else
      CS.PopupMessageManager.PopupString(TableData.GetHintById(903158))
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Increase.gameObject).onClick = function()
    self:OnClickIncrease()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Reduce.gameObject).onClick = function()
    self:OnClickReduce()
  end
  self.ui.mSlider_Line.onValueChanged:AddListener(function(ptc)
    self:OnValueChanged(ptc)
  end)
  self:UpdateCost()
end
function UIDarkZoneRepositoryBuyDialog:OnClickIncrease()
  if self.curBuyCount < self.maxBuyCount then
    self.curBuyCount = self.curBuyCount + 1
    self.ui.mSlider_Line.value = self.curBuyCount
    self:UpdateCost()
  end
end
function UIDarkZoneRepositoryBuyDialog:OnClickReduce()
  if self.curBuyCount > UIDarkZoneRepositoryBuyDialog.MinCount then
    self.curBuyCount = self.curBuyCount - 1
    self.ui.mSlider_Line.value = self.curBuyCount
    self:UpdateCost()
  end
end
function UIDarkZoneRepositoryBuyDialog:OnValueChanged(ptc)
  self.curBuyCount = ptc
  self:UpdateCost()
end
function UIDarkZoneRepositoryBuyDialog:UpdateCost()
  self.price = 0
  for i = 0, self.curBuyCount - 1 do
    self.price = self.priceList[i].item_num + self.price
  end
  self.ui.mText_CompoundNum.text = formatnum(self.curBuyCount) .. ""
  self.ui.mText_Cost.text = formatnum(self.price) .. ""
  self.ui.mText_Cost.color = NetCmdItemData:GetResItemCount(self.CostItemId) < self.price and ColorUtils.RedColor or ColorUtils.BlackColor
end
function UIDarkZoneRepositoryBuyDialog:OnShow()
end
function UIDarkZoneRepositoryBuyDialog:OnHide()
end
function UIDarkZoneRepositoryBuyDialog:OnUpdate(deltaTime)
end
function UIDarkZoneRepositoryBuyDialog.Close()
  UIManager.OpenUI(UIDef.UIDarkZoneRepositoryBuyDialog)
end
function UIDarkZoneRepositoryBuyDialog:OnClose()
  self.ui = nil
  self.mView = nil
end
