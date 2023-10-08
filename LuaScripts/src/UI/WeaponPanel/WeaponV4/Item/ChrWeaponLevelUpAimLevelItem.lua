ChrWeaponLevelUpAimLevelItem = class("ChrWeaponLevelUpAimLevelItem", UIBaseCtrl)
function ChrWeaponLevelUpAimLevelItem:ctor(root)
  self.isFocused = false
end
function ChrWeaponLevelUpAimLevelItem:InitCtrl(parent, obj)
  local instObj
  if obj == nil then
    local itemPrefab = parent.gameObject:GetComponent(typeof(CS.ScrollListChild))
    instObj = instantiate(itemPrefab.childItem)
  else
    instObj = obj
  end
  self.ui = {}
  self:LuaUIBindTable(instObj, self.ui)
  if parent then
    UIUtils.AddListItem(instObj.gameObject, parent.gameObject)
  end
  self:SetRoot(instObj.transform)
end
function ChrWeaponLevelUpAimLevelItem:SetData(index, level)
  self.index = index
  self.level = level
  self:Refresh()
end
function ChrWeaponLevelUpAimLevelItem:OnRelease(isDestroy)
  self.isFocused = nil
  self.level = nil
  self.ui = nil
  self.super.OnRelease(self, isDestroy)
end
function ChrWeaponLevelUpAimLevelItem:SetVisible(visible)
  setactive(self:GetRoot(), visible)
end
function ChrWeaponLevelUpAimLevelItem:Refresh()
  self.ui.mText_Sel.text = string.format("-", self.level)
  self.ui.mText_UnSel.text = string.format("-", self.level)
  CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self:GetRoot())
end
function ChrWeaponLevelUpAimLevelItem:GetIndex()
  return self.index
end
function ChrWeaponLevelUpAimLevelItem:GetLevel()
  return self.level
end
function ChrWeaponLevelUpAimLevelItem:SetSlotHeight(value)
  self.ui.mLayoutElement_ChrWeaponLevelUpAimLevelItem.minHeight = value
end
function ChrWeaponLevelUpAimLevelItem:SetCanSelect(boolean)
end
function ChrWeaponLevelUpAimLevelItem:IsFocused()
  return self.isFocused
end
function ChrWeaponLevelUpAimLevelItem:Focus()
  self.ui.mAnimator_Root:SetBool("White", true)
  self.isFocused = true
end
function ChrWeaponLevelUpAimLevelItem:LoseFocus()
  self.ui.mAnimator_Root:SetBool("White", false)
  self.isFocused = false
end
