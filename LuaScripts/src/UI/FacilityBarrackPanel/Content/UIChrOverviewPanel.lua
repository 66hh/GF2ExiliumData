require("UI.WeaponPanel.UIWeaponPanel")
require("UI.FacilityBarrackPanel.Item.ChrWeaponItem")
require("UI.Character.UIComStageItemV3")
require("UI.FacilityBarrackPanel.Content.UIBtnTrainingCtrl")
require("UI.FacilityBarrackPanel.Item.ChrAttributeListItemOverview")
require("UI.FacilityBarrackPanel.Content.UIBtnChangeSkinCtrl")
require("UI.FacilityBarrackPanel.Content.UIChangeSkin.UIBarrackChangeSkinPanel")
require("UI.FacilityBarrackPanel.Item.ChrBarrackSkillItem")
UIChrOverviewPanel = class("UIChrOverviewPanel", UIBasePanel)
UIChrOverviewPanel.__index = UIChrOverviewPanel
function UIChrOverviewPanel:ctor(root, uiChrPowerUpPanel)
  UIChrOverviewPanel.super.ctor(self, uiChrPowerUpPanel)
  self.mUIRoot = root
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self.uiChrPowerUpPanel = uiChrPowerUpPanel
  self.isLockGunShow = true
  self.mGunCmdData = nil
  self.mGunData = nil
  self.gunMaxLevel = 0
  self.skillList = {}
  self.attributeList = {}
  self.btnTrainingCtrl = nil
  self.needModel = true
  self.barrackCameraStand = BarrackCameraStand.Base
  self.chrWeaponItem = nil
  self.btnTalentSet = nil
  self.stageItem = nil
  self.isNeedHideEffect = true
  self.isGunUnlockEnough = false
  self.composeRedPoint = nil
  self.chrSwitchRedPoint = nil
  self:InitRank()
  self:InitVisualBtn()
  self:InitAttributeList()
  self:InitSkillList()
  self:InitUIBtnTrainingCtrl()
  self:InitBtnChangeSkin()
  self:InitChrWeaponItem()
  self:InitDorm()
end
function UIChrOverviewPanel:OnInit(data)
  self.mGunCmdData = data
  if self.mGunCmdData ~= nil then
    self.mGunData = self.mGunCmdData.TabGunData
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Detail.gameObject).onClick = function()
    local param = {
      attributeShowType = FacilityBarrackGlobal.AttributeShowType.Gun,
      gunId = self.mGunCmdData.id
    }
    UIManager.OpenUIByParam(UIDef.UIChrAttributeDetailsDialogV3, param)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnChrSwitch.gameObject).onClick = function()
    UIManager.OpenUIByParam(UIDef.UIChrScreenPanel, self.mGunCmdData)
  end
  setactive(self.ui.mBtn_ExitVisual_TL.transform.parent.gameObject, true)
  setactive(self.ui.mBtn_ExitVisual_TR.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_ExitVisual_BL.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_ExitVisual_BR.transform.parent.gameObject, false)
  setactive(self.ui.mTrans_TextTips_Top.gameObject, true)
  setactive(self.ui.mTrans_TextTips_Bottom.gameObject, false)
  UIUtils.GetButtonListener(self.ui.mBtn_ExitVisual_TL.gameObject).onClick = function()
    self:OnClickVisual(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ExitVisual_TR.gameObject).onClick = function()
    self:OnClickVisual(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ExitVisual_BL.gameObject).onClick = function()
    self:OnClickVisual(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_ExitVisual_BR.gameObject).onClick = function()
    self:OnClickVisual(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_BtnCompose.gameObject).onClick = function()
    self:OnClickBtnCompose()
  end
  self.ui.mToggle_MaxView.onValueChanged:AddListener(function(isOn)
    self.mGunCmdData = NetCmdTeamData:GetLockGunData(self.mGunCmdData.id, true, isOn)
    FacilityBarrackGlobal.IsBattlePassMaxLevel = isOn
    self.ui.mToggle_MaxView.isOn = isOn
    self:RefreshGunData()
  end)
  local composeContainner = self.ui.mBtn_BtnCompose.transform:Find("Root/Trans_RedPoint").gameObject:GetComponent(typeof(CS.UICommonContainer))
  self.composeRedPoint = composeContainner.transform
  self.chrSwitchRedPoint = self.ui.mBtn_BtnChrSwitch.transform:Find("Trans_RedPoint")
  self:AddListener()
