UIChrSpecialEffectDialog = class("UIChrSpecialEffectDialog", UIBasePanel)
UIChrSpecialEffectDialog.__index = UIChrSpecialEffectDialog
function UIChrSpecialEffectDialog:ctor(csPanel)
  UIChrSpecialEffectDialog.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  csPanel.Type = UIBasePanelType.Dialog
end
function UIChrSpecialEffectDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.isGroupSkillActive = false
end
function UIChrSpecialEffectDialog:OnInit(root, param)
  self.weaponCmdData = param.weaponCmdData
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrSpecialEffectDialog)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_GrpClose.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrSpecialEffectDialog)
  end
end
function UIChrSpecialEffectDialog:OnShowStart()
  self:SetWeaponData()
end
function UIChrSpecialEffectDialog:OnRecover()
end
function UIChrSpecialEffectDialog:OnBackFrom()
end
function UIChrSpecialEffectDialog:OnTop()
end
function UIChrSpecialEffectDialog:OnShowFinish()
end
function UIChrSpecialEffectDialog:OnHide()
end
function UIChrSpecialEffectDialog:OnHideFinish()
end
function UIChrSpecialEffectDialog:OnClose()
end
function UIChrSpecialEffectDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIChrSpecialEffectDialog:SetWeaponData()
  self:WeaponUpdateWeaponGroupSkill()
end
function UIChrSpecialEffectDialog:WeaponUpdateWeaponGroupSkill()
  self.isGroupSkillActive = false
  local groupSkillItems, isGroupSkillActive = CS.WeaponCmdData.SetWeaponGroupSkillData(self.ui.mTrans_GroupSkill1, self.weaponCmdData, self.isGroupSkillActive, false)
  local hasProficiency = self:WeaponGetWeaponPartProficiencySkill() > 0
  local hasGroup = 0 < groupSkillItems.Count
  setactive(self.ui.mTrans_GroupSkill.gameObject, hasGroup or hasProficiency)
  setactive(self.ui.mTrans_None.gameObject, not hasGroup and not hasProficiency)
  self.isGroupSkillActive = isGroupSkillActive
  if self.isGroupSkillActive then
    self.ui.mTrans_GroupSkill1.transform:SetSiblingIndex(0)
  else
    self.ui.mTrans_GroupSkill1.transform:SetSiblingIndex(1)
  end
  for i = 0, groupSkillItems.Count - 1 do
    local item = groupSkillItems[i]
    if self.isGroupSkillActive then
      item:SetCanvasGroupAlpha(1)
    else
      item:SetCanvasGroupAlpha(0.5)
    end
  end
end
function UIChrSpecialEffectDialog:WeaponGetWeaponPartProficiencySkill()
  local tmpParent = self.ui.mTrans_Proficiency
  local count = CS.WeaponCmdData.SetWeaponPartProficiencySkill(self.weaponCmdData, tmpParent)
  return count
end
