UIChrWeaponPowerUpDialogV3 = class("UIChrWeaponPowerUpDialogV3", UIBasePanel)
UIChrWeaponPowerUpDialogV3.__index = UIChrWeaponPowerUpDialogV3
function UIChrWeaponPowerUpDialogV3:ctor(csPanel)
  UIChrWeaponPowerUpDialogV3.super:ctor(csPanel)
  csPanel.Is3DPanel = true
  self.weaponCmdData = nil
  self.costWeaponCmdData = nil
  self.isMaxBreakTimes = false
  self.lastBreakTimes = 0
  self.breakRoundItemInterval = 0.3
  self.closeInterval = 0
  self.btnTimer = nil
  self.scaleTime1 = 0.5
  self.scaleTime2 = 0.3
  self.targetScale1 = 1.334
  self.WeaponPowerUpObj = nil
  self.GrpRoundObj = nil
  self.mAnimator_Root = nil
end
function UIChrWeaponPowerUpDialogV3:OnAwake(root, data)
  self:SetRoot(root)
  self.ui = {}
  self:LuaUIBindTable(root, self.ui)
end
function UIChrWeaponPowerUpDialogV3:OnInit(root, data)
  self.lastBreakTimes = data.lastBreakTimes
  self.callback = data.callback
  self.weaponCmdData = data.weaponCmdData
  self.costWeaponCmdData = data.costWeaponCmdData
  self.isMaxBreakTimes = self.weaponCmdData.BreakTimes == self.weaponCmdData.StcData.MaxBreak
  self.WeaponPowerUpObj = BarrackHelper.CameraMgr.Barrack3DCanvas.transform:Find("WeaponPowerUp")
  self.GrpRoundObj = self.WeaponPowerUpObj.transform:Find("Root/GrpBg/GrpRound")
  local aniRoot = self.WeaponPowerUpObj.transform:Find("Root")
  self.mAnimator_Root = aniRoot.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
  self:CloseAllAudio()
end
function UIChrWeaponPowerUpDialogV3:OnShowStart()
  self:SetWeaponData()
end
function UIChrWeaponPowerUpDialogV3:OnRecover()
  self:SetWeaponData()
end
function UIChrWeaponPowerUpDialogV3:OnBackFrom()
  self:SetWeaponData()
end
function UIChrWeaponPowerUpDialogV3:OnTop()
  self:SetWeaponData()
end
function UIChrWeaponPowerUpDialogV3:OnShowFinish()
end
function UIChrWeaponPowerUpDialogV3:OnCameraStart()
  return 0.01
end
function UIChrWeaponPowerUpDialogV3:OnCameraBack()
  return 0.01
end
function UIChrWeaponPowerUpDialogV3:OnHide()
  self:CloseAllAudio()
end
function UIChrWeaponPowerUpDialogV3:OnHideFinish()
  if self.callback ~= nil then
    self.callback()
  end
  self:CloseAllFx()
  setactive(self.WeaponPowerUpObj, false)
end
function UIChrWeaponPowerUpDialogV3:OnClose()
  self.btnTimer = nil
  self:RemoveListener()
end
function UIChrWeaponPowerUpDialogV3:OnRelease()
  self.super.OnRelease(self)
end
function UIChrWeaponPowerUpDialogV3:SetWeaponData()
  setactive(self.WeaponPowerUpObj, true)
  self:CloseAllFx()
  self.ui.mText_Weapon.text = self.weaponCmdData.Name
  self.ui.mImg_Num.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. self.lastBreakTimes)
  local tmpParent = self.GrpRoundObj
  for i = 0, self.weaponCmdData.StcData.MaxBreak - 1 do
    local imgItem = tmpParent:GetChild(i)
    setactive(imgItem:GetChild(0), i < self.lastBreakTimes)
  end
  self:InitBreakTimesSequence()
  self.btnTimer = TimerSys:DelayCall(self.closeInterval, function()
    self:AddListener()
  end)
  self:WeaponModelTween(true)