end
function UIChrOverviewPanel:OnShowStart()
  setactive(self.mUIRoot.gameObject, true)
  self.btnTrainingCtrl:SetInteractable(true)
  self.btnChangeSkinCtrl:SetInteractable(true)
  self:SetData()
end
function UIChrOverviewPanel:OnRecover()
end
function UIChrOverviewPanel:OnBackFrom()
  setactive(self.mUIRoot.gameObject, true)
  self.btnTrainingCtrl:SetInteractable(true)
  self.btnChangeSkinCtrl:SetInteractable(true)
  local normalView = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview
  if normalView == true then
    self:SetData()
  end
  BarrackHelper.SceneMgr:SetAimoLineEffectVisible(false)
end
function UIChrOverviewPanel:OnTop()
  setactive(self.mUIRoot.gameObject, true)
  self:SetData()
end
function UIChrOverviewPanel:OnShowFinish()
  self:OnShowStart()
  setactive(self.ui.mTrans_TouchPad, false)
  local gunid = self.mGunCmdData.Id
  self.ui.mAnimator_Dorm:SetBool("UnLock", NetCmdTeamData:IsDormSystemUnlock() and NetCmdTeamData:GetGunDormUnlockByUnlockedID(gunid) ~= nil)
end
function UIChrOverviewPanel:OnUpdate(deltaTime)
end
function UIChrOverviewPanel:OnHideFinish()
end
function UIChrOverviewPanel:OnClose()
  setactive(self.mUIRoot.gameObject, false)
  self:RemoveListener()
end
function UIChrOverviewPanel:OnRelease()
  self.super.OnRelease(self)
end
function UIChrOverviewPanel:OnHide()
end
function UIChrOverviewPanel:OnRefresh()
  self:OnBackFrom()
end
function UIChrOverviewPanel:InitRank()
  local tmpStageParent = self.ui.mScrollListChild_GrpStage.transform
  local stageItem = UIComStageItemV3.New()
  if 1 <= tmpStageParent.childCount then
    stageItem:InitCtrl(tmpStageParent, true, tmpStageParent:GetChild(0))
  else
    stageItem:InitCtrl(tmpStageParent, true)
  end
  self.stageItem = stageItem
end
function UIChrOverviewPanel:InitAttributeList()
  self:InitShowAttributeOnPc()
  local tmpAttriParent = self.ui.mScrollListChild_Content.transform
  for i, att in ipairs(FacilityBarrackGlobal.ShowAttribute) do
    local attr = ChrAttributeListItemOverview.New()
    if i <= tmpAttriParent.childCount then
      attr:InitCtrl(tmpAttriParent, tmpAttriParent:GetChild(i - 1))
    else
      attr:InitCtrl(tmpAttriParent)
    end
    table.insert(self.attributeList, attr)
  end
end
function UIChrOverviewPanel:InitSkillList()
  self.skillList = {}
  local tmpSkillParent = self.ui.mScrollListChild_GrpSkill.transform
  for i = 1, 5 do
    local skillItem = ChrBarrackSkillItem.New()
    if i <= tmpSkillParent.childCount then
      skillItem:InitCtrl(tmpSkillParent, tmpSkillParent:GetChild(i - 1))
    else
      skillItem:InitCtrl(tmpSkillParent)
    end
    table.insert(self.skillList, skillItem)
  end
end
function UIChrOverviewPanel:InitShowAttributeOnPc()
end
function UIChrOverviewPanel:InitChrWeaponItem()
  local tmpWeaponParent = self.ui.mScrollListChild_WeaponBox.transform
  self.chrWeaponItem = ChrWeaponItem.New()
  if tmpWeaponParent.childCount > 2 then
    self.chrWeaponItem:InitCtrl(tmpWeaponParent, tmpWeaponParent:GetChild(0))
  else
    self.chrWeaponItem:InitCtrl(tmpWeaponParent)
  end
end
function UIChrOverviewPanel:InitUIBtnTrainingCtrl()
  self.btnTrainingCtrl = UIBtnTrainingCtrl.New(self.ui.mTrans_BtnLevelUp)
  self.btnTrainingCtrl:AddBtnClickListener(function()
    self:OnClickTraining()
  end)
  self.btnTrainingCtrl:SetInteractable(false)
