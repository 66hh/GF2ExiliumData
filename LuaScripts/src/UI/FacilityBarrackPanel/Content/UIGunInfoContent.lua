require("UI.Common.PropertyItemS")
UIGunInfoContent = class("UIGunInfoContent", UIBarrackContentBase)
UIGunInfoContent.__index = UIGunInfoContent
local self = UIGunInfoContent
UIGunInfoContent.PrefabPath = "Character/ChrOverviewPanelV2.prefab"
UIGunInfoContent.skillList = {}
function UIGunInfoContent:ctor(obj)
  self.gunMaxLevel = 0
  self.nextLevelExp = 0
  self.attributeList = {}
  self.upgradeList = {}
  self.dutyItem = nil
  self.fragmentItem = nil
  self.isGunLock = false
  UIGunInfoContent.super.ctor(self, obj)
end
function UIGunInfoContent:__InitCtrl()
  UIGunInfoContent.super.__InitCtrl(self)
  self.mBtn_PowerInfo = self.ui.mBtn_PowerInfo
  self.mBtn_LevelUp = self.ui.mBtn_LevelUp
  self.mBtn_Fragment = self.ui.mBtn_Fragment
  self.mBtn_Supply = self.ui.mBtn_Supply
  self.mTrans_Level = self.ui.mTrans_Level
  self.mText_Level = self.ui.mText_Level
  self.mText_Exp = self.ui.mText_Exp
  self.mImage_ExpIcon = self.ui.mImage_ExpIcon
  self.mText_Name = self.ui.mText_ChrName
  self.mImage_Class = self.ui.mImage_Class
  self.mText_Power = self.ui.mText_Power
  self.mImage_Rank = self.ui.mImage_Rank
  self.mTrans_AttrList = self.ui.mTrans_AttrList
  self.mTrans_Duty = self.ui.mTrans_Duty
  self.mText_DutyName = self.ui.mText_DutyName
  self.mImage_Element = self.ui.mImage_Element
  self.mText_ElementName = self.ui.mText_ElementName
  setactive(self.ui.mTrans_ElementText.gameObject, false)
  setactive(self.ui.mTrans_Element.gameObject, false)
  self.mTrans_CostContent = self.ui.mTrans_CostContent
  self.mTrans_FragmentBtn = self.ui.mTrans_FragmentBtn
  self.mTrans_MaxLevel = self.ui.mTrans_MaxLevel
  self.mText_MaxHint = self.ui.mText_MaxHint
  self.mTrans_LevelUp = self.ui.mTrans_LevelUp
  self.mTrans_FragmentItem = self.ui.mTrans_FragmentItem
  self.mTrans_Lock = self.ui.mTrans_Lock
  self.mText_LockHint = self.ui.mText_LockHint
  self.mImage_Talent = self.ui.mImage_Talent
  self.mAni_Root = self.ui.mAni_Root
  UIUtils.GetButtonListener(self.mBtn_PowerInfo.gameObject).onClick = function()
    self:OnClickPowerInfo()
  end
  UIUtils.GetButtonListener(self.mBtn_Fragment.gameObject).onClick = function()
    self:OnClickFragment()
  end
  UIUtils.GetButtonListener(self.mBtn_Supply.gameObject).onClick = function()
    self:OnClickSupply()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_StageUp.gameObject).onClick = function()
    if FacilityBarrackGlobal.UIModel ~= nil then
      FacilityBarrackGlobal.UIModel:StopAudio()
    end
    self:OnClickStageUp()
  end
  self.btnTrainingCtrl = UIBtnTrainingCtrl.New(self.mBtn_LevelUp)
  self.btnTrainingCtrl:AddBtnClickListener(function()
    self:OnClickTraining()
  end)
  self.btnTrainingCtrl:AddCountdownEndListener(function()
    self:OnTrainingCountdownEnd()
  end)
  for i = 1, TableData.GlobalSystemData.GunMaxGrade do
    local obj = self.ui.mTrans_Stage.transform:GetChild(i - 1)
    local item = self:InitUpgrade(obj)
    table.insert(self.upgradeList, item)
  end
  UIGunInfoContent.skillList = {}
  for i = 1, 4 do
    local obj = self.ui.mTrans_Skill.transform:GetChild(i - 1)
    local item = self:InitSkill(obj, i)
    table.insert(UIGunInfoContent.skillList, item)
  end
  self:InitAttributeList()
  self:InitDutyItem()
  self:InitFragmentItem()
  self:OnEnable(true)
