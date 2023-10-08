require("UI.FacilityBarrackPanel.Content.UIBarrackShooting.UIBarrackBreakSubPanel")
require("UI.FacilityBarrackPanel.Content.UIBarrackShooting.UIBarrackLevelUpSubPanel")
UIBarrackTrainingPanel = class("UIBarrackTrainingPanel", UIBasePanel)
function UIBarrackTrainingPanel:ctor(csPanel)
  UIBarrackTrainingPanel.super.ctor(UIBarrackTrainingPanel, csPanel)
  csPanel.Is3DPanel = true
end
function UIBarrackTrainingPanel:OnAwake(root, gunId)
  self.ui = UIUtils.GetUIBindTable(root)
  self:SetRoot(root)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnBack.gameObject, function()
    self:onClickBack()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_BtnHome.gameObject, function()
    self:onClickHome()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_LeftArrow.gameObject, function()
    self:onClickLeftArrow()
  end)
  UIUtils.AddBtnClickListener(self.ui.mBtn_RightArrow.gameObject, function()
    self:onClickRightArrow()
  end)
  self.levelUpSubPanel = UIBarrackLevelUpSubPanel.New(self.ui.mTrans_GrpTrain, self)
  self.breakSubPanel = UIBarrackBreakSubPanel.New(self.ui.mTrans_GrpBreak, self)
  self.levelUpSubPanel:SetVisible(false)
  self.breakSubPanel:SetVisible(false)
  self.levelUpSubPanel:AddStartTimelineListener(function()
    self:onStartLevelUpTimeline()
  end)
  self.breakSubPanel:AddStartTimelineListener(function()
    self:onStartBreakTimeline()
  end)
end
function UIBarrackTrainingPanel:OnInit(root, gunId)
  self.gunId = gunId
  self.gunCmdData = NetCmdTeamData:GetGunByID(self.gunId)
  self.levelUpSubPanel:SetData(self.gunCmdData)
  self.breakSubPanel:SetData(self.gunCmdData)
end
function UIBarrackTrainingPanel:OnShowStart()
  self:refresh()
end
function UIBarrackTrainingPanel:OnBackFrom()
  self:refresh()
end
function UIBarrackTrainingPanel:OnHide()
  if self.levelUpSubPanel:IsVisible() then
  end
  if self.breakSubPanel:IsVisible() then
  end
end
function UIBarrackTrainingPanel:OnTop()
  if self.gunCmdData.level == self.gunCmdData.MaxGunLevel then
    self.breakSubPanel:RefreshItemCost()
  else
    self.levelUpSubPanel:RefreshItemCountByCurFocusLevel()
  end
end
function UIBarrackTrainingPanel:OnRecover()
  local gunId = BarrackHelper.ModelMgr.GunStcDataId
  self:OnInit(nil, gunId)
  BarrackHelper.CameraMgr:ChangeCameraStand(BarrackCameraStand.Base, false)
  BarrackHelper.CameraMgr:StartCameraMoving(BarrackCameraOperate.OverviewToUpgrade, true)
  BarrackHelper.SceneMgr:SetAimoLineEffectVisible(true)
end
function UIBarrackTrainingPanel:OnClose()
  FacilityBarrackGlobal:SwitchCameraPos(BarrackCameraStand.Base, false)
  self.isInTraining = nil
end
function UIBarrackTrainingPanel:OnRelease()
  self.clickHomeFlag = nil
  self.gunId = nil
  self.gunCmdData = nil
  self.levelUpSubPanel:OnRelease()
  self.breakSubPanel:OnRelease()
  self.ui = nil
  self.super.OnRelease(self)
end
function UIBarrackTrainingPanel:OnCameraStart()
  if self.mCSPanel.ShowType.value__ == 0 then
    return BarrackHelper.CameraMgr:GetAlmostEndDuration(BarrackCameraOperate.OverviewToUpgrade)
  end
  return 0.01
end
function UIBarrackTrainingPanel:OnCameraBack()
  if self.clickHomeFlag then
    return 0
  end
  return BarrackHelper.CameraMgr:GetAlmostEndDuration(BarrackCameraOperate.UpgradeToOverview)
end
function UIBarrackTrainingPanel:OnRefresh()
  if TutorialSystem.IsInTutorial then
    if self.levelUpSubPanel:IsVisible() then
      self.levelUpSubPanel:RefreshItemCountByCurFocusLevel()
    elseif self.breakSubPanel:IsVisible() then
      self.breakSubPanel:RefreshItemCost()
    end
  end
end
function UIBarrackTrainingPanel:onStartLevelUpTimeline()
  self:CallWithAniDelay(function()
    self:setRootVisible(false)
  end)
end
function UIBarrackTrainingPanel:onStartBreakTimeline()
  self:CallWithAniDelay(function()
    self:setRootVisible(false)
  end)
end
function UIBarrackTrainingPanel:onTimelineEnd()
  self:setRootVisible(true)
