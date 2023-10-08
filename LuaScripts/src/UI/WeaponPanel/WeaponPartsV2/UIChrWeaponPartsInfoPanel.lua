require("UI.Common.UICommonLockItem")
UIChrWeaponPartsInfoPanel = class("UIChrWeaponPartsInfoPanel", UIBasePanel)
UIChrWeaponPartsInfoPanel.__index = UIChrWeaponPartsInfoPanel
function UIChrWeaponPartsInfoPanel:ctor(csPanel)
  UIChrWeaponPartsInfoPanel.super:ctor(csPanel)
  csPanel.Is3DPanel = true
end
function UIChrWeaponPartsInfoPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.gunWeaponModData = nil
  self.lockItem = nil
  self.subPropList = nil
  self.bgImg = nil
end
function UIChrWeaponPartsInfoPanel:OnInit(root, data)
  self.gunWeaponModData = data.gunWeaponModData
  UIUtils.GetButtonListener(self.ui.mBtn_BtnBack.gameObject).onClick = function()
    UIManager.CloseUI(UIDef.UIChrWeaponPartsInfoPanel)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnHome.gameObject).onClick = function()
    UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(true)
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnLevelUp.gameObject).onClick = function()
    self:OnClickLevelUp()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnPolarity.gameObject).onClick = function()
    self:OnClickPolarity()
  end
  self.bgImg = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("Panel"):GetComponent(typeof(CS.UnityEngine.UI.Image))
  self:InitLockItem()
end
function UIChrWeaponPartsInfoPanel:OnShowStart()
  BarrackHelper.CameraMgr:SetWeaponRT()
  UIBarrackWeaponModelManager:ShowCurWeaponModel(false)
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(false)
  BarrackHelper.CameraMgr:ChangeCameraStand(BarrackCameraStand.Weapon, false)
  self:SetWeaponPartsData()
end
function UIChrWeaponPartsInfoPanel:OnRecover()
end
function UIChrWeaponPartsInfoPanel:OnBackFrom()
  self:SetWeaponPartsData()
end
function UIChrWeaponPartsInfoPanel:OnTop()
end
function UIChrWeaponPartsInfoPanel:OnShowFinish()
end
function UIChrWeaponPartsInfoPanel:OnHide()
end
function UIChrWeaponPartsInfoPanel:OnHideFinish()
  if UIWeaponGlobal.GetNeedCloseBarrack3DCanvas() then
    UIWeaponGlobal:ReleaseWeaponModel()
    CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  end
end
function UIChrWeaponPartsInfoPanel:OnClose()
  self.lockItem:OnRelease(true)
end
function UIChrWeaponPartsInfoPanel:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPartsInfoPanel:InitLockItem()
  local parent = self.ui.mScrollListChild_BtnLock.transform
  local obj
  if parent.childCount > 0 then
    obj = parent:GetChild(0)
  end
  self.lockItem = UICommonLockItem.New()
  self.lockItem:InitCtrl(parent, obj)
  self.lockItem:AddClickListener(function(isOn)
    self:OnClickLock(isOn)
  end)
end
function UIChrWeaponPartsInfoPanel:SetWeaponPartsData()
  UIWeaponGlobal.SetNeedCloseBarrack3DCanvas(false)
  self.bgImg.sprite = ResSys:GetWeaponBgSprite("Img_Weapon_Bg")
  UISystem.BarrackCharacterCameraCtrl:ShowBarrack3DCanvas(true)
  self.gunWeaponModData = NetCmdWeaponPartsData:GetWeaponModById(self.gunWeaponModData.id)
  local tmpGunWeaponModData = self.gunWeaponModData
  self.ui.mText_Name.text = tmpGunWeaponModData.name
  self.ui.mText_Type.text = tmpGunWeaponModData.weaponModTypeData.Name.str
  self.ui.mText_Quality.text = tmpGunWeaponModData.QualityStr
  self.ui.mImg_TypeIcon.sprite = ResSys:GetWeaponPartEffectSprite(tmpGunWeaponModData.ModEffectTypeData.icon)
  self.ui.mText_NumNow.text = GlobalConfig.SetLvText(tmpGunWeaponModData.level)
  self.ui.mText_Max.text = "/" .. tmpGunWeaponModData.maxLevel
  self.ui.mImg_QualityLine.color = TableData.GetGlobalGun_Quality_Color2(tmpGunWeaponModData.rank, self.ui.mImg_QualityLine.color.a)
  self.ui.mText_Num.text = tmpGunWeaponModData.Capacity
  self.ui.mImg_WeaponPartsIcon.sprite = IconUtils.GetWeaponPartIcon(tmpGunWeaponModData.icon)
  if tmpGunWeaponModData.PolarityTagData ~= nil then
    setactive(self.ui.mImg_PolarityIcon.gameObject, true)
    self.ui.mImg_PolarityIcon.sprite = IconUtils.GetElementIcon(tmpGunWeaponModData.PolarityTagData.icon .. "_S")
  else
    setactive(self.ui.mImg_PolarityIcon.gameObject, false)
  end
  self.ui.mText_Text.text = tmpGunWeaponModData.weaponModTypeData.weapon_mod_des.str
  self.ui.mTextFit_Describe.text = tmpGunWeaponModData.ItemData.introduction.str
  self.subPropList = CS.GunWeaponModData.SetWeaponPartAttr(tmpGunWeaponModData, self.ui.mScrollListChild_GrpItem.transform)
  setactive(self.ui.mText_Num1.gameObject, false)
  self:UpdateLockStatue()
  self:UpdateIsUse()
  self:UpdateWeaponPartsSkill()
  self:UpdateAction()