end
function UIGunInfoContent:InitUpgrade(obj)
  if obj then
    local item = {}
    item.obj = obj
    item.transOn = UIUtils.GetRectTransform(obj, "Trans_On")
    item.transOff = UIUtils.GetRectTransform(obj, "Trans_Off")
    return item
  end
end
function UIGunInfoContent:InitSkill(parent, type)
  if parent then
    local item = {}
    local obj = self:InstanceUIPrefab("Character/ChrBarrackSkillItemV2.prefab", parent, true)
    item.obj = obj
    item.type = type
    item.btnSkill = UIUtils.GetButton(obj)
    item.imgIcon = UIUtils.GetImage(obj, "GrpIcon/Img_Icon")
    item.txtLevel = UIUtils.GetText(obj, "GrpLevel/GrpText/Text_Level")
    item.transLock = UIUtils.GetRectTransform(obj, "Trans_GrpLock")
    item.transRedPoint = UIUtils.GetRectTransform(obj, "GrpRedPoint")
    return item
  end
end
function UIGunInfoContent:InitAttributeList()
  for i, att in ipairs(FacilityBarrackGlobal.ShowAttribute) do
    local go = self:Instantiate("UICommonFramework/ComAttributeUpListItem_W.prefab", self.mTrans_AttrList)
    local attr = UICommonPropertyItem.New()
    attr:InitObj(go)
    attr:SetDataByName(att, 0, true, true, false, false)
    table.insert(self.attributeList, attr)
  end
end
function UIGunInfoContent:InitDutyItem()
  if self.dutyItem == nil then
    self.dutyItem = UICommonDutyItem.New()
    self.dutyItem:InitCtrl(self.mTrans_Duty)
  end
end
function UIGunInfoContent:InitTalent()
  local id = self.mData.id
  local isTalentSysLock = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.SquadTalent)
  if not isTalentSysLock then
    setactive(self.mImage_Talent.transform, false)
    return
  end
  if NetCmdTalentData:GetTalentTreeGroupId(id) == 0 then
    setactive(self.mImage_Talent.transform, false)
    return
  end
  setactive(self.mImage_Talent.transform, true)
  local sprite = NetCmdTalentData:GetTalentIcon(id)
  if sprite ~= nil then
    self.mImage_Talent.sprite = sprite
  else
    printstack("mylog:Lua:" .. "出错了")
  end
end
function UIGunInfoContent:InitFragmentItem()
  local item = UICommonItem.New()
  item:InitCtrl(self.mTrans_FragmentItem)
  self.fragmentItem = item
end
function UIGunInfoContent:OnShow()
  if FacilityBarrackGlobal.GunDataDirty then
    self:UpdateOnGunLevelGhange()
    FacilityBarrackGlobal.GunDataDirty = false
  end
  function self.tempOnShotChrVcamBlendFinishCallback()
    self:onShotChrVcamBlendFinishCallback()
  end
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Shot):FinishCallback("+", self.tempOnShotChrVcamBlendFinishCallback)
  function self.tempOnBaseVcamBlendFinishCallback()
    self:onBaseVcamBlendFinishCallback()
  end
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Base):FinishCallback("+", self.tempOnBaseVcamBlendFinishCallback)
  self.ui.mAni_Root:SetTrigger("FadeIn")
  UISystem.BarrackCharacterCameraCtrl:AttachChrTouchCtrlEvents()
end
function UIGunInfoContent:OnPanelBack()
  setactive(self:GetRoot(), true)
  self.btnTrainingCtrl:Refresh()
  self.ui.mAni_Root:SetTrigger("FadeIn")
  self:UpdateContent()
  UISystem.BarrackCharacterCameraCtrl:AttachChrTouchCtrlEvents()
