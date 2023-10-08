UIChrWeaponPartsPolaritySuccessDialog = class("UIChrWeaponPartsPolaritySuccessDialog", UIBasePanel)
UIChrWeaponPartsPolaritySuccessDialog.__index = UIChrWeaponPartsPolaritySuccessDialog
function UIChrWeaponPartsPolaritySuccessDialog:ctor(csPanel)
  UIChrWeaponPartsPolaritySuccessDialog.super:ctor(csPanel)
  csPanel.Type = UIBasePanelType.Dialog
end
function UIChrWeaponPartsPolaritySuccessDialog:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.title = nil
  self.gunWeaponModData = nil
  self.lastGunWeaponModData = nil
  self.polarityTagData = nil
end
function UIChrWeaponPartsPolaritySuccessDialog:OnInit(root, param)
  self.title = param.title
  self.gunWeaponModData = param.gunWeaponModData
  self.lastGunWeaponModData = self.gunWeaponModData.LastModData
  self.polarityTagData = self.gunWeaponModData.PolarityTagData
  self.callback = param.callback
end
function UIChrWeaponPartsPolaritySuccessDialog:OnShowStart()
  self:SetData()
end
function UIChrWeaponPartsPolaritySuccessDialog:OnRecover()
end
function UIChrWeaponPartsPolaritySuccessDialog:OnBackFrom()
end
function UIChrWeaponPartsPolaritySuccessDialog:OnTop()
end
function UIChrWeaponPartsPolaritySuccessDialog:OnShowFinish()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrWeaponPartsPolaritySuccessDialog)
  end
end
function UIChrWeaponPartsPolaritySuccessDialog:OnHide()
end
function UIChrWeaponPartsPolaritySuccessDialog:OnHideFinish()
end
function UIChrWeaponPartsPolaritySuccessDialog:OnClose()
  if self.callback ~= nil then
    self.callback()
  end
end
function UIChrWeaponPartsPolaritySuccessDialog:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPartsPolaritySuccessDialog:SetData()
  self.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(self.polarityTagData.icon .. "_S")
  local icon = self.gunWeaponModData.icon
  self.ui.mImg_PartsIcon.sprite = IconUtils.GetWeaponPartIcon(icon)
  self.ui.mImg_Quality.color = TableData.GetGlobalGun_Quality_Color2(self.gunWeaponModData.rank, self.ui.mImg_Quality.color.a)
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(self.gunWeaponModData.rank, self.ui.mImg_QualityLine.color.a)
  self.ui.mImg_TypeIcon.sprite = ResSys:GetWeaponPartEffectSprite(self.gunWeaponModData.ModEffectTypeData.icon)
  self:SetSkill()
  self:SetPolarityEffect()
end
function UIChrWeaponPartsPolaritySuccessDialog:SetSkill()
  local tmpParent = self.ui.mTrans_OtherPartsSkillDescribe
  local tmpItem = self.ui.mTrans_PartsSkill1
  local hasAddition = false
  setactive(tmpItem.gameObject, false)
  self.subPropList = CS.GunWeaponModData.SetWeaponPartAttr(self.gunWeaponModData, self.ui.mTrans_Attribute.transform, 0, true, 0)
  if self.subPropList.Count >= 1 then
    self.subPropList[self.subPropList.Count - 1]:ShowLine(false)
  end
  if self.subPropList.Count % 2 == 0 and self.subPropList.Count >= 2 then
    self.subPropList[self.subPropList.Count - 2]:ShowLine(false)
  end
  for i = 0, tmpParent.childCount - 1 do
    setactive(tmpParent:GetChild(i).gameObject, false)
  end
  local index = 1
  local proficiencySkillData = self.gunWeaponModData.ProficiencySkillData
  if proficiencySkillData then
    local item
    if index < tmpParent.childCount then
      item = tmpParent:GetChild(index)
    else
      item = instantiate(tmpItem, tmpParent, false)
    end
    setactive(item.gameObject, true)
    CS.GunWeaponModData.SetProficiencySkill(item, proficiencySkillData.description.str, proficiencySkillData.level)
    index = index + 1
  end
  local gunWeaponModPropertyListWithAddValue = self.gunWeaponModData.GunWeaponModPropertyListWithAddValue
  local hint1 = TableData.GetHintById(250055)
  for i = 0, gunWeaponModPropertyListWithAddValue.Count - 1 do
    local gunWeaponModProperty = gunWeaponModPropertyListWithAddValue[i]
    local item
    if index < tmpParent.childCount then
      item = tmpParent:GetChild(index)
    else
      item = instantiate(tmpItem, tmpParent, false)
    end
    setactive(item.gameObject, true)
    local text = string_format(hint1, gunWeaponModProperty.PropData.show_name.str)
    CS.GunWeaponModData.SetProficiencySkill(item, text, gunWeaponModProperty.AddLevel)
    index = index + 1
  end
  local hint2 = TableData.GetHintById(250057)
  if 0 < self.gunWeaponModData.AddValue.Length then
    setactive(self.ui.mTrans_GroupSkill.gameObject, true)
    self.ui.mImg_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(self.gunWeaponModData.ModPowerData.image, false)
    local text = string_format(hint2, self.gunWeaponModData.ModPowerData.name.str, self.gunWeaponModData.AddLevel)
    self.ui.mTextFit_GroupDescribe.text = text
  else
    setactive(self.ui.mTrans_GroupSkill.gameObject, false)
  end
  local hasAddAttr = false
  local tmpAttrParent = self.ui.mTrans_Attribute.transform
  for i = 0, tmpAttrParent.childCount - 1 do
    if tmpAttrParent:GetChild(i).gameObject.activeSelf then
      hasAddAttr = true
      break
    end
  end
  hasAddition = hasAddAttr or proficiencySkillData ~= nil or 0 < gunWeaponModPropertyListWithAddValue.Count or 0 < self.gunWeaponModData.AddValue.Length
  setactive(self.ui.mTrans_AdditionEffect.gameObject, hasAddition)
end
function UIChrWeaponPartsPolaritySuccessDialog:SetPolarityEffect()
  if self.ui.mTrans_Fx.transform.childCount > 0 then
    ResourceDestroy(self.ui.mTrans_Fx.transform:GetChild(0).gameObject)
  end
  local originalString = self.polarityTagData.icon
end
function UIChrWeaponPartsPolaritySuccessDialog:OnRelease()
  if self.fxGameObject == nil then
    return
  end
  ResourceManager:DestroyInstance(self.fxGameObject)
end
