require("UI.FacilityBarrackPanel.Content.UIModelToucher")
require("UI.FacilityBarrackPanel.FacilityBarrackGlobal")
require("UI.FacilityBarrackPanel.Content.UIChrStageUpPanel")
require("UI.FacilityBarrackPanel.UIChrTalent.UIChrTalentPanel")
require("UI.FacilityBarrackPanel.Content.UIChrOverviewPanel")
require("UI.FacilityBarrackPanel.Item.ChrBarrackTopBarItemV3")
UIChrPowerUpPanel = class("UIChrPowerUpPanel", UIBasePanel)
UIChrPowerUpPanel.__index = UIChrPowerUpPanel
function UIChrPowerUpPanel:ctor(csPanel)
  self.super.ctor(self, csPanel)
  csPanel.Is3DPanel = true
end
function UIChrPowerUpPanel:OnAwake(root, data)
  self:SetRoot(root)
  self.contentList = {}
  self.curContent = nil
  self.tabItemList = {}
  self.curTabItem = nil
  self.mModelGameObject = nil
  self.mGunCmdData = nil
  self.mGunData = nil
  self.roleTemplateData = nil
  self.reflectionPanel = nil
  self.notCommandCenter = false
  self.isLockGun = false
  self.lastContentType = 0
  self.curContentType = 0
  self.gachaId = 0
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
  self:InitTab()
  self:InitContent()
end
function UIChrPowerUpPanel:OnInit(root, data)
  self.notCommandCenter = false
  BarrackHelper.CameraMgr:ShowParticleObj(false)
  FacilityBarrackGlobal.CurShowContentType = FacilityBarrackGlobal.ShowContentType.UIChrOverview
  if data == nil then
    if CS.UIBarrackModelManager.Instance.GunStcDataId == 0 then
      self.mGunCmdData = NetCmdTeamData:GetFirstGun()
    else
      self:GetCurGun()
    end
  elseif data and type(data) == "userdata" then
    if data.Length > 1 and data[1] == FacilityBarrackGlobal.ShowContentType.UIGachaPreview then
      self.gachaId = data[2]
      FacilityBarrackGlobal.CurShowContentType = FacilityBarrackGlobal.ShowContentType.UIGachaPreview
      self.notCommandCenter = false
      self.mGunCmdData = NetCmdTeamData:GetGachaPreviewGunData(data[0])
    elseif data.Length > 1 and data[1] == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
      self.mGunCmdData = NetCmdTeamData:GetLockGunData(data[0], true)
      FacilityBarrackGlobal.CurShowContentType = FacilityBarrackGlobal.ShowContentType.UIShopClothes
      self.notCommandCenter = false
    elseif data.Length > 1 and data[1] == FacilityBarrackGlobal.ShowContentType.UIClothesPreview then
      self.mGunCmdData = NetCmdTeamData:GetLockGunData(data[0], true)
      FacilityBarrackGlobal.CurShowContentType = FacilityBarrackGlobal.ShowContentType.UIClothesPreview
      self.notCommandCenter = false
    elseif data.Length > 1 and data[1] == FacilityBarrackGlobal.ShowContentType.UIBpClothes then
      self.mGunCmdData = NetCmdTeamData:GetLockGunData(data[0], true)
      FacilityBarrackGlobal.CurShowContentType = FacilityBarrackGlobal.ShowContentType.UIBpClothes
      self.notCommandCenter = false
    end
  else
    self.mGunCmdData = data[1]
    FacilityBarrackGlobal.CurShowContentType = data[2]
    self.notCommandCenter = true
  end
  if FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass then
    FacilityBarrackGlobal.IsBattlePassMaxLevel = false
  end
  self.mGunData = self.mGunCmdData.TabGunData
  UIUtils.GetButtonListener(self.ui.mBtn_Back.gameObject).onClick = function()
    self:OnBackBtnClick()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_Home.gameObject).onClick = function()
    CS.UIBarrackModelManager.Instance:ResetGunStcDataId()
    UIManager.JumpToMainPanel()
  end
  UIUtils.GetButtonListener(self.ui.mBtn_PreGun.gameObject).onClick = function()
    self:SwitchGun(false)
  end
  UIUtils.GetButtonListener(self.ui.mBtn_NextGun.gameObject).onClick = function()
    self:SwitchGun(true)
  end
  for i, v in pairs(self.contentList) do
    v:OnInit(self.mGunCmdData)
  end
  self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
  self:AddListener()
