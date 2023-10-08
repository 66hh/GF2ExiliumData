require("UI.DarkZonePanel.UIDarkZoneRepositoryPanel.UIDarkZoneRepositoryExistDialogView")
require("UI.UIBasePanel")
UIDarkZoneRepositoryExistDialog = class("UIDarkZoneRepositoryExistDialog", UIBasePanel)
UIDarkZoneRepositoryExistDialog.__index = UIDarkZoneRepositoryExistDialog
function UIDarkZoneRepositoryExistDialog:ctor(csPanel)
  UIDarkZoneRepositoryExistDialog.super.ctor(UIDarkZoneRepositoryExistDialog, csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIDarkZoneRepositoryExistDialog:OnInit(root, data)
  self:SetRoot(root)
  self.ui = {}
  self.mView = UIDarkZoneRepositoryExistDialogView.New()
  self.mView:InitCtrl(root, self.ui)
  UIUtils.GetButtonListener(self.ui.mBtn_Cancel.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneRepositoryExistDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneRepositoryExistDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BgClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIDarkZoneRepositoryExistDialog)
  end
  self.data = data[1]
  self.toBag = data[2]
  self.item = UICommonItem.New()
  self.item:InitObj(self.ui.objItem)
  self.item:SetDarkZoneItemData(self.data.ItemData.id, nil)
  if self.toBag then
    self.ui.mText_Title.text = TableData.GetHintById(903156)
    self.ui.mText_BuyCount.text = TableData.GetHintById(903163)
  else
    self.ui.mText_Title.text = TableData.GetHintById(903155)
    self.ui.mText_BuyCount.text = TableData.GetHintById(903164)
  end
  self.maxCount = self.data.ItemCount
  self.ui.mText_MinNum.text = 1 .. ""
  self.ui.mText_MaxNum.text = self.maxCount .. ""
  self.curBuyCount = self.maxCount
  self.ui.mSlider_Line.minValue = 1
  self.ui.mSlider_Line.maxValue = self.maxCount
  self.ui.mSlider_Line.value = self.curBuyCount
  local this = self
  UIUtils.GetButtonListener(self.ui.mBtn_Confirm.gameObject).onClick = function()
    if this.curBuyCount == this.maxCount then
      DarkZoneNetRepoCmdData:StorageMove(this.toBag, this.data, function()
        UIManager.CloseUI(UIDef.UIDarkZoneRepositoryExistDialog)
      end)
    else
      DarkZoneNetRepoCmdData:StorageMove(this.toBag, this.data, this.curBuyCount, function()
        UIManager.CloseUI(UIDef.UIDarkZoneRepositoryExistDialog)
      end)
    end
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Increase.gameObject).onClick = function()
    this:OnClickIncrease()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Reduce.gameObject).onClick = function()
    this:OnClickReduce()
  end
  self.ui.mSlider_Line.onValueChanged:AddListener(function(ptc)
    this:OnValueChanged(ptc)
  end)
  self:UpdateCost()
end
function UIDarkZoneRepositoryExistDialog:OnClickIncrease()
  if self.curBuyCount < self.maxCount then
    self.curBuyCount = self.curBuyCount + 1
    self.ui.mSlider_Line.value = self.curBuyCount
    self:UpdateCost()
  end
end
function UIDarkZoneRepositoryExistDialog:OnClickReduce()
  if self.curBuyCount > 1 then
    self.curBuyCount = self.curBuyCount - 1
    self.ui.mSlider_Line.value = self.curBuyCount
    self:UpdateCost()
  end
end
function UIDarkZoneRepositoryExistDialog:OnValueChanged(ptc)
  self.curBuyCount = ptc
  self:UpdateCost()
end
function UIDarkZoneRepositoryExistDialog:UpdateCost()
  self.ui.mText_CompoundNum.text = formatnum(self.curBuyCount) .. ""
  self.ui.mBtn_Reduce.interactable = self.curBuyCount > 1
  self.ui.mBtn_Increase.interactable = self.curBuyCount < self.maxCount
end
function UIDarkZoneRepositoryExistDialog:OnShowStart()
end
function UIDarkZoneRepositoryExistDialog:OnHide()
end
function UIDarkZoneRepositoryExistDialog:OnUpdate(deltaTime)
end
function UIDarkZoneRepositoryExistDialog.Close()
  UIManager.OpenUI(UIDef.UIDarkZoneRepositoryExistDialog)
end
function UIDarkZoneRepositoryExistDialog:OnClose()
  self.ui = nil
  self.mView = nil
end