end
function UIChrOverviewPanel:OnClickTraining()
  FacilityBarrackGlobal.HideEffectNum()
  self.ui.mAnimator_Root:ResetTrigger("FadeIn")
  BarrackHelper.ModelMgr:ResetBarrackIdle()
  UIManager.OpenUIByParam(UIDef.UIBarrackTrainingPanel, self.mGunCmdData.id)
  BarrackHelper.CameraMgr:StartCameraMoving(BarrackCameraOperate.OverviewToUpgrade)
  self.btnTrainingCtrl:SetInteractable(false)
  self:GunModelStopAudioAndEffect()
  BarrackHelper.SceneMgr:SetAimoLineEffectVisible(true)
end
function UIChrOverviewPanel:InitBtnChangeSkin()
  self.btnChangeSkinCtrl = UIBtnChangeSkinCtrl.New(self.ui.mTrans_ChangeSkin)
  self.btnChangeSkinCtrl:AddBtnClickListener(function()
    self:OnClickChangeSkin()
  end)
  self.btnChangeSkinCtrl:SetInteractable(false)
end
function UIChrOverviewPanel:OnClickChangeSkin()
  FacilityBarrackGlobal.HideEffectNum()
  self.ui.mAnimator_Root:ResetTrigger("FadeIn")
  BarrackHelper.ModelMgr:ResetBarrackIdle()
  self:GunModelStopAudioAndEffect()
  self.btnChangeSkinCtrl:SetInteractable(false)
  FacilityBarrackGlobal.CurSkinShowContentType = FacilityBarrackGlobal.ShowContentType.UIChrOverview
  UIManager.OpenUIByParam(UIDef.UIBarrackChangeSkinPanel, self.mGunCmdData.id)
end
function UIChrOverviewPanel:GetCurGun()
  local gunId = BarrackHelper.ModelMgr.GunStcDataId
  self.isLockGun = NetCmdTeamData:GetGunByStcId(gunId) == nil
  local isBattlePassRelated = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass or FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection
  if FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIGachaPreview then
    self.mGunCmdData = NetCmdTeamData:GetGachaPreviewGunData(gunId)
  elseif isBattlePassRelated then
    self.mGunCmdData = NetCmdTeamData:GetLockGunData(self.mGunCmdData.id, true, FacilityBarrackGlobal.IsBattlePassMaxLevel)
  elseif self.isLockGun then
    self.mGunCmdData = NetCmdTeamData:GetLockGunByStcId(gunId)
  else
    self.mGunCmdData = NetCmdTeamData:GetGunByStcId(gunId)
  end
  self.mGunData = self.mGunCmdData.TabGunData
end
function UIChrOverviewPanel:ResetData()
  self:SetData()
end
function UIChrOverviewPanel:SetData()
  self.ui.mAni_MaxView:SetBool("Bool", false)
  self:GetCurGun()
  self:RefreshGunData()
