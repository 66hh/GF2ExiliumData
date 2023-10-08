require("UI.UIBaseCtrl")
Btn_ActivityTourChrInfoListItem = class("Btn_ActivityTourChrInfoListItem", UIBaseCtrl)
Btn_ActivityTourChrInfoListItem.__index = Btn_ActivityTourChrInfoListItem
local WillType = {
  Empty = 0,
  Half = 1,
  Full = 2
}
function Btn_ActivityTourChrInfoListItem:ctor()
  self.super.ctor(self)
end
function Btn_ActivityTourChrInfoListItem:InitCtrl(itemPrefab, parent)
  local instObj = instantiate(itemPrefab, parent)
  self:SetRoot(instObj.transform)
  self.ui = {}
  self:LuaUIBindTable(instObj.transform, self.ui)
  self.ui.mAnim_Root.keepAnimatorControllerStateOnDisable = true
  UIUtils.GetButtonListener(self.ui.mBtn_Root.gameObject).onClick = function()
    CS.RoleInfoCtrlHelper.Instance:InitSysPlayerAttrData(self.mGunCmdData)
  end
  self:InitSteady()
  self:ResetAnim()
end
function Btn_ActivityTourChrInfoListItem:ResetAnim()
  self.ui.mAnim_Root:ResetTrigger("FadeIn")
  self.ui.mAnim_Root:ResetTrigger("FadeOut")
  self.ui.mCG_Root.alpha = 0
end
function Btn_ActivityTourChrInfoListItem:FadeInOut(isFadeIn)
  UIUtils.AnimatorFadeInOut(self.ui.mAnim_Root, isFadeIn)
end
function Btn_ActivityTourChrInfoListItem:SetData(data, isAnim)
  self.mFirstInit = self.mGunProperty == nil
  self.mGunProperty = data
  self.mGunCmdData = NetCmdTeamData:GetGunByID(self.mGunProperty.Id)
  local hp = self.mGunProperty.HpPercent
  hp = math.max(0, math.min(100, hp))
  self:RefreshBase()
  self:RefreshHP(hp, isAnim)
  self:ShowWillValue(data.Ip.WillValue, isAnim)
end
function Btn_ActivityTourChrInfoListItem:RefreshBase()
  self.ui.mImage_QualityColor.color = TableData.GetGlobalGun_Quality_Color2(self.mGunCmdData.gunData.rank)
  self.ui.mImage_Avatar.sprite = IconUtils.GetCharacterHeadSprite(self.mGunCmdData.gunData.Code)
  self.ui.mText_Name.text = self.mGunCmdData.gunData.name.str
end
function Btn_ActivityTourChrInfoListItem:RefreshHP(value, isAnim)
  if self.mHP == value then
    return
  end
  self.mHP = value
  local oldValue = self.mHPProgress
  self.mHPProgress = self.mHP * 1.0 / ActivityTourGlobal.MaxHp
  if isAnim == nil then
    isAnim = true
  end
  if not isAnim then
    self.ui.mProgress_HP.FillAmount = self.mHPProgress
    self.ui.mGray_Avatar:SetGray(self.mHPProgress <= 0)
    return
  end
  if self.mFirstInit == false and oldValue < self.mHPProgress then
    self.ui.mAnim_Root:SetTrigger("Add")
  end
  setactive(self.ui.mProgress_AddHP.gameObject, true)
  setactive(self.ui.mTrans_AddEffect.gameObject, true)
  if self.tweenShield ~= nil then
    LuaDOTweenUtils.Kill(self.tweenShield, false)
  end
  self.ui.mProgress_AddHP.FillAmount = self.mHPProgress
  self.ui.mProgress_HP.FillAmount = oldValue
  local getter = function(tempSelf)
    return self.ui.mProgress_HP.FillAmount
  end
  local setter = function(tempSelf, value)
    self.ui.mProgress_HP.FillAmount = value
  end
  self.tweenShield = LuaDOTweenUtils.ToOfFloat(self, getter, setter, self.mHPProgress, 0.7, function()
    self.ui.mProgress_HP.FillAmount = self.mHPProgress
    self.ui.mGray_Avatar:SetGray(self.mHPProgress <= 0)
    setactive(self.ui.mProgress_AddHP.gameObject, false)
    setactive(self.ui.mTrans_AddEffect.gameObject, false)
  end)
end
function Btn_ActivityTourChrInfoListItem:InitSteady()
  self.mWillIcon = {}
  self.mWillIcon[WillType.Full] = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_2")
  self.mWillIcon[WillType.Half] = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_1")
  self.mWillIcon[WillType.Empty] = IconUtils.GetAtlasIcon("Attribute/Icon_Steady_0")
end
function Btn_ActivityTourChrInfoListItem:ShowWillValue(cur, isAnim)
  if self.mCurWillValue == cur then
    return
  end
  local oldValue = self.mCurWillValue
  self.mCurWillValue = cur
  if not isAnim then
    self:SetWillValue(self.mCurWillValue)
    return
  end
  if self.mWillTimer ~= nil then
    self.mWillTimer:Stop()
    self.mWillTimer = nil
  end
  local count = math.abs(self.mCurWillValue - oldValue)
  local offset = 1
  if oldValue > self.mCurWillValue then
    offset = -1
  end
  local setValue = oldValue
  self.mWillTimer = self:DelayCall(0.05, function()
    setValue = setValue + offset
    self:SetWillValue(setValue)
  end, nil, count)
end
function Btn_ActivityTourChrInfoListItem:SetWillValue(willValue)
  local maxWill = ActivityTourGlobal.GetMaxWillValue(self.mGunCmdData.id)
  local willType = WillType.Half
  if willValue == 0 then
    willType = WillType.Empty
  elseif willValue >= maxWill then
    willType = WillType.Full
  end
  self.ui.mText_Steady.text = tostring(willValue)
  self.ui.mImage_SteadyIcon.sprite = self.mWillIcon[willType]
  setactive(self.ui.mImage_SteadyBreak, willType == WillType.Empty)
end
function Btn_ActivityTourChrInfoListItem:OnRelease()
  self.super:OnRelease()
  if self.tweenShield ~= nil then
    LuaDOTweenUtils.Kill(self.tweenShield, false)
    self.tweenShield = nil
  end
  self:ReleaseTimers()
  self.mWillTimer = nil
end
