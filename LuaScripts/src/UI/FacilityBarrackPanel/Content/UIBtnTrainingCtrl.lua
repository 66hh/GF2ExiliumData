UIBtnTrainingCtrl = class("UIBtnTrainingCtrl", UIBaseCtrl)
function UIBtnTrainingCtrl:ctor(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root.transform)
  UIUtils.AddBtnClickListener(self.ui.mBtn_ComBtn2ItemV2.gameObject, function()
    self:onClickSelf()
  end)
end
function UIBtnTrainingCtrl:OnRelease()
  self.remainingTrainingTime = nil
  self.gunId = nil
  self.onClickCallback = nil
  self.onCountdownEnd = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIBtnTrainingCtrl:SetData(gunId)
  self.gunId = gunId
end
function UIBtnTrainingCtrl:Refresh()
  local isBreakable = NetCmdTrainGunData:IsBreakable(self.gunId)
  self:setRedPointVisible(isBreakable)
end
function UIBtnTrainingCtrl:AddBtnClickListener(callback)
  self.onClickCallback = callback
end
function UIBtnTrainingCtrl:SetInteractable(interactable)
  self.ui.mBtn_ComBtn2ItemV2.interactable = interactable
end
function UIBtnTrainingCtrl:IsInteractable()
  return self.ui.mBtn_ComBtn2ItemV2.interactable
end
function UIBtnTrainingCtrl:SetVisible(visible)
  setactive(self:GetRoot(), visible)
end
function UIBtnTrainingCtrl:setRedPointVisible(visible)
  setactive(self.ui.mScrollItem_RedPoint, visible)
end
function UIBtnTrainingCtrl:setGrpTrainingVisible(visible)
  setactive(self.ui.mTrans_Training, visible)
end
function UIBtnTrainingCtrl:setGrpTextVisible(visible)
  setactive(self.ui.mTrans_GrpText, visible)
end
function UIBtnTrainingCtrl:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback()
  end
end