end
function UIGunInfoContent:OnHide()
end
function UIGunInfoContent:SetData(data, parent)
  self.super.SetData(self, data, parent)
  self.isGunLock = NetCmdTeamData:GetGunByID(data.id) == nil
  self:UpdateContent()
  self:EnableModel(true)
  self:EnableLevelInfo(not parent.switchGun)
  self.btnTrainingCtrl:SetData(data.id)
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base)
  setactive(self.ui.mBtn_StageUp, not self.isGunLock)
  setactive(self.ui.mTrans_StageUpRedPoint.gameObject, NetCmdTeamData:UpdateUpgradeRedPoint(self.mData) ~= 0)
end
function UIGunInfoContent:UpdateContent()
  self:UpdateLevelInfo(self.mData.MaxGunLevel)
  self:UpdateGunInfo()
end
function UIGunInfoContent:UpdateLevelInfo(maxLevel)
  local gunData = self.mData
  self.gunMaxLevel = maxLevel
  self.mText_Level.text = TableData.GetHintById(140040, gunData.level, self.gunMaxLevel)
  local count = NetCmdItemData:GetItemCountById(GlobalConfig.GunExpItem)
  local nextLevel = gunData.level >= self.gunMaxLevel and self.gunMaxLevel or gunData.level + 1
  self.nextLevelExp = TableData.listGunLevelExpDatas:GetDataById(nextLevel).exp
  self.mImage_ExpIcon.sprite = IconUtils.GetItemIconSprite(GlobalConfig.GunExpItem)
  if count < self.nextLevelExp then
    self.mText_Exp.text = string_format("<color=#FF5E41>{0}</color>/{1}", count, self.nextLevelExp)
  else
    self.mText_Exp.text = string_format("{0}/{1}", count, self.nextLevelExp)
  end
  self:InitTalent()
end
function UIGunInfoContent:UpdateGunInfo()
  local gunData = self.mData
  local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.TabGunData.duty)
  self.mText_Name.text = gunData.TabGunData.name.str
  self.mImage_Class.sprite = IconUtils.GetMentalIcon(gunData.curGunClass.icon)
  self.mText_Power.text = NetCmdTeamData:GetGunFightingCapacity(gunData)
  self.mImage_Rank.color = TableData.GetGlobalGun_Quality_Color2(gunData.TabGunData.rank)
  self.mText_DutyName.text = dutyData.name.str
  local elementData = TableData.listLanguageElementDatas:GetDataById(gunData.TabGunData.Element)
  if elementData ~= nil then
    self.mImage_Element.sprite = IconUtils.GetElementIconM(elementData.icon)
    self.mText_ElementName.text = elementData.name.str
  end
  self.dutyItem:SetData(dutyData)
  for i, item in ipairs(self.upgradeList) do
    setactive(item.transOn, i <= gunData.upgrade)
    setactive(item.transOff, i > gunData.upgrade)
  end
  self:UpdateAttributeList()
  self:UpdateSkillItem()
  self:UpdateFragment()
  self:UpdateGunLevelLock()
end
function UIGunInfoContent:UpdateFightingCapacity()
  self.mText_Power.text = NetCmdTeamData:GetGunFightingCapacity(self.mData)
end
function UIGunInfoContent:UpdateGunLevelLock()
  local isUnlock = AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailLevelup)
  local lockInfo = TableData.GetUnLockInfoByType(SystemList.GundetailLevelup)
  local isMaxLevel = self.mData.level >= self.gunMaxLevel
  local isMaxClass = self.mData:IsMaxClass()
  self.btnTrainingCtrl:SetVisible(not self.isGunLock and (not isMaxLevel or not isMaxClass) and isUnlock)
  setactive(self.mTrans_Lock, not self.isGunLock and not isUnlock)
  setactive(self.mTrans_MaxLevel, isMaxLevel and isMaxClass and isUnlock)
  setactive(self.mTrans_CostContent, not self.isGunLock and not isMaxLevel and isUnlock)
  setactive(self.mBtn_Supply.gameObject.transform.parent, not self.isGunLock and isUnlock)
  local hint = ""
  if isMaxLevel and isMaxClass then
    hint = TableData.GetHintById(30020)
  end
  self.mText_MaxHint.text = hint
  local str = UIUtils.CheckUnlockPopupStr(lockInfo)
  PopupMessageManager.PopupString(str)
  self.mText_LockHint.text = str
