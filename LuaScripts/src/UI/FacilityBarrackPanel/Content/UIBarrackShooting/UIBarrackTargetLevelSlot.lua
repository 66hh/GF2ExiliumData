UIBarrackTargetLevelSlot = class("UIBarrackTargetLevelSlot", UIBaseCtrl)
function UIBarrackTargetLevelSlot:ctor(root)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  self.isFocused = false
end
function UIBarrackTargetLevelSlot:SetData(index, level)
  self.index = index
  self.level = level
  self:Refresh()
end
function UIBarrackTargetLevelSlot:OnRelease(isDestroy)
  self.isFocused = nil
  self.level = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function UIBarrackTargetLevelSlot:Refresh()
  self.ui.mText_B.text = tostring(self.level)
  self.ui.mText_W.text = tostring(self.level)
  CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self:GetRoot())
end
function UIBarrackTargetLevelSlot:GetIndex()
  return self.index
end
function UIBarrackTargetLevelSlot:GetLevel()
  return self.level
end
function UIBarrackTargetLevelSlot:SetVisible(visible)
  setactive(self:GetRoot(), visible)
end
function UIBarrackTargetLevelSlot:SetAlpha(alpha)
  self.ui.mCanvasGroup.alpha = alpha
end
function UIBarrackTargetLevelSlot:SetSlotHeight(value)
  self.ui.mLayoutElement.minHeight = value
end
function UIBarrackTargetLevelSlot:IsFocused()
  return self.isFocused
end
function UIBarrackTargetLevelSlot:Focus()
  self.ui.mAnimator:SetBool("White", true)
  self.isFocused = true
end
function UIBarrackTargetLevelSlot:LoseFocus()
  self.ui.mAnimator:SetBool("White", false)
  self.isFocused = false
end