end
function UIBarrackTrainingPanel:setRootVisible(visible)
  if visible then
    self.ui.mCanvasGroup_Root.alpha = 1
  else
    self.ui.mCanvasGroup_Root.alpha = 0
  end
  self.ui.mCanvasGroup_Root.blocksRaycasts = visible
  self:SetVisible(visible)
end
function UIBarrackTrainingPanel:refresh()
  FacilityBarrackGlobal.HideEffectNum(false)
  self.clickHomeFlag = false
  self.breakSubPanel:SetVisible(false)
  self.levelUpSubPanel:SetVisible(false)
  if self.gunCmdData.level == self.gunCmdData.MaxGunLevel then
    self.breakSubPanel:SetVisible(true)
  else
    self.levelUpSubPanel:SetVisible(true)
  end
  if self.gunCmdData.level == self.gunCmdData.MaxGunLevel then
    local data = TableDataBase.listGunLevelExpDatas:GetDataById(self.gunCmdData.level)
    self.ui.mSmoothMask_Exp.FillAmount = self.gunCmdData.Exp / data.Exp
  else
    local data = TableDataBase.listGunLevelExpDatas:GetDataById(self.gunCmdData.level + 1)
    self.ui.mSmoothMask_Exp.FillAmount = self.gunCmdData.Exp / data.Exp
  end
  self:refreshGunInfo()
  self:refreshSwitchArrow()
end
function UIBarrackTrainingPanel:refreshGunInfo()
  if not self.gunCmdData then
    return
  end
  self.ui.mText_TextChrName.text = self.gunCmdData.gunData.name.str
  self.ui.mText_TextNow.text = tostring(self.gunCmdData.Level)
  self.ui.mText_TextMax.text = "/" .. tostring(self.gunCmdData.MaxGunLevel)
end
function UIBarrackTrainingPanel:refreshSwitchArrow()
  local gunCmdData = self:getValidGunCmdData(self.gunId, true, 1, NetCmdTeamData.GunCount)
  setactivewithcheck(self.ui.mBtn_RightArrow, gunCmdData ~= nil)
  setactivewithcheck(self.ui.mBtn_LeftArrow, gunCmdData ~= nil)
end
function UIBarrackTrainingPanel:onClickBack()
  if self.levelUpSubPanel:IsInTraining() or self.breakSubPanel:IsInTraining() then
    return
  end
  if self.clickHomeFlag then
    return
  end
  UIManager.CloseUI(self.mCSPanel)
  BarrackHelper.ModelMgr:ChangeChrAnim("BarrackIdle")
  BarrackHelper.CameraMgr:StartCameraMoving(CS.BarrackCameraOperate.UpgradeToOverview)
end
function UIBarrackTrainingPanel:onClickLeftArrow()
  if NetCmdTeamData.GunCount <= 1 then
    return
  end
  local gunCmdData = self:getValidGunCmdData(self.gunId, false, 1, NetCmdTeamData.GunCount)
  if not gunCmdData or gunCmdData.GunId == self.gunId then
    return
  end
  self.ui.mAnimator:SetTrigger("Previous")
  FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
  BarrackHelper.ModelMgr:SwitchGunModel(gunCmdData, function()
    self:onSwitchedModel()
  end)
  self:OnInit(nil, gunCmdData.GunId)
  self:refresh()
end
function UIBarrackTrainingPanel:onClickRightArrow()
  if NetCmdTeamData.GunCount <= 1 then
    return
  end
  local gunCmdData = self:getValidGunCmdData(self.gunId, true, 1, NetCmdTeamData.GunCount)
  if not gunCmdData or gunCmdData.GunId == self.gunId then
    return
  end
  self.ui.mAnimator:SetTrigger("Next")
  FacilityBarrackGlobal.SetNeedBarrackEntrance(false)
  BarrackHelper.ModelMgr:SwitchGunModel(gunCmdData, function()
    self:onSwitchedModel()
  end)
  self:OnInit(nil, gunCmdData.GunId)
  self:refresh()
end
function UIBarrackTrainingPanel:onSwitchedModel()
  BarrackHelper.ModelMgr.curModel:Show(true)
  BarrackHelper.ModelMgr:ChangeChrAnim("BarrackIdle")
  BarrackHelper.ModelMgr:PlayChangeGunEffect()
end
function UIBarrackTrainingPanel:getValidGunCmdData(gunId, isNext, itorCount, allGunCount)
  if allGunCount < itorCount then
    return nil
  end
  local gunCmdData = NetCmdTeamData:GetOtherGunById(gunId, isNext)
  if NetCmdTeamData:IsLocked(gunCmdData) or gunCmdData.IsFullLevel then
    return self:getValidGunCmdData(gunCmdData.GunId, isNext, itorCount + 1, allGunCount)
  end
  if gunCmdData.id == self.gunId then
    return nil
  end
  return gunCmdData
end
function UIBarrackTrainingPanel:onClickHome()
  self.clickHomeFlag = true
  BarrackHelper.ModelMgr:ChangeChrAnim("BarrackIdle")
  UIManager.JumpToMainPanel()
end