end
function UIChrPowerUpPanel:OnShowStart(needBarrackEntrance)
  if needBarrackEntrance == nil then
    needBarrackEntrance = true
  end
  FacilityBarrackGlobal.SetNeedBarrackEntrance(needBarrackEntrance)
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  UIManager.EnableFacilityBarrack(true)
  setactive(UISystem.BarrackCharacterCameraCtrl.CharacterCamera, true)
  self:UpdateModel()
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
  if self.curContent ~= nil and self.curTabItem ~= nil then
    self.curTabItem:SetSelect(true)
  end
  self:ChangeContent(FacilityBarrackGlobal.ContentType.UIChrOverviewPanel, false)
  self:UpdateTabLock()
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  UIWeaponGlobal:ReleaseWeaponModel()
end
function UIChrPowerUpPanel:OnBackFrom()
  if self.curContentType == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel then
    self:OnRecover()
    return
  end
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  if self.mGunCmdData == nil then
    self.mGunCmdData = NetCmdTeamData:GetFirstGun()
    self.mGunData = self.mGunCmdData.TabGunData
  else
    self:GetCurGun()
    self:UpdateModel()
  end
  if self.curContent ~= nil then
    self.curContent:OnBackFrom()
  end
  self:OtherPanelOrDialogBack()
  self:UpdateTabLock()
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  self:ResetEffectNumObj()
  if self.curContentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel then
    FacilityBarrackGlobal.HideEffectNum(false)
  end
  if FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIGachaPreview then
    FacilityBarrackGlobal.HideEffectNum(true)
  end
end
function UIChrPowerUpPanel:OnTop()
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  if self.curContent ~= nil then
    self.curContent:OnTop()
  end
  self:OtherPanelOrDialogBack()
  self:UpdateTabLock()
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
end
function UIChrPowerUpPanel:OnShowFinish()
  UISystem.BarrackCharacterCameraCtrl:DetachChrTouchCtrlEvents()
  self:GetCurGun()
  for i, v in pairs(self.contentList) do
    self.tabItemList[i]:SetActive(v.isLockGunShow ~= nil and v.isLockGunShow and self.isLockGun or not self.isLockGun)
  end
  self.mIsRelatedBP = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass or FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection
  if self.mIsRelatedBP then
    CS.UIBarrackModelManager.Instance:SetCurModelLock(false)
  else
    CS.UIBarrackModelManager.Instance:SetCurModelLock(self.isLockGun)
  end
  if self.curContent ~= nil then
    self.curContent:OnShowFinish()
  end
  self:UpdateTabRedPoint()
  local normalView = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview
  setactive(self.ui.mScrollListChild_TopRightBtn, normalView)
  setactive(self.ui.mAnimator_Arrow, normalView)
  self:UpdateTabLock()
end
function UIChrPowerUpPanel:OnUpdate(deltaTime)
  if self.curContentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel then
    self.contentList[self.curContentType]:OnUpdate()
  end
end
function UIChrPowerUpPanel:OnHide()
  for i, v in pairs(self.contentList) do
    if v.OnHide ~= nil then
      v:OnHide()
    end
  end
  self:PlayFadeAnim(false, true, true)
end
function UIChrPowerUpPanel:OnHideFinish()
end
function UIChrPowerUpPanel:OnSave()
  FacilityBarrackGlobal.SetTargetContentType(self.curContentType)
  self.notCommandCenter = true
