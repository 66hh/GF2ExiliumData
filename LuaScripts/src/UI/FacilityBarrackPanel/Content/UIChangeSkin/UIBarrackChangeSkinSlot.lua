UIBarrackChangeSkinSlot = class("UIBarrackChangeSkinSlot", UIBaseCtrl)
function UIBarrackChangeSkinSlot:SetRoot(root)
  self.ui = UIUtils.GetUIBindTable(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_ChrSkinChangeItem.gameObject, function()
    self:onClickSelf()
  end)
  self.super.SetRoot(self, root.transform)
end
function UIBarrackChangeSkinSlot:SetData(gunCmdData, clothesData, index)
  self.gunCmdData = gunCmdData
  self.clothesId = clothesData.id
  self.clothesData = clothesData
  self.index = index
end
function UIBarrackChangeSkinSlot:Refresh()
  self:RefreshInfo()
  local isUnlock = self:IsUnlock()
  if isUnlock then
    NetCmdGunClothesData:SetPreviewedRecord(self.clothesData.id)
    self.ui.mAnimator:SetInteger("Lock", 2)
  elseif not isUnlock then
    self.ui.mAnimator:SetInteger("Lock", 0)
  end
  local isFocusEquipped = self.clothesId == self.gunCmdData.costume
  setactivewithcheck(self.ui.mTrans_Equipped, isFocusEquipped)
  local isNeedRedPoint = NetCmdGunClothesData:IsNeedRedPoint(self.gunCmdData.id, self.clothesData.id)
  isNeedRedPoint = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview and isNeedRedPoint or false
  setactivewithcheck(self.ui.mObj_RedPoint, isNeedRedPoint)
end
function UIBarrackChangeSkinSlot:RefreshInfo()
  self.ui.mText_SkinName.text = self.clothesData.name.str
  self.ui.mImage_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.clothesData.rare)
  self.ui.mImage_Skin.sprite = IconUtils.GetSkinSprite("Img_ChrSkinPic_" .. self.clothesData.code)
  self.ui.mAnimator:SetInteger("Lock", 2)
  setactive(self.ui.mTrans_Several, self.clothesData.clothes_type == 1)
  setactive(self.ui.mTrans_All, self.clothesData.clothes_type == 2)
end
function UIBarrackChangeSkinSlot:OnRelease(isDestroy)
  self.clothesId = nil
  self.gunCmdData = nil
  self.clothesData = nil
  self.index = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UIBarrackChangeSkinSlot:AddBtnClickListener(callback)
  self.onClickCallback = callback
end
function UIBarrackChangeSkinSlot:Select()
  self.ui.mBtn_ChrSkinChangeItem.interactable = false
  self.ui.mAnimator:SetBool("Selected", true)
end
function UIBarrackChangeSkinSlot:Deselect()
  self.ui.mBtn_ChrSkinChangeItem.interactable = true
  self.ui.mAnimator:SetBool("Selected", false)
end
function UIBarrackChangeSkinSlot:PlayUnlockingAnim()
  self.ui.mAnimator:SetInteger("Lock", 1)
end
function UIBarrackChangeSkinSlot:GetIndex()
  return self.index
end
function UIBarrackChangeSkinSlot:GetClothesId()
  return self.clothesId
end
function UIBarrackChangeSkinSlot:GetClothesData()
  return self.clothesData
end
function UIBarrackChangeSkinSlot:IsUnlock()
  return NetCmdGunClothesData:IsUnlock(self.clothesId)
end
function UIBarrackChangeSkinSlot:onClickSelf()
  if self.onClickCallback then
    self.onClickCallback(self.index)
  end
end