end
function UIChrOverviewPanel:RefreshGunData()
  local gunData = self.mGunCmdData
  local isBattlePassView = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass or FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection
  local isGachaPreview = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIGachaPreview
  self.gunMaxLevel = self.mGunCmdData.MaxGunLevel
  local dutyData = TableData.listGunDutyDatas:GetDataById(gunData.TabGunData.duty)
  self.ui.mImg_Duty.sprite = IconUtils.GetGunTypeIcon(dutyData.icon .. "_W")
  local dutyTxt = dutyData.name.str
  if gunData.TabGunData.second_duty ~= 0 then
    local secondDutyData = TableData.listSecondDutyDatas:GetDataById(gunData.TabGunData.second_duty)
    dutyTxt = dutyTxt .. "·" .. secondDutyData.name.str
  end
  self.ui.mText_Name1.text = dutyTxt
  self.ui.mText_ChrName.text = gunData.TabGunData.name.str
  self.ui.mText_Num.text = GlobalConfig.SetLvText(gunData.level)
  self.ui.mText_MaxLevel.text = self.gunMaxLevel
  if isGachaPreview then
    self.ui.mText_MaxLevel.text = TableData.GlobalConfigData.GunMaxLv
  elseif isBattlePassView then
    self.gunMaxLevel = TableData.GlobalConfigData.GunMaxLv
    if FacilityBarrackGlobal.IsBattlePassMaxLevel then
      self.ui.mText_Num.text = GlobalConfig.SetLvText(self.gunMaxLevel)
    else
      self.ui.mText_Num.text = GlobalConfig.SetLvText(1)
    end
    self.ui.mText_MaxLevel.text = self.gunMaxLevel
    self.ui.mAni_MaxView:SetBool("Bool", FacilityBarrackGlobal.IsBattlePassMaxLevel)
  end
  setactive(self.ui.mTrans_GrpGachaTalent, isGachaPreview)
  setactive(self.ui.mBtn_Video, isGachaPreview)
  setactive(self.ui.mBtn_GachaTry, isGachaPreview)
  setactive(self.ui.mTrans_GachaPreviewRedpoint, isGachaPreview and not GashaponNetCmdHandler:CheckPoolPreviewed(self.uiChrPowerUpPanel.gachaId))
  if isGachaPreview then
    self:InitGachaPreview()
  end
  local isRelateBp = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass or FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection
  self.btnTrainingCtrl:SetData(gunData.Id)
  self.btnTrainingCtrl:Refresh()
  self.btnChangeSkinCtrl:SetData(gunData.Id)
  self.btnChangeSkinCtrl:Refresh()
  local changeSkinBtnVisible = NetCmdTeamData:GetGunByID(gunData.Id) ~= nil and FacilityBarrackGlobal.CurShowContentType ~= FacilityBarrackGlobal.ShowContentType.UIGachaPreview and not isRelateBp
  self.btnChangeSkinCtrl:SetVisible(changeSkinBtnVisible)
  FacilityBarrackGlobal.SetVisualOnClick(function()
    self:OnClickVisual(true)
  end)
  self.ui.mText_Num1.text = NetCmdTeamData:GetGunFightingCapacity(gunData)
  self.ui.mImg_Line.color = TableData.GetGlobalGun_Quality_Color2(gunData.TabGunData.rank, self.ui.mImg_Line.color.a)
  local elementData = TableData.listLanguageElementDatas:GetDataById(gunData.TabGunData.Element)
  if elementData ~= nil then
  end
  local normalView = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview
  setactivewithcheck(self.ui.mBtn_Dorm, normalView)
  setactive(self.ui.mTrans_ChrMaxView, isRelateBp)
  setactive(self.ui.mBtn_BtnChrSwitch, normalView)
  setactive(self.ui.mTrans_BtnCompose, gunData.isLockGun and normalView)
  setactive(self.ui.mTrans_BtnLevelUp, not gunData.isLockGun and normalView)
  setactive(self.ui.mTrans_Equipment, not gunData.isLockGun and normalView)
  local unlockId = gunData.TabGunData.unlock_hint
  setactive(self.ui.mTrans_GainWays, gunData.isLockGun and normalView and 0 < unlockId)
  if gunData.isLockGun and normalView then
    self.ui.mText_Way1.text = TableData.GetHintById(unlockId)
  end
  setactive(self.ui.mBtn_Detail.gameObject, not gunData.isLockGun and FacilityBarrackGlobal.CurShowContentType ~= FacilityBarrackGlobal.ShowContentType.UIGachaPreview)
  if isBattlePassView then
    self.btnTrainingCtrl:SetVisible(false)
  end
  setactive(self.ui.mTrans_GrpTalent, not gunData.isLockGun and normalView)
  self.canHideEffect = true
  if gunData.isLockGun then
    local itemData = TableData.listItemDatas:GetDataById(self.mGunData.core_item_id)
    local curChipNum = NetCmdItemData:GetItemCount(itemData.id)
    local unLockNeedNum = tonumber(self.mGunData.unlock_cost)
    self.isGunUnlockEnough = curChipNum >= unLockNeedNum
    if self.isGunUnlockEnough then
      self.ui.mText_ComposeNum.text = curChipNum .. "/" .. unLockNeedNum
    else
      self.ui.mText_ComposeNum.text = "<color=red>" .. curChipNum .. "</color>/" .. unLockNeedNum
    end
    self.ui.mImg_ComposeItem.sprite = IconUtils.GetItemIconSprite(self.mGunData.core_item_id)
    UIUtils.GetButtonListener(self.ui.mBtn_ConsumeItem.gameObject).onClick = function()
      UITipsPanel.Open(itemData, 0, true)
    end
    setactive(self.composeRedPoint.gameObject, self.isGunUnlockEnough)
  else
    self:UpdateTalent()
    self:UpdateChrWeaponItem()
    self:UpdateGunLevelLock()
  end
  self:UpdateRank()
  self:UpdateAttributeList()
  self:UpdateSkillList()
  self:UpdateRedPoint()
  self:UpdateDorm()
