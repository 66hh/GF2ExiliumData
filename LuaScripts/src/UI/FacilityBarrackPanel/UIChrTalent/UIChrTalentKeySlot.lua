UIChrTalentKeySlot = class("UIChrTalentKeySlot", UIBaseCtrl)
function UIChrTalentKeySlot:ctor(btnGo)
  self.btnGo = btnGo
  self.mAnimator = self.btnGo:GetComponent(typeof(CS.UnityEngine.Animator))
  self.mTrans_RedPoint = self.btnGo.transform:Find("Trans_RedPoint")
  self:SetRoot(btnGo.transform)
  UIUtils.AddBtnClickListener(self.btnGo.gameObject, function()
    self:onClickSlot()
  end)
end
function UIChrTalentKeySlot:Init(gunId, talentKeyId)
  self.gunId = gunId
  self.talentKeyId = talentKeyId
end
function UIChrTalentKeySlot:Show()
end
function UIChrTalentKeySlot:Hide()
end
function UIChrTalentKeySlot:OnRelease()
  self.onClickCallback = nil
  self.talentKeyId = nil
  self.gunId = nil
  self.ui = nil
  self.super.OnRelease(self)
end
function UIChrTalentKeySlot:SetAnimInteger(paramName, value)
  if not self.mAnimator then
    return
  end
  self.mAnimator:SetInteger(paramName, value)
end
function UIChrTalentKeySlot:SetAnimTrigger(paramName)
  if not self.mAnimator then
    return
  end
  self.mAnimator:SetTrigger(paramName)
end
function UIChrTalentKeySlot:Focus()
  self.btnGo.interactable = false
end
function UIChrTalentKeySlot:LoseFocus()
  self.btnGo.interactable = true
end
function UIChrTalentKeySlot:AddFocusListener(callback)
  self.onClickCallback = callback
end
function UIChrTalentKeySlot:SetRedPointVisible(visible)
  if self.mTrans_RedPoint then
    setactive(self.mTrans_RedPoint, visible)
  end
end
function UIChrTalentKeySlot:onClickSlot()
  if self.onClickCallback then
    self.onClickCallback()
  end
end