end
function UIChrPowerUpPanel:OnRecover()
  local targetContentType = FacilityBarrackGlobal.GetTargetContentType()
  if targetContentType == nil and self.curContentType ~= nil and self.curContentType ~= 0 then
    targetContentType = self.curContentType
  end
  SceneSys:SwitchVisible(EnumSceneType.Barrack)
  self.notCommandCenter = false
  CS.UIBarrackModelManager.Instance:ShowBarrackObjWithLayer(true)
  self:UpdateTabLock()
  self:ResetCurSelectTabItem()
  self:OnShowStart(false)
  if targetContentType == nil then
    self:ChangeContent(FacilityBarrackGlobal.ContentType.UIChrOverviewPanel, false)
  else
    self:ChangeContent(targetContentType, false)
  end
  FacilityBarrackGlobal.SetTargetContentType(nil)
  if self.curContent ~= nil then
    self.curContent:OnRecover()
  end
end
function UIChrPowerUpPanel:OnRefresh()
  self:UpdateTabRedPoint()
  self:UpdateTabLock()
  if self.curContent.OnRefresh then
    self.curContent:OnRefresh()
  end
end
function UIChrPowerUpPanel:OnClose()
  if self.curTabItem ~= nil then
    self.curTabItem:SetSelect(false)
  end
  for i, v in pairs(self.contentList) do
    v:OnClose()
  end
  UIModelToucher.ReleaseWeaponToucher()
  UIModelToucher.ReleaseCharacterToucher()
  if self.delayCameraTimer ~= nil then
    self.delayCameraTimer:Stop()
  end
  self.curContent = nil
  self.curTabItem = nil
  local curModel = CS.UIBarrackModelManager.Instance.curModel
  if curModel ~= nil and not CS.LuaUtils.IsNullOrDestroyed(curModel) then
    curModel:StopAudio()
  end
  if self.notCommandCenter == false and (FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass or FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection) then
    SceneSys:SwitchVisible(EnumSceneType.BattlePass)
    UIManager.EnableFacilityBarrack(false)
  elseif self.notCommandCenter == false and FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIShopClothes then
    SceneSys:SwitchVisible(EnumSceneType.Store)
    UIManager.EnableFacilityBarrack(false)
  elseif self.notCommandCenter == false then
    SceneSys:SwitchVisible(EnumSceneType.CommandCenter)
    UIManager.EnableFacilityBarrack(false)
    if SceneSys.currentScene ~= nil and SceneSys.currentScene.OnUIShowFinish ~= nil then
      SceneSys.currentScene:OnUIShowFinish(false)
    end
  end
  self:RemoveListener()
end
function UIChrPowerUpPanel:OnRelease()
  self.super.OnRelease(self)
  for i, v in pairs(self.contentList) do
    v:OnRelease()
  end
  self.contentList = {}
end
function UIChrPowerUpPanel:OnCameraStart()
  if not self.curContent then
    return
  end
  if self.curContent.OnCameraStart ~= nil then
    return self.curContent:OnCameraStart()
  end
end
function UIChrPowerUpPanel:OnCameraBack()
  if not self.curContent then
    return
  end
  if self.curContent.OnCameraBack ~= nil then
    return self.curContent:OnCameraBack()
  end
end
function UIChrPowerUpPanel:InitTab()
  local tmpList = {}
  local tmpIndex = 1
  local tmpTabParent = self.ui.mScrollListChild_TopRightBtn.transform
  for i, v in pairs(FacilityBarrackGlobal.ContentType) do
    local tabItem = ChrBarrackTopBarItemV3.New()
    local callback = function(contentType)
      if TipsManager.NeedLockTips(tabItem.systemId) then
        return
      end
      self:ChangeContent(contentType)
      MessageSys:SendMessage(GuideEvent.OnTabSwitched, UIDef.UIChrPowerUpPanel, tabItem:GetGlobalTab())
    end
    if tmpIndex + 1 <= tmpTabParent.childCount then
      tabItem:InitCtrl(tmpTabParent.gameObject, v, callback, tmpTabParent:GetChild(tmpIndex - 1))
    else
      tabItem:InitCtrl(tmpTabParent.gameObject, v, callback)
    end
    self.tabItemList[v] = tabItem
    tmpList[tmpIndex] = tabItem
    tmpIndex = tmpIndex + 1
  end
  table.sort(tmpList, function(a, b)
    return a.contentType < b.contentType
  end)
  for i, tab in ipairs(tmpList) do
    tab.mUIRoot:SetSiblingIndex(i - 1)
  end