end
function UIChrOverviewPanel:InitGachaPreview()
  local gachaID = self.uiChrPowerUpPanel.gachaId
  if gachaID ~= 0 then
    local gachaData = TableDataBase.listGachaDatas:GetDataById(gachaID)
    setactive(self.ui.mBtn_Video, true)
    setactive(self.ui.mBtn_GachaTry, tonumber(gachaData.gun_up_character) == self.uiChrPowerUpPanel.mGunCmdData.id)
    local gunData = TableData.listGunDatas:GetDataById(self.uiChrPowerUpPanel.mGunCmdData.id)
    UIUtils.GetButtonListener(self.ui.mBtn_Video.gameObject).onClick = function()
      CS.CriWareVideoController.StartPlay(gunData.gacha_get_timeline .. ".usm", CS.CriWareVideoType.eVideoPath, function()
      end, true, 1, false, -1, 0, {
        gunData.gacha_get_audio,
        gunData.gacha_get_voice
      })
    end
    UIUtils.GetButtonListener(self.ui.mBtn_GachaTry.gameObject).onClick = function()
      setactive(FacilityBarrackGlobal.EffectNumAnimator, false)
      GashaponNetCmdHandler:PreviewPool(self.uiChrPowerUpPanel.gachaId)
      UIManager.OpenUIByParam(UIDef.UIGashaponChrTryDialog, gachaData)
    end
  else
    setactive(self.ui.mBtn_Video, false)
    setactive(self.ui.mBtn_GachaTry, false)
  end
  local talentGunData = TableData.listSquadTalentGunDatas:GetDataById(self.mGunCmdData.id)
  local itemId = talentGunData.FullyActiveItemId
  local itemData = TableData.listItemDatas:GetDataById(itemId)
  self.ui.mImg_GachaTalentIcon.sprite = IconUtils.GetItemIconSprite(itemId)
  self.ui.mText_GachaTalentName.text = itemData.name.str
  TipsManager.Add(self.ui.mBtn_GachaTalent.gameObject, itemData, nil, false)
end
function UIChrOverviewPanel:UpdateRedPoint()
  local redPoint = 0
  local unLockGuns = NetCmdTeamData:GetBarrackGunCmdDatas()
  local lockGuns = NetCmdTeamData:GetBarrackLockGunCmdDatas()
  for i = 0, unLockGuns.Count - 1 do
    if BarrackHelper.ModelMgr.curModel.tableId ~= unLockGuns[i].id then
      redPoint = redPoint + unLockGuns[i]:GetGunRedPoint()
    end
  end
  for i = 0, lockGuns.Count - 1 do
    redPoint = redPoint + lockGuns[i]:GetGunRedPoint()
  end
  setactive(self.chrSwitchRedPoint.gameObject, 0 < redPoint)
  return redPoint
end
function UIChrOverviewPanel:UpdateRank()
  self.stageItem:SetData(self.mGunCmdData.upgrade)
end
function UIChrOverviewPanel:UpdateAttributeList()
  for i, attName in ipairs(FacilityBarrackGlobal.ShowAttribute) do
    local attr = self.attributeList[i]
    local value = self:GetTotalPropValueByName(attName)
    local languagePropertyData = TableData.GetPropertyDataByName(attName, 1)
    attr:SetData(languagePropertyData, value)
  end
end
function UIChrOverviewPanel:GetTotalPropValueByName(name)
  return self.mGunCmdData:GetGunPropertyValueWithPercentByType(name)
end
function UIChrOverviewPanel:UpdateSkillList()
  if self.skillList then
    self.mGunCmdData:RecomputeGunSkillAbbr()
    local data = self.mGunCmdData.CurAbbr
    for i = 0, data.Count - 1 do
      local skill = self.skillList[i + 1]
      skill:SetData(data[i], function()
        self:OnClickSkill(skill.mBattleSkillData, i + 1)
      end)
    end
  end
  FacilityBarrackGlobal.CurBattleSkillDataList = self.skillList