end
function UIChrWeaponPowerUpDialogV3:CloseAllAudio()
end
function UIChrWeaponPowerUpDialogV3:CloseAllFx()
  local tmpParent = self.GrpRoundObj
  for i = 0, tmpParent.childCount - 2 do
    local child = tmpParent:GetChild(i)
    local fx = child:GetChild(1)
    setactive(fx.gameObject, false)
  end
end
function UIChrWeaponPowerUpDialogV3:InitBreakTimesSequence()
  local tmpParent = self.GrpRoundObj
  local sequence = CS.LuaTweenUtils.Sequence()
  local interval = CSUIUtils.GetClipLengthByEndsWith(self.mAnimator_Root, "FadeIn_1")
  local interval2 = CSUIUtils.GetClipLengthByEndsWith(self.mAnimator_Root, "FadeIn_2")
  if self.isMaxBreakTimes then
    interval2 = CSUIUtils.GetClipLengthByEndsWith(self.mAnimator_Root, "FadeIn_3")
  end
  self.closeInterval = interval + interval2
  CS.LuaTweenUtils.AppendInterval(sequence, interval)
  for i = self.lastBreakTimes + 1, self.weaponCmdData.BreakTimes do
    CS.LuaTweenUtils.AppendInterval(sequence, self.breakRoundItemInterval)
    CS.LuaTweenUtils.AppendCallBack(sequence, function()
      local tmpImg = tmpParent:GetChild(i - 1):GetChild(0)
      setactive(tmpImg.gameObject, true)
      setactive(self.ui.mImg_Num, false)
      setactive(self.ui.mImg_Num, true)
      self.ui.mImg_Num.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. i)
      local fx = tmpParent:GetChild(i - 1):GetChild(1)
      setactive(fx.gameObject, i == self.lastBreakTimes + 1)
    end)
    self.closeInterval = self.closeInterval + self.breakRoundItemInterval
  end
  CS.LuaTweenUtils.AppendCallBack(sequence, function()
    self:BreakTimesAnimEnd()
  end)
end
function UIChrWeaponPowerUpDialogV3:BreakTimesAnimEnd()
  if self.isMaxBreakTimes then
    self.mAnimator_Root:SetTrigger("FadeIn_3")
  else
    self.mAnimator_Root:SetTrigger("FadeIn_2")
  end
  self.ui.mAnimator_Root:SetTrigger("FadeIn_2")
  self.ui.mImg_Num.sprite = IconUtils.GetUIWeaponBreakNum("Img_BreakNum" .. self.weaponCmdData.BreakTimes)
  if self.costWeaponCmdData:HasPart() then
    local hint = TableData.GetHintById(220057)
    local param = {
      contentText = hint,
      customData = self.costWeaponCmdData.DicWeaponParts
    }
    UIManager.OpenUIByParam(UIDef.UIComDoubleCheckDialog, param)
  end
end
function UIChrWeaponPowerUpDialogV3:WeaponModelScale(endValue, duration)
  local weaponModel = UIBarrackWeaponModelManager.CurWeaponModel
  LuaDOTweenUtils.DoScale(weaponModel.transform, endValue, duration, 0)
end
function UIChrWeaponPowerUpDialogV3:WeaponModelTween(boolean)
  if boolean then
    UIBarrackWeaponModelManager:SetRootPositionByScale(self.targetScale1, self.scaleTime1)
  else
    UIBarrackWeaponModelManager:SetRootPositionByScale(1, self.scaleTime2)
  end
end
function UIChrWeaponPowerUpDialogV3:OnBgClick()
  self:WeaponModelTween(false)
  self.mAnimator_Root:SetTrigger("FadeOut")
  UIManager.CloseUI(UIDef.UIChrWeaponPowerUpDialogV3)
end
function UIChrWeaponPowerUpDialogV3:AddListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = function()
    self:OnBgClick()
  end
end
function UIChrWeaponPowerUpDialogV3:RemoveListener()
  UIUtils.GetButtonListener(self.ui.mBtn_Close.gameObject).onClick = nil
end