end
function UIChrPowerUpPanel:UpdateTabLock()
  for _, item in pairs(self.tabItemList) do
    item:UpdateSystemLock()
  end
end
function UIChrPowerUpPanel:InitContent()
  if #self.contentList > 0 then
    return
  end
  self.curContent = nil
  for i, v in pairs(FacilityBarrackGlobal.ContentType) do
    if v == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel then
      self.contentList[FacilityBarrackGlobal.ContentType.UIChrOverviewPanel] = UIChrOverviewPanel.New(self.ui.mTrans_Overview, self)
    elseif v == FacilityBarrackGlobal.ContentType.UIChrTalentPanel then
      self.contentList[FacilityBarrackGlobal.ContentType.UIChrTalentPanel] = UIChrTalentPanel.New(self.ui.mTrans_ChrTalent, self)
    elseif v == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel then
      self.contentList[FacilityBarrackGlobal.ContentType.UIChrStageUpPanel] = UIChrStageUpPanel.New(self.ui.mTrans_StageUp, self)
    end
  end
end
function UIChrPowerUpPanel:ChangeContent(contentType, needBlending)
  needBlending = needBlending == nil and true or needBlending
  self.lastContentType = self.curContentType
  self.curContentType = contentType
  if self.curTabItem ~= nil and self.curTabItem.contentType == contentType then
    return
  end
  self:ShowMask(true)
  if self.curTabItem ~= nil then
    self:PlayFadeAnim(false)
    local cameraMoveEnd = function(attachTouch)
      self:ActiveSwitchGunBtn(true)
      self:PlayFadeAnim(true)
      self.contentList[self.lastContentType]:OnClose()
      self.contentList[self.curContentType]:OnShowStart()
      self:ShowMask(false)
      self.curTabItem = self.tabItemList[contentType]
      self:SetTabItemsSwitchMask(true)
      if contentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel then
        FacilityBarrackGlobal.HideEffectNum(true)
      end
    end
    local delayCameraMoveEnd = function(time, attachTouch)
      self.delayCameraTimer = TimerSys:DelayCall(time, function()
        cameraMoveEnd(attachTouch)
      end)
    end
    local cameraMove = function(barrackCameraOperate, attachTouch)
      self:ActiveSwitchGunBtn(false)
      BarrackHelper.CameraMgr:StartCameraMoving(barrackCameraOperate, not needBlending)
      if needBlending then
        delayCameraMoveEnd(BarrackHelper.CameraMgr:GetAlmostEndDuration(barrackCameraOperate), attachTouch)
      else
        cameraMoveEnd(attachTouch)
      end
    end
    if self.curTabItem.contentType == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel and contentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel then
      setactive(self.ui.mTrans_TouchPad.gameObject, false)
      FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
      cameraMove(BarrackCameraOperate.GradeToOverview, true)
    elseif self.curTabItem.contentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel and contentType == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel then
      FacilityBarrackGlobal.HideEffectNum()
      setactive(self.ui.mTrans_TouchPad.gameObject, false)
      cameraMove(BarrackCameraOperate.OverviewToGrade, false)
      CS.UIBarrackModelManager.Instance:ResetBarrackIdle()
    elseif self.curTabItem.contentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel and contentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel then
      setactive(self.ui.mTrans_TouchPad.gameObject, false)
      cameraMove(BarrackCameraOperate.TalentTreeToOverview, false)
    elseif self.curTabItem.contentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel and contentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel then
      FacilityBarrackGlobal.HideEffectNum()
      setactive(self.ui.mTrans_TouchPad.gameObject, false)
      cameraMove(BarrackCameraOperate.OverviewToTalentTree, false)
      BarrackHelper.ModelMgr:ResetBarrackIdle()
    elseif self.curTabItem.contentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel and contentType == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel then
      cameraMove(BarrackCameraOperate.TalentTreeToGrade, false)
    elseif self.curTabItem.contentType == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel and contentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel then
      cameraMove(BarrackCameraOperate.GradeToTalentTree, false)
    end
  else
    self:ShowMask(false)
    self.contentList[contentType]:OnShowStart()
  end
  if self.curContent ~= nil then
    self.curContent:OnHide()
  else
    self.curContent = self.contentList[contentType]
    self.curContent:OnShowStart()
  end
  self.curContent = self.contentList[contentType]
  for _, item in pairs(self.tabItemList) do
    item:SetSelect(contentType == item.contentType)
  end
  self.curTabItem = self.tabItemList[contentType]
  if needBlending then
    self:SetTabItemsSwitchMask(false)
  end
  self:EnableCharacterModel(self.curContent.needModel)