end
function UIGunInfoContent:UpdateSkillItem()
  if UIGunInfoContent.skillList then
    local data = self.mData.CurAbbr
    for i = 0, data.Count - 1 do
      local skillData = TableData.listBattleSkillDatas:GetDataById(data[i])
      local skill = UIGunInfoContent.skillList[i + 1]
      skill.data = skillData
      skill.imgIcon.sprite = IconUtils.GetSkillIconByAttr(skillData.icon, skillData.icon_attr_type)
      skill.txtLevel.text = TableData.GetHintById(102246) .. skillData.level
      UIUtils.GetButtonListener(skill.btnSkill.gameObject).onClick = function()
        self:OnClickSkill(skillData, i + 1)
      end
      setactive(skill.transRedPoint, false)
    end
  end
end
function UIGunInfoContent:UpdateFragment()
  if self.isGunLock and self.fragmentItem then
    self.fragmentItem:SetItemData(self.mData.TabGunData.core_item_id, tonumber(self.mData.TabGunData.unlock_cost), true, true)
  end
  setactive(self.mTrans_FragmentItem, self.isGunLock)
  setactive(self.mTrans_FragmentBtn, self.isGunLock)
end
function UIGunInfoContent:UpdateOnGunLevelGhange()
  self:UpdateLevelInfo(self.mData.MaxGunLevel)
  self:UpdateAttributeList()
  self:UpdateGunLevelLock()
  self.mImage_Class.sprite = IconUtils.GetMentalIcon(self.mData.curGunClass.icon)
end
function UIGunInfoContent:OnClickSkill(skillData, pos)
  UIManager.OpenUIByParam(UIDef.UIChrSkillInfoDialog, {
    skillData = skillData,
    gunCmdData = self.mData,
    isGunLock = self.isGunLock,
    pos = pos,
    showBottomBtn = true
  })
end
function UIGunInfoContent.OnUpdate()
end
function UIGunInfoContent:OnClickTraining()
  self:EnableMask(true)
  self:RecordAttrValue()
  self.mParent:FadeOut()
  self:OnEnable(false)
  self:GunModelStopAudioAndEffect()
  UIManager.OpenUIByParam(UIDef.UIBarrackTrainingPanel, self.mData.id)
  BarrackHelper.CameraMgr:StartCameraMoving(CS.BarrackCameraOperate.BaseToPrepare)
end
function UIGunInfoContent:onShotChrVcamBlendFinishCallback()
  local basePanelUI = UISystem:GetTopPanelUI()
  if basePanelUI.UIDefine.UIType ~= UIDef.UICharacterDetailPanel then
    return
  end
  UIManager.OpenUIByParam(UIDef.UIBarrackTrainingPanel, self.mData.id)
end
function UIGunInfoContent:onBaseVcamBlendFinishCallback()
  UISystem.BarrackCharacterCameraCtrl:AttachChrTouchCtrlEvents()