end
function UIChrWeaponPartsInfoPanel:UpdateIsUse()
  setactive(self.ui.mTrans_State.gameObject, self.gunWeaponModData.equipWeapon ~= 0)
end
function UIChrWeaponPartsInfoPanel:UpdateLockStatue()
  self.lockItem:SetLock(self.gunWeaponModData.IsLocked)
end
function UIChrWeaponPartsInfoPanel:UpdateWeaponPartsSkill()
  local modPowerData = self.gunWeaponModData.ModPowerData
  local groupSkillData = self.gunWeaponModData.GroupSkillData
  local PowerSkillCsData = self.gunWeaponModData.PowerSkillCsData
  if nil == groupSkillData then
    setactive(self.ui.mTrans_GroupSkill.gameObject, false)
  else
    setactive(self.ui.mTrans_GroupSkill.gameObject, true)
    CS.GunWeaponModData.SetModPowerDataNameWithLevel(self.ui.mText_Skill, modPowerData, self.gunWeaponModData)
    local showText = self.gunWeaponModData:GetModGroupSkillShowText()
    self.ui.mTextFit_GroupDescribe.text = showText
    self.ui.mImg_SuitIcon.sprite = IconUtils.GetWeaponPartIconSprite(self.gunWeaponModData.ModPowerData.image, false)
  end
  local tmpParent = self.ui.mTrans_OtherPartsSkillDescribe1
  local tmpItem = self.ui.mTrans_PartsSkill1
  local count = CS.GunWeaponModData.SetWeaponPartProficiencySkill(self.gunWeaponModData, tmpParent, tmpItem)
  setactive(self.ui.mTrans_PartsSkill.gameObject, nil ~= groupSkillData or 0 ~= count)
end
function UIChrWeaponPartsInfoPanel:UpdateAction()
  setactive(self.ui.mBtn_BtnLevelUp.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_BtnPolarity.transform.parent.gameObject, false)
  setactive(self.ui.mTrans_Disable.gameObject, false)
  setactive(self.ui.mTrans_Mismatch.gameObject, false)
  setactive(self.ui.mTrans_MaxLevel.gameObject, false)
  if not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpartUpgrade) then
    setactive(self.ui.mTrans_Mismatch.gameObject, true)
    local unlockData = AccountNetCmdHandler:GetUnlockDataBySystemId(SystemList.GundetailWeaponpartUpgrade)
    local str = UIUtils.CheckUnlockPopupStr(unlockData)
    self.ui.mText_MismatchName.text = str
    return
  end
  if not AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpartPolarity) then
    setactive(self.ui.mTrans_Disable.gameObject, true)
    local unlockData = AccountNetCmdHandler:GetUnlockDataBySystemId(SystemList.GundetailWeaponpartPolarity)
    local str = UIUtils.CheckUnlockPopupStr(unlockData)
    self.ui.mText_MismatchName.text = str
    return
  end
  if self.gunWeaponModData.PolarityId ~= 0 then
    setactive(self.ui.mTrans_MaxLevel.gameObject, true)
    return
  end
  if self.gunWeaponModData.level < self.gunWeaponModData.maxLevel then
    setactive(self.ui.mBtn_BtnLevelUp.transform.parent.gameObject, true)
    return
  end
  if not self.gunWeaponModData.WeaponModData.can_polarity then
    setactive(self.ui.mTrans_Disable.gameObject, true)
    return
  end
  setactive(self.ui.mBtn_BtnPolarity.transform.parent.gameObject, true)
end
function UIChrWeaponPartsInfoPanel:OnClickLevelUp()
  local param = {
    gunWeaponModData = self.gunWeaponModData,
    openFrom = 1
  }
  UIManager.OpenUIByParam(UIDef.UIChrWeaponPartsPowerUpPanelV4, param)
end
function UIChrWeaponPartsInfoPanel:OnClickPolarity()
  self:OnClickLevelUp()
end
function UIChrWeaponPartsInfoPanel:OnClickLock(isOn)
  if isOn == self.gunWeaponModData.IsLocked then
    return
  end
  NetCmdWeaponPartsData:ReqWeaponPartLockUnlock(self.gunWeaponModData.id, function(ret)
    if ret == ErrorCodeSuc then
      self:UpdateLockStatue()
    end
  end)
end