end
function UIChrPowerUpPanel:ActiveSwitchGunBtn(boolean)
  self.ui.mBtn_PreGun.interactable = boolean
  self.ui.mBtn_NextGun.interactable = boolean
end
function UIChrPowerUpPanel:PlayFadeAnim(boolean, includeTop, includeArrow)
  if includeTop == nil then
  end
  if includeArrow == nil then
  end
  local playAnim = function(animator)
    if animator == nil then
      return
    end
    if boolean then
      animator:ResetTrigger("FadeOut")
      animator:SetTrigger("FadeIn")
    else
      animator:ResetTrigger("FadeIn")
      animator:SetTrigger("FadeOut")
    end
  end
  if includeTop then
    playAnim(self.ui.mAnimator_Root)
  end
  if includeArrow then
    playAnim(self.ui.mAnimator_Arrow)
  end
  if self.curContent ~= nil and self.curContent.ui.mAnimator_Root ~= nil then
    playAnim(self.curContent.ui.mAnimator_Root)
  end
end
function UIChrPowerUpPanel:OtherPanelOrDialogBack()
  local targetContent = FacilityBarrackGlobal.GetTargetContentType()
  if targetContent ~= nil and self.curContentType ~= FacilityBarrackGlobal.ContentType.UIChrStageUpPanel then
    self:ChangeContent(targetContent)
    FacilityBarrackGlobal.SetTargetContentType(nil)
  elseif self.curContent == nil then
    self:ChangeContent(FacilityBarrackGlobal.ContentType.UIChrOverviewPanel)
  end
  if self.curContent.barrackCameraStand ~= nil then
    FacilityBarrackGlobal:SwitchCameraPos(self.curContent.barrackCameraStand)
  end
end
function UIChrPowerUpPanel:UpdateTabRedPoint()
  for i, tab in pairs(self.tabItemList) do
    local redPoint = 0
    local isUnlock = not self.isLockGun
    if tab.contentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel then
      if isUnlock then
        redPoint = NetCmdWeaponData:UpdateWeaponCanChangeRedPoint(self.mGunCmdData.WeaponId, self.mGunCmdData.GunId)
        if self.mGunCmdData.WeaponData ~= nil then
          redPoint = redPoint + self.mGunCmdData.WeaponData:GetWeaponLevelUpBreakPolarityRedPoint()
        end
        if AccountNetCmdHandler:CheckSystemIsUnLock(SystemList.GundetailWeaponpart) then
          redPoint = redPoint + NetCmdTeamData:UpdateWeaponModRedPoint(self.mGunCmdData)
        end
        redPoint = redPoint + NetCmdTalentData:TalentSkillItemRedPoint(self.mGunCmdData.GunId)
        local isBreakable = NetCmdTrainGunData:IsBreakable(self.mGunCmdData.GunId)
        if isBreakable then
          redPoint = redPoint + 1
        end
        if NetCmdGunClothesData:IsAnyClothesNeedRedPoint(self.mGunCmdData.id) then
          redPoint = redPoint + 1
        end
      else
        redPoint = NetCmdTeamData:UpdateLockRedPoint(self.mGunCmdData.TabGunData)
      end
      local overviewPanel = self.contentList[FacilityBarrackGlobal.ContentType.UIChrOverviewPanel]
      if overviewPanel ~= nil then
        redPoint = redPoint + overviewPanel:UpdateRedPoint()
      end
    elseif tab.contentType == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel then
      if isUnlock then
        redPoint = NetCmdTeamData:UpdateUpgradeRedPoint(self.mGunCmdData)
      end
    elseif tab.contentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel and isUnlock and NetCmdTalentData:IsNeedRedPointOfGunTalentTab(self.mGunCmdData.Id) then
      redPoint = redPoint + 1
    end
    tab:UpdateRedPoint(0 < redPoint)
  end
