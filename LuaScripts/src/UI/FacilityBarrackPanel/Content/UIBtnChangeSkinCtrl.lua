UIBtnChangeSkinCtrl = class("UIBtnChangeSkinCtrl", UIBaseCtrl)
function UIBtnChangeSkinCtrl:ctor(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root.transform)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnChrSkin.gameObject, function()
    self:onClickSelf()
  end)
end
function UIBtnChangeSkinCtrl:OnRelease()
  self.gunId = nil
  self.onClickCallback = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIBtnChangeSkinCtrl:SetData(gunId)
  self.gunId = gunId
end
function UIBtnChangeSkinCtrl:Refresh()
  local isNeedRedPoint = NetCmdGunClothesData:IsAnyClothesNeedRedPoint(self.gunId)
  self:setRedPointVisible(isNeedRedPoint)
end
function UIBtnChangeSkinCtrl:AddBtnClickListener(callback)
  self.onClickCallback = callback
end
function UIBtnChangeSkinCtrl:SetInteractable(interactable)
  self.ui.mBtn_BtnChrSkin.interactable = interactable
end
function UIBtnChangeSkinCtrl:IsInteractable()
  return self.ui.mBtn_BtnChrSkin.interactable
end
function UIBtnChangeSkinCtrl:setRedPointVisible(visible)
  setactive(self.ui.mObj_RedPoint.transform.parent, visible)
  setactive(self.ui.mObj_RedPoint, visible)
end
function UIBtnChangeSkinCtrl:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback()
  end
end