end
function UIChrOverviewPanel:UpdateGunLevelLock()
  local isCanLevelUp = self.mGunCmdData.CanLevelUp
  local isFullLevel = self.mGunCmdData.IsFullLevel
  local isBreakable = not self.mGunCmdData:IsMaxClass() and self.mGunCmdData.level == self.mGunCmdData.MaxGunLevel
  local normalView = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview
  self.btnTrainingCtrl:SetVisible(not isFullLevel and normalView)
  setactive(self.ui.mTrans_MaxLevel, isFullLevel and normalView)
  setactive(self.ui.mTrans_BPToGet, false)
  setactive(self.ui.mTrans_BpLocked.transform, false)
  setactive(self.ui.mTrans_BPHasReceied, false)
  setactive(self.ui.mBtn_Receive.transform.parent, false)
  if FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass then
    local status = NetCmdBattlePassData.BattlePassStatus
    local isBuyBp = status == CS.ProtoObject.BattlepassType.AdvanceTwo or status == CS.ProtoObject.BattlepassType.AdvanceOne
    local isFullBpLevel = NetCmdBattlePassData.BattlePassLevel == NetCmdBattlePassData.CurSeason.max_level
    setactive(self.ui.mTrans_BPToGet, isBuyBp and not isFullBpLevel)
    setactive(self.ui.mTrans_BpLocked.transform, not isBuyBp)
    local isMaxRewardGet = NetCmdBattlePassData.IsMaxRewardGet
    setactive(self.ui.mTrans_BPHasReceied, isFullBpLevel and isMaxRewardGet)
    setactive(self.ui.mBtn_Receive.transform.parent, isFullBpLevel and not isMaxRewardGet and isBuyBp)
    UIUtils.GetButtonListener(self.ui.mBtn_Receive.gameObject).onClick = function()
      NetCmdBattlePassData:SendGetBattlepassReward(NetCmdBattlePassData.BattlePassStatus, NetCmdBattlePassData.CurSeason.MaxLevel, CS.ProtoCsmsg.BpRewardGetType.GetTypeNone, function(ret)
        if ret == ErrorCodeSuc then
          MessageSys:SendMessage(UIEvent.BpGetReward, nil)
          UIManager.OpenUI(UIDef.UICommonReceivePanel)
          self:UpdateGunLevelLock()
        end
      end)
    end
  end
end
function UIChrOverviewPanel:UpdateTalent()
  local id = self.mGunCmdData.id
  self:UpdateTalentButton()
  local sprite = NetCmdTalentData:GetTalentIcon(id)
  local talentData = NetCmdTalentData:GetTalentData(id)
  if sprite ~= nil then
  else
    printstack("mylog:Lua:" .. "出错了")
  end
end
function UIChrOverviewPanel:UpdateTalentButton()
  if self.btnTalentSet == nil then
    self.btnTalentSet = UIGunTalentAssemblyUnlockItem.New()
    self.btnTalentSet:InitCtrl(self.ui.mTrans_SetTalent)
    self.btnTalentSet:SetData(self.mGunCmdData.GunId)
    self.btnTalentSet:AddClickListener(function()
      self:OnClickTalentButton()
    end)
  else
    self.btnTalentSet:SetData(self.mGunCmdData.GunId)
  end
end
function UIChrOverviewPanel:OnClickTalentButton()
  if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.SquadTalentEquip) then
    local gunId = self.mGunCmdData.GunId
    local needMoveCamera = true
    UIManager.OpenUIByParam(UIDef.UIGunTalentAssemblyPanel, {gunId, needMoveCamera})
    self.canHideEffect = false
    BarrackHelper.ModelMgr:ResetBarrackIdle()
    FacilityBarrackGlobal.HideEffectNum(false)
  elseif TipsManager.NeedLockTips(SystemList.SquadTalentEquip) then
    return
  end
end
function UIChrOverviewPanel:UpdateChrWeaponItem()
  self.chrWeaponItem:SetData(self.mGunCmdData, function()
    self:OnClickWeaponItem()
  end)
end
function UIChrOverviewPanel:GunModelStopAudioAndEffect()
  local curModel = CS.UIBarrackModelManager.Instance.curModel
  curModel:StopAudio()
  curModel:StopEffect()
end
function UIChrOverviewPanel:OnClickWeaponItem()
  local param = {
    self.mGunCmdData.WeaponData.id,
    UIWeaponGlobal.WeaponPanelTab.Info,
    true,
    UIWeaponPanel.OpenFromType.Barrack,
    needReplaceBtn = true
  }
  UIManager.OpenUIByParam(UIDef.UIWeaponPanel, param)