end
function UIChrPowerUpPanel:SetTabItemsSwitchMask(boolean, isAll)
  for _, item in pairs(self.tabItemList) do
    if boolean then
      item:SetSwitchMask(true)
    else
      item:SetSwitchMask(self.curContentType == item.contentType)
    end
  end
end
function UIChrPowerUpPanel:ResetCurSelectTabItem()
  for i, v in pairs(FacilityBarrackGlobal.ContentType) do
    self.tabItemList[v]:SetSelect(self.curContentType == v)
  end
end
function UIChrPowerUpPanel:OnBackBtnClick()
  if self.curTabItem.contentType ~= FacilityBarrackGlobal.ContentType.UIChrOverviewPanel then
    self:ChangeContent(FacilityBarrackGlobal.ContentType.UIChrOverviewPanel)
    return
  end
  CS.UIBarrackModelManager.Instance:ResetGunStcDataId()
  UIManager.CloseUI(UIDef.UIChrPowerUpPanel)
end
function UIChrPowerUpPanel:ChangeVisualEscapeBtn(boolean, btn)
  self:UnRegistrationKeyboard(KeyCode.Escape)
  if boolean then
    self:RegistrationKeyboard(KeyCode.Escape, btn)
  else
    self:RegistrationKeyboard(KeyCode.Escape, self.ui.mBtn_Back)
  end
end
function UIChrPowerUpPanel:SwitchGun(isNext)
  FacilityBarrackGlobal.HideEffectNum()
  isNext = isNext == nil and true or isNext
  FacilityBarrackGlobal.SetNeedBarrackEntrance(self.curTabItem.contentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel and not self.isLockGun)
  if isNext then
    CS.UIBarrackModelManager.Instance:SwitchRightGunModel(function(modelGameObject)
      self:UpdateModelCallback(modelGameObject)
    end)
  else
    CS.UIBarrackModelManager.Instance:SwitchLeftGunModel(function(modelGameObject)
      self:UpdateModelCallback(modelGameObject)
    end)
  end
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, true)
  if self.curContent ~= nil and self.curContent.SwitchGun ~= nil then
    self.curContent:SwitchGun(isNext)
  end
  self:GetCurGun()
  if self.curContent ~= nil and self.curContent.ResetData ~= nil then
    self.curContent:ResetData()
  end
end
function UIChrPowerUpPanel:GetCurGun()
  local gunId = BarrackHelper.ModelMgr.GunStcDataId
  self.isLockGun = NetCmdTeamData:GetGunByStcId(gunId) == nil and FacilityBarrackGlobal.CurShowContentType ~= FacilityBarrackGlobal.ShowContentType.UIGachaPreview
  if FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIGachaPreview then
    self.mGunCmdData = NetCmdTeamData:GetGachaPreviewGunData(gunId)
  elseif self.isLockGun then
    self.mGunCmdData = NetCmdTeamData:GetLockGunByStcId(gunId)
  else
    self.mGunCmdData = NetCmdTeamData:GetGunByStcId(gunId)
  end
  self.mGunData = self.mGunCmdData.TabGunData
  local normalView = FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrOverview
  if not normalView then
    self.mGunCmdData = NetCmdTeamData:GetLockGunData(gunId, true)
  end
