require("UI.UIBaseCtrl")
ChrWeaponLvUpAttributeDetailItemV4 = class("ChrWeaponLvUpAttributeDetailItemV4", UIBaseCtrl)
ChrWeaponLvUpAttributeDetailItemV4.__index = ChrWeaponLvUpAttributeDetailItemV4
function ChrWeaponLvUpAttributeDetailItemV4:ctor()
  self.mLanguagePropertyData = nil
  self.mData = nil
  self.fillAmountTween = nil
  self.isTween = false
end
function ChrWeaponLvUpAttributeDetailItemV4:InitCtrl(parent, obj)
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
function ChrWeaponLvUpAttributeDetailItemV4:SetData(data, value, defaultMaxValue, needIcon)
  if data then
    if needIcon == nil then
      needIcon = false
    end
    self.mLanguagePropertyData = data
    self.mData = data
    self.value = value
    self.defaultMaxValue = defaultMaxValue
    self.ui.mText_AttrName.text = data.show_name.str
    local fillAmount = value / defaultMaxValue
    local showValue = value
    if self.mLanguagePropertyData.show_type == 2 then
      showValue = self:PercentValue(value)
    end
    self.ui.mText_AttrNum.text = showValue
    self.ui.mText_AttrNumBefore.text = showValue
    self.ui.mText_AttrNumNow.text = showValue
    self.ui.mImg_ProgressBarBefore.fillAmount = fillAmount
    if value >= self.defaultMaxValue then
      self.ui.mText_AttrNum.color = UIWeaponGlobal.WeaponBreakColor.YellowColor
      self.ui.mImg_ProgressBarAfter.fillAmount = 0
    else
      self.ui.mText_AttrNum.color = UIWeaponGlobal.WeaponBreakColor.WhiteColor
    end
    setactive(self.mUIRoot.gameObject, true)
    setactive(self.ui.mTrans_DiffRoot, false)
    setactive(self.ui.mTrans_NowRoot, true)
  else
    self.mLanguagePropertyData = nil
    self.mData = nil
    setactive(self.mUIRoot.gameObject, false)
  end
end
function ChrWeaponLvUpAttributeDetailItemV4:ShowDiff(data, prevValue, curValue, needTween, forceSetValue)
  if needTween == nil then
    needTween = false
  end
  if forceSetValue == nil then
    forceSetValue = false
  end
  if self.isTween and not forceSetValue then
    return
  end
  if data == nil then
    data = self.mLanguagePropertyData
  else
    self.mLanguagePropertyData = data
    self.mData = data
  end
  self.ui.mText_AttrName.text = self.mLanguagePropertyData.show_name.str
  local start = prevValue / self.defaultMaxValue
  local endLv = curValue / self.defaultMaxValue
  if needTween then
    self.isTween = true
    CS.ProgressBarAnimationHelper.PlayProgress(self.ui.mImg_ProgressBarBefore, self.ui.mImg_ProgressBarAfter, start, endLv, 0.5, nil, function()
      self.isTween = false
      self.ui.mImg_ProgressBarBefore.fillAmount = prevValue / self.defaultMaxValue
      self.ui.mImg_ProgressBarAfter.fillAmount = curValue / self.defaultMaxValue
    end)
  else
    self.ui.mImg_ProgressBarBefore.fillAmount = prevValue / self.defaultMaxValue
    self.ui.mImg_ProgressBarAfter.fillAmount = curValue / self.defaultMaxValue
  end
  if self.mLanguagePropertyData.show_type == 2 then
    self.ui.mText_AttrNumBefore.text = self:PercentValue(prevValue)
    self.ui.mText_AttrNumNow.text = self:PercentValue(curValue)
  else
    self.ui.mText_AttrNumBefore.text = prevValue
    self.ui.mText_AttrNumNow.text = curValue
  end
  setactive(self.ui.mTrans_DiffRoot, true)
  setactive(self.ui.mTrans_NowRoot, false)
end
function ChrWeaponLvUpAttributeDetailItemV4:ResetAfterFillAmount()
  self.ui.mImg_ProgressBarAfter.fillAmount = self.ui.mImg_ProgressBarBefore.fillAmount
end
function ChrWeaponLvUpAttributeDetailItemV4:SetPreValueAnim(prevValue, curValue)
  local afterImage = self.ui.mImg_ProgressBarAfter
  local start = prevValue / self.defaultMaxValue
  local endLv = curValue / self.defaultMaxValue
  if self.mLanguagePropertyData.show_type == 2 then
    self.ui.mText_AttrNumBefore.text = self:PercentValue(prevValue)
    self.ui.mText_AttrNumNow.text = self:PercentValue(curValue)
  else
    self.ui.mText_AttrNumBefore.text = prevValue
    self.ui.mText_AttrNumNow.text = curValue
  end
  if self.fillAmountTween ~= nil then
    CS.UITweenManager.TweenKill(self.fillAmountTween)
  end
  self.fillAmountTween = CS.UITweenManager.PlayImageFillAmount(afterImage, start, endLv, 0.5)
end
function ChrWeaponLvUpAttributeDetailItemV4:PercentValue(value)
  value = value / 10
  value = math.floor(value * 10 + 0.5) / 10
  return value .. "%"
end
function ChrWeaponLvUpAttributeDetailItemV4:ShowOrHideDiff(boolean)
  setactive(self.ui.mTrans_DiffRoot, boolean)
  setactive(self.ui.mTrans_NowRoot, not boolean)
end
function ChrWeaponLvUpAttributeDetailItemV4:PlayNumAddTween(startValue, endValue)
  self.ui.mAnimator_Root:ResetTrigger("LvUp")
  self.ui.mAnimator_Root:SetTrigger("LvUp")
  CS.UISequenceManager.PlayNumSequence(self.ui.mText_AttrNumBefore, startValue, endValue, 0.5, nil, 0.3)
end
function ChrWeaponLvUpAttributeDetailItemV4:OnRelease(isDestroy)
  self.super.OnRelease(self, isDestroy)
end