end
function UIChrOverviewPanel:OnClickSkill(skillData, pos)
  UIManager.OpenUIByParam(UIDef.UIChrSkillInfoDialog, {
    skillData = skillData,
    gunCmdData = self.mGunCmdData,
    isGunLock = self.mGunCmdData.isLockGun,
    pos = pos,
    showBottomBtn = true,
    isGachaPreview = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIGachaPreview
  })
end
function UIChrOverviewPanel:SwitchGun(isNext)
  self.ui.mAnimator_Root:SetTrigger("Switch")
end
function UIChrOverviewPanel:InitDorm()
  UIUtils.GetButtonListener(self.ui.mBtn_Dorm.gameObject).onClick = function()
    if not NetCmdTeamData:IsDormSystemUnlock() then
      local unlockData = TableData.listUnlockDatas:GetDataById(15100)
      local str = UIUtils.CheckUnlockPopupStr(unlockData)
      PopupMessageManager.PopupString(str)
      return
    end
    local gun = NetCmdTeamData:GetGunByID(self.mGunCmdData.Id)
    if gun == nil then
      gun = NetCmdTeamData:GetLockGunByStcId(self.mGunCmdData.Id)
    end
    if gun.isDormLockGun then
      local unlockDesc = ""
      for i = 0, gun.UnlockDorm.Count - 1 do
        local id = gun.UnlockDorm[i]
        local achieve = TableData.listAchievementDetailDatas:GetDataById(id)
        if achieve ~= nil then
          unlockDesc = unlockDesc .. achieve.des.str
        end
      end
      PopupMessageManager.PopupString(unlockDesc)
    else
      NetCmdLoungeData:SetGunId(self.mGunCmdData.Id)
      NetCmdLoungeData:SetEnterSceneType(EnumSceneType.Barrack)
      SceneSys:OpenLoungeScene(function()
        UIManager.OpenUI(UIDef.DormMainPanel)
      end)
    end
  end
end
function UIChrOverviewPanel:UpdateDorm()
  local gunid = self.mGunCmdData.Id
  local normalView = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview
  setactivewithcheck(self.ui.mBtn_Dorm, NetCmdTeamData:GetGunByID(gunid) ~= nil and normalView)
  self.ui.mAnimator_Dorm:SetBool("UnLock", NetCmdTeamData:IsDormSystemUnlock() and NetCmdTeamData:GetGunDormUnlockByUnlockedID(gunid) ~= nil)
end
function UIChrOverviewPanel:InitVisualBtn()
  UISystem.BarrackCharacterCameraCtrl:SetEnterLookAtFinishedCallback(function()
    self:EnterVisual()
  end)
  UISystem.BarrackCharacterCameraCtrl:SetExitLookAtFinishedCallback(function()
    self:ExitVisual()
  end)
end
function UIChrOverviewPanel:EnterVisual()
  self.uiChrPowerUpPanel:ChangeVisualEscapeBtn(true, self.ui.mBtn_ExitVisual_TL)
  UISystem.BarrackCharacterCameraCtrl:AttachChrTouchCtrlEvents()
  setactive(self.ui.mTrans_BtnExitVisual, true)
  setactive(self.ui.mTrans_TouchPad, true)
  self.ui.mBtn_ExitVisual_TL.interactable = true
  self:ShowMask(false)
end
function UIChrOverviewPanel:ExitVisual()
  self.uiChrPowerUpPanel:ChangeVisualEscapeBtn(false)
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
  CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.FacilityBarrackEvent.ShowOrHideUI, true)
  BarrackHelper.InteractManager:OnVisualCameraChanged(false)
  FacilityBarrackGlobal.HideEffectNum(true)
  setactive(self.ui.mTrans_BtnExitVisual, false)
  setactive(self.ui.mTrans_TouchPad, false)
  self.ui.mBtn_ExitVisual_TL.interactable = true
  self:ShowMask(false)
  setactive(self.uiChrPowerUpPanel.ui.mAnimator_Arrow.gameObject, FacilityBarrackGlobal.CurShowContentType ~= FacilityBarrackGlobal.ShowContentType.UIGachaPreview)