end
function UIChrPowerUpPanel:UpdateModel()
  local curModel = CS.UIBarrackModelManager.Instance.curModel
  if CS.UIBarrackModelManager.Instance.GunStcDataId == self.mGunCmdData.id and curModel ~= nil and curModel.gameObject ~= nil and curModel.gameObject.activeSelf and FacilityBarrackGlobal.GetNeedBarrackEntrance() then
    curModel:Show(false)
    curModel:Show(true)
    FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
  end
  if FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIGachaPreview or FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePass or FacilityBarrackGlobal.CurShowContentType == FacilityBarrackGlobal.ShowContentType.UIChrBattlePassCollection then
    CS.UIBarrackModelManager.Instance:SwitchGunModel(self.mGunCmdData, function(modelGameObject)
    end, false)
  else
    CS.UIBarrackModelManager.Instance:SwitchGunModel(self.mGunCmdData, function(modelGameObject)
      if curModel ~= nil then
        curModel:Show(true)
      end
    end)
  end
end
function UIChrPowerUpPanel:UpdateModelCallback(modelGameObject)
  self:GetCurGun()
  self.mModelGameObject = modelGameObject
  local topUi = UISystem:GetTopPanelUI()
  if topUi.UIDefine.UIName ~= "UIChrPowerUpPanel" then
    return
  end
  self:UpdateTabRedPoint()
  if self.mModelGameObject ~= nil and self.mModelGameObject.gameObject ~= nil then
    self.mModelGameObject:Show(true)
    self:ResetEffectNumObj()
  end
end
function UIChrPowerUpPanel:OnAnimaChange(currentAnimatorStateInfo)
  local topUi = UISystem:GetTopPanelUI()
  if topUi == nil or topUi.UIDefine.UIName ~= "UIChrPowerUpPanel" then
    return
  end
  if currentAnimatorStateInfo:IsName("BarrackEntrance") then
    FacilityBarrackGlobal.HideEffectNum(false)
  elseif currentAnimatorStateInfo:IsName("BarrackIdle") then
    if self.curContentType == FacilityBarrackGlobal.ContentType.UIChrTalentPanel then
      FacilityBarrackGlobal.HideEffectNum(false)
    elseif self.curContentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel then
      local uiChrPowerUpPanel = self.contentList[self.curContentType]
      local isNeedEffectNum = uiChrPowerUpPanel:IsNeedEffectNum()
      FacilityBarrackGlobal.HideEffectNum(isNeedEffectNum)
    elseif self.curContentType == FacilityBarrackGlobal.ContentType.UIChrStageUpPanel then
      FacilityBarrackGlobal.HideEffectNum(false)
    else
      FacilityBarrackGlobal.HideEffectNum(true)
    end
    self:ResetEffectNumPosition()
  end
end
function UIChrPowerUpPanel:GunModelChangeAnimState(currentAnimatorStateInfo)
  self:OnAnimaChange(currentAnimatorStateInfo)
end
function UIChrPowerUpPanel:ResetEffectNumPosition()
  local clothesData = TableDataBase.listClothesDatas:GetDataById(self.mGunCmdData.costume)
  if not clothesData then
    return
  end
  local gunGlobalConfigData = TableData.listGunGlobalConfigDatas:GetDataById(clothesData.model_id)
  if gunGlobalConfigData ~= nil then
    FacilityBarrackGlobal.SetEffectNumPosition(gunGlobalConfigData.GunHigh)
  end
end
function UIChrPowerUpPanel:SetLookAtCharacter(obj)
  local characterSelfShadowSettings = SceneSys.currentScene.CharacterSelfShadowSettings
  if characterSelfShadowSettings then
    characterSelfShadowSettings:SetLookAtCharacter(obj)
  end
