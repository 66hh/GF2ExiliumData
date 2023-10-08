UIDormChangeSkinSlot = class("UIDormChangeSkinSlot", UIBaseCtrl)
UIDormChangeSkinSlot.__index = UIDormChangeSkinSlot
function UIDormChangeSkinSlot:ctor()
  gfdebug("UIDormChangeSkinSlot:ctor")
end
function UIDormChangeSkinSlot:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_ChrSkinChangeItem.gameObject, function()
    self:onClickSelf()
  end)
  self.super.SetRoot(self, root.transform)
  self.ui.mAnimator.keepAnimatorControllerStateOnDisable = true
end
function UIDormChangeSkinSlot:SetData(gunCmdData, clothesData, index)
  self.gunCmdData = gunCmdData
  self.clothesId = clothesData.id
  self.clothesData = clothesData
  self.index = index
end
function UIDormChangeSkinSlot:Refresh()
  self:RefreshInfo()
  local isUnlock = self:IsUnlock()
  if isUnlock then
    self.ui.mAnimator:SetInteger("Lock", 2)
  elseif not isUnlock then
    self.ui.mAnimator:SetInteger("Lock", 0)
  end
  local isFocusEquipped = self.clothesId == self.gunCmdData.dormCostume
  setactivewithcheck(self.ui.mTrans_Equipped, isFocusEquipped)
  local isNeedRedPoint = NetCmdGunClothesData:isDormNeedRedPoint(self.gunCmdData.id, self.clothesData.id)
  setactivewithcheck(self.ui.mObj_RedPoint, isNeedRedPoint)
end
function UIDormChangeSkinSlot:RefreshInfo()
  self.ui.mText_SkinName.text = self.clothesData.name.str
  self.ui.mImage_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.clothesData.rare)
  self.ui.mImage_Skin.sprite = IconUtils.GetSkinSprite("Img_ChrSkinPic_" .. self.clothesData.code)
  self.ui.mAnimator:SetInteger("Lock", 2)
end
function UIDormChangeSkinSlot:OnRelease(isDestroy)
  self.clothesId = nil
  self.gunCmdData = nil
  self.clothesData = nil
  self.index = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UIDormChangeSkinSlot:AddBtnClickListener(callback)
  self.onClickCallback = callback
end
function UIDormChangeSkinSlot:Select()
  NetCmdGunClothesData:SetDormPreviewedRecord(self.clothesData.id)
  local isNeedRedPoint = NetCmdGunClothesData:isDormNeedRedPoint(self.gunCmdData.id, self.clothesData.id)
  setactivewithcheck(self.ui.mObj_RedPoint, isNeedRedPoint)
  self.ui.mBtn_ChrSkinChangeItem.interactable = false
  self.ui.mAnimator:SetBool("Selected", true)
end
function UIDormChangeSkinSlot:Deselect()
  self.ui.mBtn_ChrSkinChangeItem.interactable = true
  self.ui.mAnimator:SetBool("Selected", false)
end
function UIDormChangeSkinSlot:PlayUnlockingAnim()
  self.ui.mAnimator:SetInteger("Lock", 1)
end
function UIDormChangeSkinSlot:GetIndex()
  return self.index
end
function UIDormChangeSkinSlot:GetClothesId()
  return self.clothesId
end
function UIDormChangeSkinSlot:GetClothesData()
  return self.clothesData
end
function UIDormChangeSkinSlot:IsUnlock()
  return NetCmdGunClothesData:IsUnlock(self.clothesId)
end
function UIDormChangeSkinSlot:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback(self.index)
  end
end