end
function UIChrOverviewPanel:OnClickVisual(enabled)
  if not enabled and BarrackHelper.InteractManager:IsPlaying() or not UISystem.BarrackCharacterCameraCtrl:IsInteractiveCameraBlendFinished() then
    local str = TableData.GetHintById(102274)
    CS.PopupMessageManager.PopupString(str)
    return
  end
  self:ShowMask(true)
  self.ui.mBtn_ExitVisual_TL.interactable = false
  BarrackHelper.InteractManager:SetVisualState(enabled)
  if enabled then
    setactive(self.uiChrPowerUpPanel.ui.mAnimator_Arrow.gameObject, not enabled and FacilityBarrackGlobal.CurShowContentType ~= FacilityBarrackGlobal.ShowContentType.UIGachaPreview)
    function self.ui.mTrans_TouchPad.PointerDownHandler(eventData)
      BarrackHelper.InteractManager:PlayTouchEffect(eventData)
    end
    FacilityBarrackGlobal.HideEffectNum()
    UISystem.BarrackCharacterCameraCtrl:EnterLookAt()
    CS.GF2.Message.MessageSys.Instance:SendMessage(CS.GF2.Message.FacilityBarrackEvent.ShowOrHideUI, false)
    BarrackHelper.InteractManager:OnVisualCameraChanged(true)
  else
    self.ui.mTrans_TouchPad.PointerDownHandler = nil
    UISystem.BarrackCharacterCameraCtrl:ExitLookAt()
  end
end
function UIChrOverviewPanel:OnClickBtnCompose()
  if not self.isGunUnlockEnough then
    local itemData = TableData.GetItemData(self.mGunData.core_item_id)
    UITipsPanel.Open(itemData, 0, true)
  else
    NetCmdTrainGunData:SendCmdUpgradeGun(self.mGunData.id, function(ret)
      FacilityBarrackGlobal.SetNeedBarrackEntrance(true)
      self:UnLockCallBack(ret)
    end)
  end
end
function UIChrOverviewPanel:UnLockCallBack(ret)
  if ret == ErrorCodeSuc then
    local data = {}
    data.ItemId = self.mGunCmdData.id
    UICommonGetGunPanel.OpenGetGunPanel({data}, function()
      local tmpNewGunCmdData = NetCmdTeamData:GetGunByStcId(self.mGunCmdData.id)
      self:ResetData(tmpNewGunCmdData)
      if SceneSys.currentScene:GetSceneType() == CS.EnumSceneType.CommandCenter then
        SceneSys:SwitchVisible(CS.EnumSceneType.Barrack)
      end
    end, nil, true)
  else
    printstack("解锁人形失败")
  end
end
function UIChrOverviewPanel:IsNeedEffectNum()
  return self.btnTrainingCtrl:IsInteractable() and self.canHideEffect == true and self.btnChangeSkinCtrl:IsInteractable()
end
function UIChrOverviewPanel:ShowMask(boolean)
  self.uiChrPowerUpPanel:ShowMask(boolean)
end
function UIChrOverviewPanel:AddListener()
  function self.updateOrient(message)
    self:UpdateOrient(message)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackModelEvent.CameraOrient, self.updateOrient)
end
function UIChrOverviewPanel:RemoveListener()
  if self.updateOrient ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackModelEvent.CameraOrient, self.updateOrient)
    self.updateOrient = nil
  end
end
function UIChrOverviewPanel:UpdateOrient(message)
  setactive(self.ui.mBtn_ExitVisual_TL.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_ExitVisual_TR.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_ExitVisual_BL.transform.parent.gameObject, false)
  setactive(self.ui.mBtn_ExitVisual_BR.transform.parent.gameObject, false)
  setactive(self.ui.mTrans_TextTips_Top.gameObject, false)
  setactive(self.ui.mTrans_TextTips_Bottom.gameObject, false)
  local orientation = tonumber(message.Content)
  if orientation == 0 then
    setactive(self.ui.mBtn_ExitVisual_TL.transform.parent.gameObject, true)
    setactive(self.ui.mTrans_TextTips_Top.gameObject, true)
  elseif orientation == -1 then
    setactive(self.ui.mBtn_ExitVisual_BL.transform.parent.gameObject, true)
  elseif orientation == 1 then
    setactive(self.ui.mBtn_ExitVisual_TR.transform.parent.gameObject, true)
  elseif orientation == 2 then
    setactive(self.ui.mBtn_ExitVisual_BR.transform.parent.gameObject, true)
    setactive(self.ui.mTrans_TextTips_Bottom.gameObject, true)
  end
end