end
function UIChrPowerUpPanel:EnableCharacterModel(enable)
  if (self.gunModel or {}).gameObject and enable then
    local data = TableData.listModelConfigDatas:GetDataById(self.mGunCmdData.model_id)
    local vec = UIUtils.SplitStrToVector(data.character_type)
    self.gunModel.gameObject.transform.position = vec
    if self.reflectionPanel == nil then
      local canvas = UISystem.CharacterCanvas
      self.reflectionPanel = UIUtils.GetTransform(canvas, "ReflectionPlane")
    end
    self.reflectionPanel.transform.position = vec
  end
end
function UIChrPowerUpPanel:ResetEffectNumObj()
  local nextFrameFunc = function()
    local isNeedBarrackEntrance = FacilityBarrackGlobal.GetNeedBarrackEntrance() and self.mModelGameObject.animChangeDispatcher:IsCurAnim("BarrackIdle")
    local isIdle = false
    if self.mModelGameObject ~= nil and self.mModelGameObject.animChangeDispatcher ~= nil and not isNeedBarrackEntrance and self.mModelGameObject.gameObject ~= nil and self.mModelGameObject.gameObject.activeInHierarchy and self.mModelGameObject.animChangeDispatcher:IsCurAnim("BarrackIdle") then
      isIdle = true
    end
    FacilityBarrackGlobal.HideEffectNum(not self.isLockGun and isIdle and self.curContentType == FacilityBarrackGlobal.ContentType.UIChrOverviewPanel)
    self:ResetEffectNumPosition()
  end
  TimerSys:DelayFrameCall(5, function()
    nextFrameFunc()
  end)
end
function UIChrPowerUpPanel:ShowOrHideMask(message)
  local boolean = message.Sender
  self:ShowMask(boolean)
end
function UIChrPowerUpPanel:ShowMask(boolean)
  self:SetInputActive(not boolean)
  if self ~= nil and self.ui ~= nil and not CS.LuaUtils.IsNullOrDestroyed(self.ui.mTrans_Mask) and not CS.LuaUtils.IsNullOrDestroyed(self.ui.mTrans_Mask.gameObject) then
    setactive(self.ui.mTrans_Mask.gameObject, boolean)
  end
end
function UIChrPowerUpPanel:SetUIInteractable(interactable)
  self.mCSPanel:SetUIInteractable(interactable)
end
function UIChrPowerUpPanel:ShowOrHideUI(message)
  local boolean = message.Sender
  boolean = boolean == nil and true or boolean
  self:PlayFadeAnim(boolean, true, true)
end
function UIChrPowerUpPanel:AddListener()
  function self.showOrHideMask(message)
    self:ShowOrHideMask(message)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.ShowOrHideMask, self.showOrHideMask)
  function self.refreshGun(message)
    self:UpdateTabRedPoint()
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.RefreshGun, self.refreshGun)
  function self.showOrHideUI(message)
    self:ShowOrHideUI(message)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.ShowOrHideUI, self.showOrHideUI)
  function self.updateModelCallback(message)
    self:UpdateModelCallback(message.Sender)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.UpdateModelCallback, self.updateModelCallback)
  function self.gunModelChangeAnimState(message)
    self:GunModelChangeAnimState(message.Sender)
  end
  MessageSys:AddListener(CS.GF2.Message.FacilityBarrackEvent.GunModelChangeAnimState, self.gunModelChangeAnimState)
end
function UIChrPowerUpPanel:RemoveListener()
  if self.showOrHideMask ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.ShowOrHideMask, self.showOrHideMask)
    self.showOrHideMask = nil
  end
  if self.refreshGun ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.RefreshGun, self.refreshGun)
    self.refreshGun = nil
  end
  if self.showOrHideUI ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.ShowOrHideUI, self.showOrHideUI)
    self.showOrHideUI = nil
  end
  if self.updateModelCallback ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.UpdateModelCallback, self.updateModelCallback)
    self.updateModelCallback = nil
  end
  if self.gunModelChangeAnimState ~= nil then
    MessageSys:RemoveListener(CS.GF2.Message.FacilityBarrackEvent.GunModelChangeAnimState, self.gunModelChangeAnimState)
    self.gunModelChangeAnimState = nil
  end
end