end
function UIGunInfoContent:OnTrainingCountdownEnd()
end
function UIGunInfoContent:OnClickPowerInfo()
  UIManager.OpenUIByParam(UIDef.UICharacterPropPanel, self.mData.id)
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
end
function UIGunInfoContent:OnClickFragment()
  if self.fragmentItem then
    if not self.fragmentItem:IsItemEnough() then
      CS.PopupMessageManager.PopupString(GlobalConfig.GetCostNotEnoughStr(self.fragmentItem.itemId))
      return
    else
      NetCmdTrainGunData:SendCmdUpgradeGun(self.mData.id, function(ret)
        self:UnLockCallBack(ret)
      end)
    end
  end
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
end
function UIGunInfoContent:OnClickSupply()
  printstack("  OnClickSupply  ")
  local params = CS.System.Array.CreateInstance(typeof(CS.System.Object), 2)
  params[0] = self.mData.id
  params[1] = self.mData.Bullet
  UIManager.OpenUIByParam(CS.GF2.UI.enumUIPanel.SupplyConfigPanel, params)
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
end
function UIGunInfoContent:OnClickStageUp()
  local id = FacilityBarrackGlobal.PowerUpType.Upgrade
  local barrackData = TableData.listBarrackDatas:GetDataById(id)
  if not barrackData then
    return
  end
  if TipsManager.NeedLockTips(barrackData.systemId) then
    return
  end
  UIManager.OpenUIByParam(UIDef.UIUpgradeContent, self.mData)
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
end
function UIGunInfoContent:UnLockCallBack(ret)
  if ret == ErrorCodeSuc then
    printstack("解锁人形成功")
    local data = {}
    data.ItemId = self.mData.id
    UICommonGetGunPanel.OpenGetGunPanel({data}, function()
      if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.CommandCenter then
        SceneSys:SwitchVisible(CS.EnumSceneType.Barrack)
      end
    end, nil, true)
    self:RefreshGun()
  else
    printstack("解锁人形失败")
  end
end
function UIGunInfoContent:UpdateAttributeList()
  for i, attName in ipairs(FacilityBarrackGlobal.ShowAttribute) do
    local attr = self.attributeList[i]
    local value = self:GetTotalPropValueByName(attName)
    attr:UpdateAttrValue(value, self.mData.AttackType)
  end
end
function UIGunInfoContent:GetTotalPropValueByName(name)
  local weaponPercentValue = self.mData:GetWeaponPercentValueByName(name)
  local gunTalentPercentValue = self.mData:GetGunTalentPercentValueByName(name)
  local propertyValue = self.mData:GetGunPropertyValueByType(name)
  return math.ceil(propertyValue * (1 + (weaponPercentValue + gunTalentPercentValue) / 1000))
end
function UIGunInfoContent:RecordAttrValue()
  for i, attr in ipairs(self.attributeList) do
    attr:RecordValue()
  end
end
function UIGunInfoContent:GetSkillDataList()
  local list = {}
  return list
end
function UIGunInfoContent:EnableLevelInfo(enable)
  setactive(self.mTrans_Level, enable)
end
function UIGunInfoContent:OnEnable(enable)
  UIGunInfoContent.super.OnEnable(self, enable)
  if enable then
    if self.mParent then
      self.mParent.ui.mAni_Root:ResetTrigger("Visual_Fade_Out")
      self.mParent.ui.mAni_Root:SetTrigger("Visual_FadeIn")
    end
  elseif self.mParent then
    self.mParent.ui.mAni_Root:ResetTrigger("Visual_FadeIn")
    self.mParent.ui.mAni_Root:SetTrigger("Visual_Fade_Out")
  end
  if enable then
    UIModelToucher.SwitchToucher(1)
  else
    self:StopAttrAni()
  end
end
function UIGunInfoContent:OnRelease()
  self.btnTrainingCtrl:OnRelease()
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Shot):FinishCallback("-", self.tempOnShotChrVcamBlendFinishCallback)
  UISystem.BarrackCharacterCameraCtrl:GetBinding(FacilityBarrackGlobal.CameraType.Base):FinishCallback("-", self.tempOnBaseVcamBlendFinishCallback)
  UIGunInfoContent.super.OnRelease(self)
  self:StopAttrAni()
end
function UIGunInfoContent:PlayTextGroupUpAni()
  for i, attr in ipairs(self.attributeList) do
    attr:PlayGroupAni((i - 1) * 0.06)
  end
end
function UIGunInfoContent:StopAttrAni()
  for i, attr in ipairs(self.attributeList) do
    attr:Release()
  end
end
function UIGunInfoContent.GetSkillByPos(pos)
  return UIGunInfoContent.skillList[pos]
end
function UIGunInfoContent:PlaySwitchInAni()
  if self.mAni_Root then
    self.mAni_Root:SetTrigger("Switch")
  end
end
